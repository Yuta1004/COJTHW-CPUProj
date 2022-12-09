//-----------------------------------------------------------------------------
// Title       : Core TB用インクルードファイル（doreとAXBFMを直結）
// Project     : cpu_proj
// Filename    : cpu_axibfm.vh
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/09  1.00     Y.Nakagami   Created
//-----------------------------------------------------------------------------


/* ----- AXIバス(命令)接続用 ----- */
// AWチャンネル
wire                            M_INST_AXI_AWID;
wire [31:0]                     M_INST_AXI_AWADDR;
wire [7:0]                      M_INST_AXI_AWLEN;
wire [2:0]                      M_INST_AXI_AWSIZE;
wire [1:0]                      M_INST_AXI_AWBURST;
wire [1:0]                      M_INST_AXI_AWLOCK;
wire [3:0]                      M_INST_AXI_AWCACHE;
wire [2:0]                      M_INST_AXI_AWPROT;
wire [3:0]                      M_INST_AXI_AWQOS;
wire                            M_INST_AXI_AWUSER;
wire                            M_INST_AXI_AWVALID;
wire                            M_INST_AXI_AWREADY;

// Wチャンネル
wire [C_AXI_DATA_WIDTH-1:0]     M_INST_AXI_WDATA;
wire [C_AXI_DATA_WIDTH/8-1:0]   M_INST_AXI_WSTRB;
wire                            M_INST_AXI_WLAST;
wire                            M_INST_AXI_WUSER;
wire                            M_INST_AXI_WVALID;
wire                            M_INST_AXI_WREADY;

// Bチャンネル
wire                            M_INST_AXI_BID;
wire [1:0]                      M_INST_AXI_BRESP;
wire                            M_INST_AXI_BUSER;
wire                            M_INST_AXI_BVALID;
wire                            M_INST_AXI_BREADY;

// ARチャンネル
wire                            M_INST_AXI_ARID;
wire [31:0]                     M_INST_AXI_ARADDR;
wire [7:0]                      M_INST_AXI_ARLEN;
wire [2:0]                      M_INST_AXI_ARSIZE;
wire [1:0]                      M_INST_AXI_ARBURST;
wire [1:0]                      M_INST_AXI_ARLOCK;
wire [3:0]                      M_INST_AXI_ARCACHE;
wire [2:0]                      M_INST_AXI_ARPROT;
wire [3:0]                      M_INST_AXI_ARQOS;
wire                            M_INST_AXI_ARUSER;
wire                            M_INST_AXI_ARVALID;
wire                            M_INST_AXI_ARREADY;

// Rチャンネル
wire                            M_INST_AXI_RID;
wire [C_AXI_DATA_WIDTH-1:0]     M_INST_AXI_RDATA;
wire [1:0]                      M_INST_AXI_RRESP;
wire                            M_INST_AXI_RLAST;
wire                            M_INST_AXI_RUSER;
wire                            M_INST_AXI_RVALID;
wire                            M_INST_AXI_RREADY;


/* ----- AXIバス(データ)接続用 ----- */
// AWチャンネル
wire                            M_DATA_AXI_AWID;
wire [31:0]                     M_DATA_AXI_AWADDR;
wire [7:0]                      M_DATA_AXI_AWLEN;
wire [2:0]                      M_DATA_AXI_AWSIZE;
wire [1:0]                      M_DATA_AXI_AWBURST;
wire [1:0]                      M_DATA_AXI_AWLOCK;
wire [3:0]                      M_DATA_AXI_AWCACHE;
wire [2:0]                      M_DATA_AXI_AWPROT;
wire [3:0]                      M_DATA_AXI_AWQOS;
wire                            M_DATA_AXI_AWUSER;
wire                            M_DATA_AXI_AWVALID;
wire                            M_DATA_AXI_AWREADY;

// Wチャンネル
wire [C_AXI_DATA_WIDTH-1:0]     M_DATA_AXI_WDATA;
wire [C_AXI_DATA_WIDTH/8-1:0]   M_DATA_AXI_WSTRB;
wire                            M_DATA_AXI_WLAST;
wire                            M_DATA_AXI_WUSER;
wire                            M_DATA_AXI_WVALID;
wire                            M_DATA_AXI_WREADY;

// Bチャンネル
wire                            M_DATA_AXI_BID;
wire [1:0]                      M_DATA_AXI_BRESP;
wire                            M_DATA_AXI_BUSER;
wire                            M_DATA_AXI_BVALID;
wire                            M_DATA_AXI_BREADY;

