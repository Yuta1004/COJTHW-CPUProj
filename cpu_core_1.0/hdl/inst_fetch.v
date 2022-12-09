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
        parameter integer C_M_AXI_BURST_LEN       = 1,
        parameter integer C_M_AXI_ID_WIDTH        = 1,
        parameter integer C_M_AXI_ADDR_WIDTH      = 32,
        parameter integer C_M_AXI_DATA_WIDTH      = 32,
        parameter integer C_M_AXI_AWUSER_WIDTH    = 1,
        parameter integer C_M_AXI_ARUSER_WIDTH    = 1,
        parameter integer C_M_AXI_WUSER_WIDTH     = 4,
        parameter integer C_M_AXI_RUSER_WIDTH     = 4,
        parameter integer C_M_AXI_BUSER_WIDTH     = 1
    )
    (
        /* ----- AXIバス用クロック ----- */
        input wire          ACLK,
        input wire          ARESETN,

        /* ----- AXIバス信号 ----- */
        // AWチャンネル
        output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_AWID,
        output wire [C_M_AXI_ADDR_WIDTH-1:0]        M_AXI_AWADDR,
        output wire [8-1:0]                         M_AXI_AWLEN,
        output wire [3-1:0]                         M_AXI_AWSIZE,
        output wire [2-1:0]                         M_AXI_AWBURST,
        output wire [2-1:0]                         M_AXI_AWLOCK,
        output wire [4-1:0]                         M_AXI_AWCACHE,
        output wire [3-1:0]                         M_AXI_AWPROT,
        output wire [4-1:0]                         M_AXI_AWQOS,
        output wire [C_M_AXI_AWUSER_WIDTH-1:0]      M_AXI_AWUSER,
        output wire                                 M_AXI_AWVALID,
        input  wire                                 M_AXI_AWREADY,

        // Wチャンネル
        output wire [C_M_AXI_DATA_WIDTH-1:0]        M_AXI_WDATA,
        output wire [C_M_AXI_DATA_WIDTH/8-1:0]      M_AXI_WSTRB,
        output wire                                 M_AXI_WLAST,
        output wire [C_M_AXI_WUSER_WIDTH-1:0]       M_AXI_WUSER,
        output wire                                 M_AXI_WVALID,
        input  wire                                 M_AXI_WREADY,

        // Bチャンネル
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_BID,
        input  wire [2-1:0]                         M_AXI_BRESP,
        input  wire [C_M_AXI_BUSER_WIDTH-1:0]       M_AXI_BUSER,
        input  wire                                 M_AXI_BVALID,
        output wire                                 M_AXI_BREADY,

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
        output wire                                 M_AXI_RREADY,

        /* ----- クロック&リセット(CCLK系) ----- */
        input wire          CCLK,
        input wire          CRST,

        /* ----- 上位との接続用 ----- */
        input wire          PC_VALID,
        input wire [31:0]   PC,

        output reg          INST_VALID,
        output reg [31:0]   INST,
        output reg          MEM_WAIT
    );

    /* ----- AXIバス設定 ----- */
    // AWチャンネル
    assign M_AXI_AWID       = 'b0;
    assign M_AXI_AWADDR     = 32'b0;
    assign M_AXI_AWLEN      = 8'b0;
    assign M_AXI_AWSIZE     = 3'b010;
    assign M_AXI_AWBURST    = 2'b01;
    assign M_AXI_AWLOCK     = 2'b00;
    assign M_AXI_AWCACHE    = 4'b0011;
    assign M_AXI_AWPROT     = 3'h0;
    assign M_AXI_AWQOS      = 4'h0;
    assign M_AXI_AWUSER     = 'b0;
    assign M_AXI_AWVALID    = 1'b0;

    // Wチャンネル
    assign M_AXI_WDATA      = 32'b0;
    assign M_AXI_WSTRB      = 4'b1111;
    assign M_AXI_WLAST      = 1'b0;
    assign M_AXI_WUSER      = 'b0;
    assign M_AXI_WVALID     = 1'b0;

    // Bチャンネル
    assign M_AXI_BREADY     = 1'b0;

    // ARチャンネル
    assign M_AXI_ARID       = 'b0;
    assign M_AXI_ARADDR     = 32'b0;   // *
    assign M_AXI_ARLEN      = 8'b0;    // *
    assign M_AXI_ARSIZE     = 3'b010;
    assign M_AXI_ARBURST    = 2'b01;
    assign M_AXI_ARLOCK     = 1'b0;
    assign M_AXI_ARCACHE    = 4'b0011;
    assign M_AXI_ARPROT     = 3'h0;
    assign M_AXI_ARQOS      = 4'h0;
    assign M_AXI_ARUSER     = 'b0;
    assign M_AXI_ARVALID    = 1'b0;    // *

    // Rチャンネル
    assign M_AXI_RREADY     = 1'b0;    // *

    /* ----- 命令出力 ----- */
    always @ (posedge CCLK) begin
        if (CRST)
            INST_VALID <= 1'b0;
    end

    always @ (posedge CCLK) begin
        if (CRST)
            INST <= 32'b0;
    end

    always @ (posedge CCLK) begin
        if (CRST)
            MEM_WAIT <= 1'b0;
    end

endmodule
