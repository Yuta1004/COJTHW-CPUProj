//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I) : Cache-4K (for Data, Device)
// Project     : cpu_proj
// Filename    : cachemem/data.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/12  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module datamem #
    (
        parameter integer C_M_AXI_THREAD_ID_WIDTH = 1,
        parameter integer C_M_AXI_ADDR_WIDTH      = 32,
        parameter integer C_M_AXI_DATA_WIDTH      = 32,
        parameter integer C_M_AXI_AWUSER_WIDTH    = 1,
        parameter integer C_M_AXI_ARUSER_WIDTH    = 1,
        parameter integer C_M_AXI_WUSER_WIDTH     = 4,
        parameter integer C_M_AXI_RUSER_WIDTH     = 4,
        parameter integer C_M_AXI_BUSER_WIDTH     = 1
    )
    (
        /* ----- クロック&リセット信号 ----- */
        input               CLK,
        input               RST,

        /* ----- 制御信号 ----- */
        input               STALL,
        input               FLUSH,

        /* ----- メモリアクセス用信号 ----- */
        // 読み
        input wire          RDEN,
        input wire  [31:0]  RDADDR,
        input wire  [1:0]   RDSIZE,
        input wire          RDSIGNED,
        output reg  [31:0]  RDDATA,

        // 書き
        input wire          WREN,
        input wire  [31:0]  WRADDR,
        input wire  [3:0]   WRSTRB,
        input wire  [31:0]  WRDATA,

        /* ----- キャッシュ状態通知用信号 ----- */
        output wire         LOADING,

        /* ----- AXIバス ----- */
        // AWチャンネル
        output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_AWID,
        output reg  [C_M_AXI_ADDR_WIDTH-1:0]        M_AXI_AWADDR,
        output reg  [8-1:0]                         M_AXI_AWLEN,
        output wire [3-1:0]                         M_AXI_AWSIZE,
        output wire [2-1:0]                         M_AXI_AWBURST,
        output wire [2-1:0]                         M_AXI_AWLOCK,
        output wire [4-1:0]                         M_AXI_AWCACHE,
        output wire [3-1:0]                         M_AXI_AWPROT,
        output wire [4-1:0]                         M_AXI_AWQOS,
        output wire [C_M_AXI_AWUSER_WIDTH-1:0]      M_AXI_AWUSER,
        output reg                                  M_AXI_AWVALID,
        input  wire                                 M_AXI_AWREADY,

        // Wチャンネル
        output reg  [C_M_AXI_DATA_WIDTH-1:0]        M_AXI_WDATA,
        output reg  [C_M_AXI_DATA_WIDTH/8-1:0]      M_AXI_WSTRB,
        output reg                                  M_AXI_WLAST,
        output wire [C_M_AXI_WUSER_WIDTH-1:0]       M_AXI_WUSER,
        output reg                                  M_AXI_WVALID,
        input  wire                                 M_AXI_WREADY,

        // Bチャンネル
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_BID,
        input  wire [2-1:0]                         M_AXI_BRESP,
        input  wire [C_M_AXI_BUSER_WIDTH-1:0]       M_AXI_BUSER,
        input  wire                                 M_AXI_BVALID,
        output wire                                 M_AXI_BREADY,

        // ARチャンネル
        output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_ARID,
        output reg  [C_M_AXI_ADDR_WIDTH-1:0]        M_AXI_ARADDR,
        output reg  [8-1:0]                         M_AXI_ARLEN,
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
    // AWチャンネル
    assign M_AXI_AWID      = 'b0;
    assign M_AXI_AWSIZE    = 3'b010;
    assign M_AXI_AWBURST   = 2'b01;
    assign M_AXI_AWLOCK    = 2'b00;
    assign M_AXI_AWCACHE   = 4'b0011;
    assign M_AXI_AWPROT    = 3'h0;
    assign M_AXI_AWQOS     = 4'h0;
    assign M_AXI_AWUSER    = 'b0;

    // Wチャンネル
    assign M_AXI_WUSER     = 'b0;

    // Bチャンネル
    assign M_AXI_BREADY    = 1'b1;

    // ARチャンネル
    assign M_AXI_ARID      = 'b0;
    assign M_AXI_ARSIZE    = 3'b010;
    assign M_AXI_ARBURST   = 2'b01;
    assign M_AXI_ARLOCK    = 1'b0;
    assign M_AXI_ARCACHE   = 4'b0011;
    assign M_AXI_ARPROT    = 3'h0;
    assign M_AXI_ARQOS     = 4'h0;
    assign M_AXI_ARUSER    = 'b0;

    // Rチャンネル
    assign M_AXI_RREADY    = 1'b1;

    /* ----- 状態通知 ----- */
    assign LOADING = (RDEN && sr_next_state != S_SR_IDLE) || (WREN && sw_next_state != S_SW_IDLE);

    /* ----- 即時メモリアクセス(AR, R)用ステートマシン ----- */
    parameter S_SR_IDLE   = 2'b00;
    parameter S_SR_ADDR   = 2'b01;
    parameter S_SR_WAIT   = 2'b11;
    parameter S_SR_FINISH = 2'b10;

    reg [31:0] sr_cache;
    reg [1:0]  sr_state, sr_next_state;

    always @ (posedge CLK) begin
        if (RST)
            sr_state <= S_SR_IDLE;
        else
            sr_state <= sr_next_state;
    end

    always @* begin
        case (sr_state)
            S_SR_IDLE:
                if (RDEN && (!(WREN && RDADDR[31:2] == WRADDR[31:2]) || sw_state == S_SW_FINISH))
                    sr_next_state <= S_SR_ADDR;
                else
                    sr_next_state <= S_SR_IDLE;

            S_SR_ADDR:
                if (M_AXI_ARREADY)
                    sr_next_state <= S_SR_WAIT;
                else
                    sr_next_state <= S_SR_ADDR;

            S_SR_WAIT:
                if (M_AXI_RVALID)
                    sr_next_state <= S_SR_FINISH;
                else
                    sr_next_state <= S_SR_WAIT;

            S_SR_FINISH:
                if (!WREN || sw_state == S_SW_FINISH)
                    sr_next_state <= S_SR_IDLE;
                else
                    sr_next_state <= S_SR_FINISH;

            default:
                sr_next_state <= S_SR_IDLE;
        endcase
    end

    always @ (posedge CLK) begin
        if (RST) begin
            M_AXI_ARADDR <= 32'b0;
            M_AXI_ARLEN <= 8'b0;
            M_AXI_ARVALID <= 1'b0;
        end
        else if (sr_next_state == S_SR_ADDR) begin
            M_AXI_ARADDR <= RDADDR & (~32'd3);
            M_AXI_ARLEN <= 8'b0;
            M_AXI_ARVALID <= 1'b1;
        end
        else if (sr_state == S_SR_ADDR && M_AXI_ARREADY) begin
            M_AXI_ARADDR <= 32'b0;
            M_AXI_ARLEN <= 8'b0;
            M_AXI_ARVALID <= 1'b0;
        end
    end

    always @ (posedge CLK) begin
        if (RST)
            RDDATA <= 32'b0;
        else if (M_AXI_RVALID)
            sr_cache <= M_AXI_RDATA;
        else if (sr_next_state == S_SR_IDLE)
            RDDATA <= sr_cache;
    end

    /* ----- 即時メモリアクセス(AW, W)用ステートマシン ----- */
    parameter S_SW_IDLE   = 2'b00;
    parameter S_SW_ADDR   = 2'b01;
    parameter S_SW_WRITE  = 2'b11;
    parameter S_SW_FINISH = 2'b10;

    reg [1:0] sw_state, sw_next_state;

    always @ (posedge CLK) begin
        if (RST)
            sw_state <= S_SW_IDLE;
        else
            sw_state <= sw_next_state;
    end

    always @* begin
        case (sw_state)
            S_SW_IDLE:
                if (WREN)
                    sw_next_state <= S_SW_ADDR;
                else
                    sw_next_state <= S_SW_IDLE;

            S_SW_ADDR:
                if (M_AXI_AWREADY)
                    sw_next_state <= S_SW_WRITE;
                else
                    sw_next_state <= S_SW_ADDR;

            S_SW_WRITE:
                if (M_AXI_WREADY)
                    sw_next_state <= S_SW_FINISH;
                else
                    sw_next_state <= S_SW_WRITE;

            S_SW_FINISH:
                if (!RDEN || sr_state == S_SR_FINISH)
                    sw_next_state <= S_SW_IDLE;
                else
                    sw_next_state <= S_SW_FINISH;

            default:
                sw_next_state <= S_SW_IDLE;
        endcase
    end

    always @ (posedge CLK) begin
        if (RST) begin
            M_AXI_AWADDR <= 32'b0;
            M_AXI_AWLEN <= 8'b0;
            M_AXI_AWVALID <= 1'b0;
        end
        else if (sw_next_state == S_SW_ADDR) begin
            M_AXI_AWADDR <= WRADDR & (~32'd3);
            M_AXI_AWLEN <= 8'b0;
            M_AXI_AWVALID <= 1'b1;
        end
        else if (sw_state == S_SW_ADDR && sw_next_state == S_SW_WRITE) begin
            M_AXI_AWADDR <= 32'b0;
            M_AXI_AWLEN <= 8'b0;
            M_AXI_AWVALID <= 1'b0;
        end
    end

    always @ (posedge CLK) begin
        if (RST) begin
            M_AXI_WDATA <= 32'b0;
            M_AXI_WSTRB <= 4'b0000;
            M_AXI_WLAST <= 1'b0;
            M_AXI_WVALID <= 1'b0;
        end
        else if (sw_next_state == S_SW_ADDR) begin
            M_AXI_WDATA <= WRDATA;
            M_AXI_WSTRB <= WRSTRB;
            M_AXI_WLAST <= 1'b1;
            M_AXI_WVALID <= 1'b1;
        end
        else if (sw_next_state == S_SW_FINISH) begin
            M_AXI_WDATA <= 32'b0;
            M_AXI_WSTRB <= 4'b0000;
            M_AXI_WLAST <= 1'b0;
            M_AXI_WVALID <= 1'b0;
        end
    end

endmodule