// ARチャンネル
wire                            M_DATA_AXI_ARID;
wire [31:0]                     M_DATA_AXI_ARADDR;
wire [7:0]                      M_DATA_AXI_ARLEN;
wire [2:0]                      M_DATA_AXI_ARSIZE;
wire [1:0]                      M_DATA_AXI_ARBURST;
wire [1:0]                      M_DATA_AXI_ARLOCK;
wire [3:0]                      M_DATA_AXI_ARCACHE;
wire [2:0]                      M_DATA_AXI_ARPROT;
wire [3:0]                      M_DATA_AXI_ARQOS;
wire                            M_DATA_AXI_ARUSER;
wire                            M_DATA_AXI_ARVALID;
wire                            M_DATA_AXI_ARREADY;

// Rチャンネル
wire                            M_DATA_AXI_RID;
wire [C_AXI_DATA_WIDTH-1:0]     M_DATA_AXI_RDATA;
wire [1:0]                      M_DATA_AXI_RRESP;
wire                            M_DATA_AXI_RLAST;
wire                            M_DATA_AXI_RUSER;
wire                            M_DATA_AXI_RVALID;
wire                            M_DATA_AXI_RREADY;


/* ----- Core接続 ----- */
core #
    (
        .C_M_AXI_DATA_WIDTH (C_AXI_DATA_WIDTH)
    )
    core
    (
        /* ----- AXIバス用クロック ----- */
        .ACLK           (ACLK),
        .ARESETN        (ARESETN),

        /* ----- AXIバス信号(命令用) ----- */
        // AWチャンネル
        .M_INST_AXI_AWID     (M_INST_AXI_AWID),
        .M_INST_AXI_AWADDR   (M_INST_AXI_AWADDR),
        .M_INST_AXI_AWLEN    (M_INST_AXI_AWLEN),
        .M_INST_AXI_AWSIZE   (M_INST_AXI_AWSIZE),
        .M_INST_AXI_AWBURST  (M_INST_AXI_AWBURST),
        .M_INST_AXI_AWLOCK   (M_INST_AXI_AWLOCK),
        .M_INST_AXI_AWCACHE  (M_INST_AXI_AWCACHE),
        .M_INST_AXI_AWPROT   (M_INST_AXI_AWPROT),
        .M_INST_AXI_AWQOS    (M_INST_AXI_AWQOS),
        .M_INST_AXI_AWUSER   (M_INST_AXI_AWUSER),
        .M_INST_AXI_AWVALID  (M_INST_AXI_AWVALID),
        .M_INST_AXI_AWREADY  (M_INST_AXI_AWREADY),

        // Wチャンネル
        .M_INST_AXI_WDATA    (M_INST_AXI_WDATA),
        .M_INST_AXI_WSTRB    (M_INST_AXI_WSTRB),
        .M_INST_AXI_WLAST    (M_INST_AXI_WLAST),
        .M_INST_AXI_WUSER    (M_INST_AXI_WUSER),
        .M_INST_AXI_WVALID   (M_INST_AXI_WVALID),
        .M_INST_AXI_WREADY   (M_INST_AXI_WREADY),

        // Bチャンネル
        .M_INST_AXI_BID      (M_INST_AXI_BID),
        .M_INST_AXI_BRESP    (M_INST_AXI_BRESP),
        .M_INST_AXI_BUSER    (M_INST_AXI_BUSER),
        .M_INST_AXI_BVALID   (M_INST_AXI_BVALID),
        .M_INST_AXI_BREADY   (M_INST_AXI_BREADY),

        // ARチャンネル
        .M_INST_AXI_ARID     (M_INST_AXI_ARID),
        .M_INST_AXI_ARADDR   (M_INST_AXI_ARADDR),
        .M_INST_AXI_ARLEN    (M_INST_AXI_ARLEN),
        .M_INST_AXI_ARSIZE   (M_INST_AXI_ARSIZE),
        .M_INST_AXI_ARBURST  (M_INST_AXI_ARBURST),
        .M_INST_AXI_ARLOCK   (M_INST_AXI_ARLOCK),
        .M_INST_AXI_ARCACHE  (M_INST_AXI_ARCACHE),
        .M_INST_AXI_ARPROT   (M_INST_AXI_ARPROT),
        .M_INST_AXI_ARQOS    (M_INST_AXI_ARQOS),
        .M_INST_AXI_ARUSER   (M_INST_AXI_ARUSER),
        .M_INST_AXI_ARVALID  (M_INST_AXI_ARVALID),
        .M_INST_AXI_ARREADY  (M_INST_AXI_ARREADY),

        // Rチャンネル
        .M_INST_AXI_RID      (M_INST_AXI_RID),
        .M_INST_AXI_RDATA    (M_INST_AXI_RDATA),
        .M_INST_AXI_RRESP    (M_INST_AXI_RRESP),
        .M_INST_AXI_RLAST    (M_INST_AXI_RLAST),
        .M_INST_AXI_RUSER    (M_INST_AXI_RUSER),
        .M_INST_AXI_RVALID   (M_INST_AXI_RVALID),
        .M_INST_AXI_RREADY   (M_INST_AXI_RREADY),

        /* ----- AXIバス信号(データ用) ----- */
        // AWチャンネル
        .M_DATA_AXI_AWID     (M_DATA_AXI_AWID),
        .M_DATA_AXI_AWADDR   (M_DATA_AXI_AWADDR),
        .M_DATA_AXI_AWLEN    (M_DATA_AXI_AWLEN),
        .M_DATA_AXI_AWSIZE   (M_DATA_AXI_AWSIZE),
        .M_DATA_AXI_AWBURST  (M_DATA_AXI_AWBURST),
        .M_DATA_AXI_AWLOCK   (M_DATA_AXI_AWLOCK),
        .M_DATA_AXI_AWCACHE  (M_DATA_AXI_AWCACHE),
        .M_DATA_AXI_AWPROT   (M_DATA_AXI_AWPROT),
        .M_DATA_AXI_AWQOS    (M_DATA_AXI_AWQOS),
        .M_DATA_AXI_AWUSER   (M_DATA_AXI_AWUSER),
        .M_DATA_AXI_AWVALID  (M_DATA_AXI_AWVALID),
        .M_DATA_AXI_AWREADY  (M_DATA_AXI_AWREADY),

        // Wチャンネル
        .M_DATA_AXI_WDATA    (M_DATA_AXI_WDATA),
        .M_DATA_AXI_WSTRB    (M_DATA_AXI_WSTRB),
        .M_DATA_AXI_WLAST    (M_DATA_AXI_WLAST),
        .M_DATA_AXI_WUSER    (M_DATA_AXI_WUSER),
        .M_DATA_AXI_WVALID   (M_DATA_AXI_WVALID),
        .M_DATA_AXI_WREADY   (M_DATA_AXI_WREADY),

        // Bチャンネル
        .M_DATA_AXI_BID      (M_DATA_AXI_BID),
        .M_DATA_AXI_BRESP    (M_DATA_AXI_BRESP),
        .M_DATA_AXI_BUSER    (M_DATA_AXI_BUSER),
        .M_DATA_AXI_BVALID   (M_DATA_AXI_BVALID),
        .M_DATA_AXI_BREADY   (M_DATA_AXI_BREADY),

        // ARチャンネル
        .M_DATA_AXI_ARID     (M_DATA_AXI_ARID),
        .M_DATA_AXI_ARADDR   (M_DATA_AXI_ARADDR),
        .M_DATA_AXI_ARLEN    (M_DATA_AXI_ARLEN),
        .M_DATA_AXI_ARSIZE   (M_DATA_AXI_ARSIZE),
        .M_DATA_AXI_ARBURST  (M_DATA_AXI_ARBURST),
        .M_DATA_AXI_ARLOCK   (M_DATA_AXI_ARLOCK),
        .M_DATA_AXI_ARCACHE  (M_DATA_AXI_ARCACHE),
        .M_DATA_AXI_ARPROT   (M_DATA_AXI_ARPROT),
        .M_DATA_AXI_ARQOS    (M_DATA_AXI_ARQOS),
        .M_DATA_AXI_ARUSER   (M_DATA_AXI_ARUSER),
        .M_DATA_AXI_ARVALID  (M_DATA_AXI_ARVALID),
        .M_DATA_AXI_ARREADY  (M_DATA_AXI_ARREADY),

        // Rチャンネル
        .M_DATA_AXI_RID      (M_DATA_AXI_RID),
        .M_DATA_AXI_RDATA    (M_DATA_AXI_RDATA),
        .M_DATA_AXI_RRESP    (M_DATA_AXI_RRESP),
        .M_DATA_AXI_RLAST    (M_DATA_AXI_RLAST),
        .M_DATA_AXI_RUSER    (M_DATA_AXI_RUSER),
        .M_DATA_AXI_RVALID   (M_DATA_AXI_RVALID),
        .M_DATA_AXI_RREADY   (M_DATA_AXI_RREADY),

        /*----- CPU制御信号 ----- */
        // クロック
        .CCLK   (CCLK),
        .CRST   (CRST),
        .CEXEC  (CEXEC),

        // CPU状態
        .STAT   (STAT),

        // デバッグ用
        .REG00  (REG00),
        .REG01  (REG01),
        .REG02  (REG02),
        .REG03  (REG03),
        .REG04  (REG04),
        .REG05  (REG05),
        .REG06  (REG06),
        .REG07  (REG07),
        .REG08  (REG08),
        .REG09  (REG09),
        .REG10  (REG10),
        .REG11  (REG11),
        .REG12  (REG12),
        .REG13  (REG13),
        .REG14  (REG14),
        .REG15  (REG15),
        .REG16  (REG16),
        .REG17  (REG17),
        .REG18  (REG18),
        .REG19  (REG19),
        .REG20  (REG20),
        .REG21  (REG21),
        .REG22  (REG22),
        .REG23  (REG23),
        .REG24  (REG24),
        .REG25  (REG25),
        .REG26  (REG26),
        .REG27  (REG27),
        .REG28  (REG28),
        .REG29  (REG29),
        .REG30  (REG30),
        .REG31  (REG31),
        .REGPC  (REGPC)
);


