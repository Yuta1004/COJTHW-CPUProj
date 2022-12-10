//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I) : Inst Fetch
// Project     : cpu_proj
// Filename    : inst_fetch.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/09  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module inst_fetch #
    (
        parameter integer C_M_AXI_THREAD_ID_WIDTH = 1,
        parameter integer C_M_AXI_ADDR_WIDTH      = 32,
        parameter integer C_M_AXI_DATA_WIDTH      = 32,
        parameter integer C_M_AXI_ARUSER_WIDTH    = 1,
        parameter integer C_M_AXI_RUSER_WIDTH     = 4
    )
    (
        /* ----- クロック&リセット信号 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- 上位との接続用 ----- */
        input wire          STALL,
        output wire         MEM_WAIT,

        input wire          PC_VALID,
        input wire  [31:0]  PC,
        output reg          INST_VALID,
        output wire [31:0]  INST,

        /* ----- AXIバス信号 ----- */
        // ARチャンネル
        output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_ARID,
        output reg  [C_M_AXI_ADDR_WIDTH-1:0]        M_AXI_ARADDR,
        output wire [8-1:0]                         M_AXI_ARLEN,
        output wire [3-1:0]                         M_AXI_ARSIZE,
        output wire [2-1:0]                         M_AXI_ARBURST,
        output wire [2-1:0]                         M_AXI_ARLOCK,
        output wire [4-1:0]                         M_AXI_ARCACHE,
        output wire [3-1:0]                         M_AXI_ARPROT,
        output wire [4-1:0]                         M_AXI_ARQOS,
        output wire [C_M_AXI_ARUSER_WIDTH-1:0]      M_AXI_ARUSER,
        output reg                                  M_AXI_ARVALID,
        input  wire                                 M_AXI_ARREADY,

        // Rチャンネル
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_RID,
        input  wire [C_M_AXI_DATA_WIDTH-1:0]        M_AXI_RDATA,
        input  wire [2-1:0]                         M_AXI_RRESP,
        input  wire                                 M_AXI_RLAST,
        input  wire [C_M_AXI_RUSER_WIDTH-1:0]       M_AXI_RUSER,
        input  wire                                 M_AXI_RVALID,
        output wire                                 M_AXI_RREADY
    );

    /* ----- AXIバス設定 ----- */
    // ARチャンネル
    assign M_AXI_ARID       = 'b0;
    assign M_AXI_ARLEN      = 8'h1f;
    assign M_AXI_ARSIZE     = 3'b010;
    assign M_AXI_ARBURST    = 2'b01;
    assign M_AXI_ARLOCK     = 1'b0;
    assign M_AXI_ARCACHE    = 4'b0011;
    assign M_AXI_ARPROT     = 3'h0;
    assign M_AXI_ARQOS      = 4'h0;
    assign M_AXI_ARUSER     = 'b0;

    // Rチャンネル
    assign M_AXI_RREADY     = 1'b1;

    /* ----- BRAM ----- */
    wire [3:0]  bram_wren;
    wire [31:0] bram_din, bram_dout;

    wire        bram_en = 1'b1;
    wire [31:0] bram_addr = { 20'b0, loaded ? PC[11:0] : r_waddr };

    bram_4kb bram_4kb (
        .clka   (CLK),
        .rsta   (RST),
        .ena    (bram_en),
        .addra  (bram_addr),
        .dina   (bram_din),
        .wea    (bram_wren),
        .douta  (bram_dout)
    );

    /* ----- ページ存在確認 ----- */
    reg [19:0]  loaded_page_addr;

    wire loaded = loaded_page_addr == PC[31:12];

    always @ (posedge CLK) begin
        if (RST)
            loaded_page_addr <= 20'b1111_1111_1111_1111_1111;
        else if (M_AXI_RVALID && M_AXI_RLAST && M_AXI_ARADDR[11:0] == 12'b0)
            loaded_page_addr <= PC[31:12];
    end

    /* ----- 出力 ----- */
    always @ (posedge CLK) begin
        INST_VALID <= PC_VALID && loaded;
    end

    assign INST = bram_dout;
    assign MEM_WAIT = PC_VALID && !loaded;

    /* ----- DRAMアクセス(AR)用ステートマシン ----- */
    parameter S_AR_IDLE = 2'b00;
    parameter S_AR_ADDR = 2'b01;
    parameter S_AR_WAIT = 2'b11;

    reg [1:0] ar_state, ar_next_state;

    always @ (posedge CLK) begin
        if (RST)
            ar_state <= S_AR_IDLE;
        else
            ar_state <= ar_next_state;
    end

    always @* begin
        case (ar_state)
            S_AR_IDLE:
                if (PC_VALID && !loaded)
                    ar_next_state <= S_AR_ADDR;
                else
                    ar_next_state <= S_AR_IDLE;

            S_AR_ADDR:
                if (M_AXI_ARREADY)
                    ar_next_state <= S_AR_WAIT;
                else
                    ar_next_state <= S_AR_ADDR;

            S_AR_WAIT:
                if (M_AXI_RVALID && M_AXI_RLAST) begin
                    if (M_AXI_ARADDR[11:0] == 12'b0)
                        ar_next_state <= S_AR_IDLE;
                    else
                        ar_next_state <= S_AR_ADDR;
                end
                else
                    ar_next_state <= S_AR_WAIT;

            default:
                ar_next_state <= S_AR_IDLE;
        endcase
    end

    always @ (posedge CLK) begin
        if (RST)
            M_AXI_ARADDR <= 32'h2000_0000;
        else if (ar_state == S_AR_IDLE && ar_next_state == S_AR_ADDR)
            M_AXI_ARADDR <= { PC[31:12], 12'b0 };
        else if (ar_state == S_AR_ADDR && M_AXI_ARREADY)
            M_AXI_ARADDR <= M_AXI_ARADDR + 32'd128;
    end

    always @ (posedge CLK) begin
        if (RST)
            M_AXI_ARVALID <= 1'b0;
        else if (ar_next_state == S_AR_ADDR)
            M_AXI_ARVALID <= 1'b1;
        else if (ar_state == S_AR_ADDR && M_AXI_ARREADY)
            M_AXI_ARVALID <= 1'b0;
    end

    /* ----- DRAMアクセス(R)用ステートマシン ----- */
    parameter S_R_IDLE = 2'b00;
    parameter S_R_READ = 2'b01;

    reg [1:0]   r_state, r_next_state;
    reg [11:0]  r_waddr;

    always @ (posedge CLK) begin
        if (RST)
            r_state <= S_R_IDLE;
        else
            r_state <= r_next_state;
    end

    always @* begin
        case (r_state)
            S_R_IDLE:
                if (M_AXI_ARADDR != r_waddr)
                    r_next_state <= S_R_READ;
                else
                    r_next_state <= S_R_IDLE;

            S_R_READ:
                if (M_AXI_RVALID && M_AXI_RLAST)
                    r_next_state <= S_R_IDLE;
                else
                    r_next_state <= S_R_READ;

            default:
                r_next_state <= S_R_IDLE;
        endcase
    end

    always @ (posedge CLK) begin
        if (RST)
            r_waddr <= 12'hfff;
        else if (r_state == S_R_IDLE && M_AXI_ARADDR != r_waddr)
            r_waddr <= M_AXI_ARADDR[11:0];
        else if (r_state == S_R_READ && M_AXI_RVALID)
            r_waddr <= r_waddr + 12'd4;
    end

    assign bram_din = M_AXI_RDATA;
    assign bram_wren = M_AXI_RVALID ? 4'hf : 4'h0;

endmodule
