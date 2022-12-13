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
        // 制御
        input wire          STALL,
        input wire          FLUSH,
        input wire  [31:0]  NEW_PC,
        output wire         MEM_WAIT,

        // 入力
        input               EXEC,

        // 出力
        output wire [31:0]  I_PC,
        output wire [31:0]  I_INST,
        output wire         I_VALID,

        /* ----- AXIバス信号 ----- */
        // ARチャンネル
        output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_ARID,
        output wire [C_M_AXI_ADDR_WIDTH-1:0]        M_AXI_ARADDR,
        output wire [8-1:0]                         M_AXI_ARLEN,
        output wire [3-1:0]                         M_AXI_ARSIZE,
        output wire [2-1:0]                         M_AXI_ARBURST,
        output wire [2-1:0]                         M_AXI_ARLOCK,
        output wire [4-1:0]                         M_AXI_ARCACHE,
        output wire [3-1:0]                         M_AXI_ARPROT,
        output wire [4-1:0]                         M_AXI_ARQOS,
        output wire [C_M_AXI_ARUSER_WIDTH-1:0]      M_AXI_ARUSER,
        output wire                                 M_AXI_ARVALID,
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

    /* ----- プログラムカウンタ ----- */
    reg         delayed_exec, delayed_flush, pc_valid;
    reg [31:0]  pc;

    always @ (posedge CLK) begin
        delayed_exec <= EXEC;
        delayed_flush <= FLUSH;
    end

    always @ (posedge CLK) begin
        if (RST)
            pc_valid <= 1'b0;
        else if (EXEC && !STALL)
            pc_valid <= 1'b1;
        else if (!EXEC)
            pc_valid <= 1'b0;
    end

    always @ (posedge CLK) begin
        if (RST)
            pc <= 32'h2000_0000;
        else if (FLUSH)
            pc <= NEW_PC;
        else if (delayed_exec && !STALL)
            pc <= pc + 32'd4;
    end

    /* ----- 出力 ----- */
    wire [31:0] i_pc, i_inst;
    wire        i_valid;

    assign I_PC     = i_pc;
    assign I_INST   = delayed_flush ? 32'b0 : i_inst;
    assign I_VALID  = delayed_flush ? 32'b0 : i_valid;

    /* ----- キャッシュメモリ ----- */
    instmem # (
        .C_M_AXI_THREAD_ID_WIDTH(C_M_AXI_THREAD_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH     (C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH     (C_M_AXI_DATA_WIDTH),
        .C_M_AXI_ARUSER_WIDTH   (C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH    (C_M_AXI_RUSER_WIDTH)
    ) instmem (
        .CLK            (CLK),
        .RST            (RST),

        .STALL          (STALL),
        .FLUSH          (FLUSH),

        .ADDR           (pc),
        .RDEN           (pc_valid),
        .OADDR          (i_pc),
        .DOUT           (i_inst),
        .VALID          (i_valid),

        .LOADING        (MEM_WAIT),

        .M_AXI_ARID     (M_AXI_ARID),
        .M_AXI_ARADDR   (M_AXI_ARADDR),
        .M_AXI_ARLEN    (M_AXI_ARLEN),
        .M_AXI_ARSIZE   (M_AXI_ARSIZE),
        .M_AXI_ARBURST  (M_AXI_ARBURST),
        .M_AXI_ARLOCK   (M_AXI_ARLOCK),
        .M_AXI_ARCACHE  (M_AXI_ARCACHE),
        .M_AXI_ARPROT   (M_AXI_ARPROT),
        .M_AXI_ARQOS    (M_AXI_ARQOS),
        .M_AXI_ARUSER   (M_AXI_ARUSER),
        .M_AXI_ARVALID  (M_AXI_ARVALID),
        .M_AXI_ARREADY  (M_AXI_ARREADY),
        .M_AXI_RID      (M_AXI_RID),
        .M_AXI_RDATA    (M_AXI_RDATA),
        .M_AXI_RRESP    (M_AXI_RRESP),
        .M_AXI_RLAST    (M_AXI_RLAST),
        .M_AXI_RUSER    (M_AXI_RUSER),
        .M_AXI_RVALID   (M_AXI_RVALID),
        .M_AXI_RREADY   (M_AXI_RREADY)
    );

endmodule