/* ----- BFM接続(命令) ----- */
axi_slave_bfm #
    (
        .READ_RANDOM_WAIT       (1),
        .C_S_AXI_DATA_WIDTH     (C_AXI_DATA_WIDTH),
        .READ_DATA_IS_INCREMENT (0),
        .C_OFFSET_WIDTH         (C_OFFSET_WIDTH),
        .ARREADY_IS_USUALLY_HIGH(1)
    )
    axi_slave_bfm_inst
    (
        // クロック
        .ACLK           (ACLK),
        .ARESETN        (ARESETN),

        // AWチャンネル
        .S_AXI_AWID     (M_INST_AXI_AWID),
        .S_AXI_AWADDR   (M_INST_AXI_AWADDR),
        .S_AXI_AWLEN    (M_INST_AXI_AWLEN),
        .S_AXI_AWSIZE   (M_INST_AXI_AWSIZE),
        .S_AXI_AWBURST  (M_INST_AXI_AWBURST),
        .S_AXI_AWLOCK   (M_INST_AXI_AWLOCK),
        .S_AXI_AWCACHE  (M_INST_AXI_AWCACHE),
        .S_AXI_AWPROT   (M_INST_AXI_AWPROT),
        .S_AXI_AWQOS    (M_INST_AXI_AWQOS),
        .S_AXI_AWUSER   (M_INST_AXI_AWUSER),
        .S_AXI_AWVALID  (M_INST_AXI_AWVALID),
        .S_AXI_AWREADY  (M_INST_AXI_AWREADY),

        // Wチャンネル
        .S_AXI_WDATA    (M_INST_AXI_WDATA),
        .S_AXI_WSTRB    (M_INST_AXI_WSTRB),
        .S_AXI_WLAST    (M_INST_AXI_WLAST),
        .S_AXI_WUSER    (M_INST_AXI_WUSER),
        .S_AXI_WVALID   (M_INST_AXI_WVALID),
        .S_AXI_WREADY   (M_INST_AXI_WREADY),

        // Bチャンネル
        // Slave Interface Write Response
        .S_AXI_BID      (M_INST_AXI_BID),
        .S_AXI_BRESP    (M_INST_AXI_BRESP),
        .S_AXI_BUSER    (M_INST_AXI_BUSER),
        .S_AXI_BVALID   (M_INST_AXI_BVALID),
        .S_AXI_BREADY   (M_INST_AXI_BREADY),

        // ARチャンネル
        .S_AXI_ARID     (M_INST_AXI_ARID),
        .S_AXI_ARADDR   (M_INST_AXI_ARADDR),
        .S_AXI_ARLEN    (M_INST_AXI_ARLEN),
        .S_AXI_ARSIZE   (M_INST_AXI_ARSIZE),
        .S_AXI_ARBURST  (M_INST_AXI_ARBURST),
        .S_AXI_ARLOCK   (M_INST_AXI_ARLOCK),
        .S_AXI_ARCACHE  (M_INST_AXI_ARCACHE),
        .S_AXI_ARPROT   (M_INST_AXI_ARPROT),
        .S_AXI_ARQOS    (M_INST_AXI_ARQOS),
        .S_AXI_ARUSER   (M_INST_AXI_ARUSER),
        .S_AXI_ARVALID  (M_INST_AXI_ARVALID),
        .S_AXI_ARREADY  (M_INST_AXI_ARREADY),

        // Rチャンネル
        .S_AXI_RID      (M_INST_AXI_RID),
        .S_AXI_RDATA    (M_INST_AXI_RDATA),
        .S_AXI_RRESP    (M_INST_AXI_RRESP),
        .S_AXI_RLAST    (M_INST_AXI_RLAST),
        .S_AXI_RUSER    (M_INST_AXI_RUSER),
        .S_AXI_RVALID   (M_INST_AXI_RVALID),
        .S_AXI_RREADY   (M_INST_AXI_RREADY)
);


/* ----- BFM接続(データ) ----- */
axi_slave_bfm #
    (
        .READ_RANDOM_WAIT       (1),
        .C_S_AXI_DATA_WIDTH     (C_AXI_DATA_WIDTH),
        .READ_DATA_IS_INCREMENT (0),
        .C_OFFSET_WIDTH         (C_OFFSET_WIDTH),
        .ARREADY_IS_USUALLY_HIGH(1)
    )
    axi_slave_bfm_data
    (
        // クロック
        .ACLK           (ACLK),
        .ARESETN        (ARESETN),

        // AWチャンネル
        .S_AXI_AWID     (M_DATA_AXI_AWID),
        .S_AXI_AWADDR   (M_DATA_AXI_AWADDR),
        .S_AXI_AWLEN    (M_DATA_AXI_AWLEN),
        .S_AXI_AWSIZE   (M_DATA_AXI_AWSIZE),
        .S_AXI_AWBURST  (M_DATA_AXI_AWBURST),
        .S_AXI_AWLOCK   (M_DATA_AXI_AWLOCK),
        .S_AXI_AWCACHE  (M_DATA_AXI_AWCACHE),
        .S_AXI_AWPROT   (M_DATA_AXI_AWPROT),
        .S_AXI_AWQOS    (M_DATA_AXI_AWQOS),
        .S_AXI_AWUSER   (M_DATA_AXI_AWUSER),
        .S_AXI_AWVALID  (M_DATA_AXI_AWVALID),
        .S_AXI_AWREADY  (M_DATA_AXI_AWREADY),

        // Wチャンネル
        .S_AXI_WDATA    (M_DATA_AXI_WDATA),
        .S_AXI_WSTRB    (M_DATA_AXI_WSTRB),
        .S_AXI_WLAST    (M_DATA_AXI_WLAST),
        .S_AXI_WUSER    (M_DATA_AXI_WUSER),
        .S_AXI_WVALID   (M_DATA_AXI_WVALID),
        .S_AXI_WREADY   (M_DATA_AXI_WREADY),

        // Bチャンネル
        // Slave Interface Write Response
        .S_AXI_BID      (M_DATA_AXI_BID),
        .S_AXI_BRESP    (M_DATA_AXI_BRESP),
        .S_AXI_BUSER    (M_DATA_AXI_BUSER),
        .S_AXI_BVALID   (M_DATA_AXI_BVALID),
        .S_AXI_BREADY   (M_DATA_AXI_BREADY),

        // ARチャンネル
        .S_AXI_ARID     (M_DATA_AXI_ARID),
        .S_AXI_ARADDR   (M_DATA_AXI_ARADDR),
        .S_AXI_ARLEN    (M_DATA_AXI_ARLEN),
        .S_AXI_ARSIZE   (M_DATA_AXI_ARSIZE),
        .S_AXI_ARBURST  (M_DATA_AXI_ARBURST),
        .S_AXI_ARLOCK   (M_DATA_AXI_ARLOCK),
        .S_AXI_ARCACHE  (M_DATA_AXI_ARCACHE),
        .S_AXI_ARPROT   (M_DATA_AXI_ARPROT),
        .S_AXI_ARQOS    (M_DATA_AXI_ARQOS),
        .S_AXI_ARUSER   (M_DATA_AXI_ARUSER),
        .S_AXI_ARVALID  (M_DATA_AXI_ARVALID),
        .S_AXI_ARREADY  (M_DATA_AXI_ARREADY),

        // Rチャンネル
        .S_AXI_RID      (M_DATA_AXI_RID),
        .S_AXI_RDATA    (M_DATA_AXI_RDATA),
        .S_AXI_RRESP    (M_DATA_AXI_RRESP),
        .S_AXI_RLAST    (M_DATA_AXI_RLAST),
        .S_AXI_RUSER    (M_DATA_AXI_RUSER),
        .S_AXI_RVALID   (M_DATA_AXI_RVALID),
        .S_AXI_RREADY   (M_DATA_AXI_RREADY)
);
