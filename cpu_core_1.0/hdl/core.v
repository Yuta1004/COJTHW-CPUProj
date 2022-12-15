//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I)
// Project     : cpu_proj
// Filename    : core.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/07  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module core #
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
        /* ----- クロック&リセット信号 ----- */
        input wire CLK,
        input wire RST,

        /*----- CPU制御信号 ----- */
        // CPU状態
        input wire          EXEC,
        output wire [3:0]   STAT,

        // デバッグ用
        output wire [31:0]  REG00,
        output wire [31:0]  REG01,
        output wire [31:0]  REG02,
        output wire [31:0]  REG03,
        output wire [31:0]  REG04,
        output wire [31:0]  REG05,
        output wire [31:0]  REG06,
        output wire [31:0]  REG07,
        output wire [31:0]  REG08,
        output wire [31:0]  REG09,
        output wire [31:0]  REG10,
        output wire [31:0]  REG11,
        output wire [31:0]  REG12,
        output wire [31:0]  REG13,
        output wire [31:0]  REG14,
        output wire [31:0]  REG15,
        output wire [31:0]  REG16,
        output wire [31:0]  REG17,
        output wire [31:0]  REG18,
        output wire [31:0]  REG19,
        output wire [31:0]  REG20,
        output wire [31:0]  REG21,
        output wire [31:0]  REG22,
        output wire [31:0]  REG23,
        output wire [31:0]  REG24,
        output wire [31:0]  REG25,
        output wire [31:0]  REG26,
        output wire [31:0]  REG27,
        output wire [31:0]  REG28,
        output wire [31:0]  REG29,
        output wire [31:0]  REG30,
        output wire [31:0]  REG31,
        output wire [31:0]  REGPC,

        /* ----- AXIバス信号(命令用) ----- */
        // AWチャンネル
        output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_INST_AXI_AWID,
        output wire [C_M_AXI_ADDR_WIDTH-1:0]        M_INST_AXI_AWADDR,
        output wire [8-1:0]                         M_INST_AXI_AWLEN,
        output wire [3-1:0]                         M_INST_AXI_AWSIZE,
        output wire [2-1:0]                         M_INST_AXI_AWBURST,
        output wire [2-1:0]                         M_INST_AXI_AWLOCK,
        output wire [4-1:0]                         M_INST_AXI_AWCACHE,
        output wire [3-1:0]                         M_INST_AXI_AWPROT,
        output wire [4-1:0]                         M_INST_AXI_AWQOS,
        output wire [C_M_AXI_AWUSER_WIDTH-1:0]      M_INST_AXI_AWUSER,
        output wire                                 M_INST_AXI_AWVALID,
        input  wire                                 M_INST_AXI_AWREADY,

        // Wチャンネル
        output wire [C_M_AXI_DATA_WIDTH-1:0]        M_INST_AXI_WDATA,
        output wire [C_M_AXI_DATA_WIDTH/8-1:0]      M_INST_AXI_WSTRB,
        output wire                                 M_INST_AXI_WLAST,
        output wire [C_M_AXI_WUSER_WIDTH-1:0]       M_INST_AXI_WUSER,
        output wire                                 M_INST_AXI_WVALID,
        input  wire                                 M_INST_AXI_WREADY,

        // Bチャンネル
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_INST_AXI_BID,
        input  wire [2-1:0]                         M_INST_AXI_BRESP,
        input  wire [C_M_AXI_BUSER_WIDTH-1:0]       M_INST_AXI_BUSER,
        input  wire                                 M_INST_AXI_BVALID,
        output wire                                 M_INST_AXI_BREADY,

        // ARチャンネル
        output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_INST_AXI_ARID,
        output wire [C_M_AXI_ADDR_WIDTH-1:0]        M_INST_AXI_ARADDR,
        output wire [8-1:0]                         M_INST_AXI_ARLEN,
        output wire [3-1:0]                         M_INST_AXI_ARSIZE,
        output wire [2-1:0]                         M_INST_AXI_ARBURST,
        output wire [2-1:0]                         M_INST_AXI_ARLOCK,
        output wire [4-1:0]                         M_INST_AXI_ARCACHE,
        output wire [3-1:0]                         M_INST_AXI_ARPROT,
        output wire [4-1:0]                         M_INST_AXI_ARQOS,
        output wire [C_M_AXI_ARUSER_WIDTH-1:0]      M_INST_AXI_ARUSER,
        output wire                                 M_INST_AXI_ARVALID,
        input  wire                                 M_INST_AXI_ARREADY,

        // Rチャンネル
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_INST_AXI_RID,
        input  wire [C_M_AXI_DATA_WIDTH-1:0]        M_INST_AXI_RDATA,
        input  wire [2-1:0]                         M_INST_AXI_RRESP,
        input  wire                                 M_INST_AXI_RLAST,
        input  wire [C_M_AXI_RUSER_WIDTH-1:0]       M_INST_AXI_RUSER,
        input  wire                                 M_INST_AXI_RVALID,
        output wire                                 M_INST_AXI_RREADY,

        /* ----- AXIバス信号(データ用) ----- */
        // AWチャンネル
        output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_DATA_AXI_AWID,
        output wire [C_M_AXI_ADDR_WIDTH-1:0]        M_DATA_AXI_AWADDR,
        output wire [8-1:0]                         M_DATA_AXI_AWLEN,
        output wire [3-1:0]                         M_DATA_AXI_AWSIZE,
        output wire [2-1:0]                         M_DATA_AXI_AWBURST,
        output wire [2-1:0]                         M_DATA_AXI_AWLOCK,
        output wire [4-1:0]                         M_DATA_AXI_AWCACHE,
        output wire [3-1:0]                         M_DATA_AXI_AWPROT,
        output wire [4-1:0]                         M_DATA_AXI_AWQOS,
        output wire [C_M_AXI_AWUSER_WIDTH-1:0]      M_DATA_AXI_AWUSER,
        output wire                                 M_DATA_AXI_AWVALID,
        input  wire                                 M_DATA_AXI_AWREADY,

        // Wチャンネル
        output wire [C_M_AXI_DATA_WIDTH-1:0]        M_DATA_AXI_WDATA,
        output wire [C_M_AXI_DATA_WIDTH/8-1:0]      M_DATA_AXI_WSTRB,
        output wire                                 M_DATA_AXI_WLAST,
        output wire [C_M_AXI_WUSER_WIDTH-1:0]       M_DATA_AXI_WUSER,
        output wire                                 M_DATA_AXI_WVALID,
        input  wire                                 M_DATA_AXI_WREADY,

        // Bチャンネル
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_DATA_AXI_BID,
        input  wire [2-1:0]                         M_DATA_AXI_BRESP,
        input  wire [C_M_AXI_BUSER_WIDTH-1:0]       M_DATA_AXI_BUSER,
        input  wire                                 M_DATA_AXI_BVALID,
        output wire                                 M_DATA_AXI_BREADY,

        // ARチャンネル
        output wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_DATA_AXI_ARID,
        output wire [C_M_AXI_ADDR_WIDTH-1:0]        M_DATA_AXI_ARADDR,
        output wire [8-1:0]                         M_DATA_AXI_ARLEN,
        output wire [3-1:0]                         M_DATA_AXI_ARSIZE,
        output wire [2-1:0]                         M_DATA_AXI_ARBURST,
        output wire [2-1:0]                         M_DATA_AXI_ARLOCK,
        output wire [4-1:0]                         M_DATA_AXI_ARCACHE,
        output wire [3-1:0]                         M_DATA_AXI_ARPROT,
        output wire [4-1:0]                         M_DATA_AXI_ARQOS,
        output wire [C_M_AXI_ARUSER_WIDTH-1:0]      M_DATA_AXI_ARUSER,
        output wire                                 M_DATA_AXI_ARVALID,
        input  wire                                 M_DATA_AXI_ARREADY,

        // Rチャンネル
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_DATA_AXI_RID,
        input  wire [C_M_AXI_DATA_WIDTH-1:0]        M_DATA_AXI_RDATA,
        input  wire [2-1:0]                         M_DATA_AXI_RRESP,
        input  wire                                 M_DATA_AXI_RLAST,
        input  wire [C_M_AXI_RUSER_WIDTH-1:0]       M_DATA_AXI_RUSER,
        input  wire                                 M_DATA_AXI_RVALID,
        output wire                                 M_DATA_AXI_RREADY
    );

    /* ----- AXIバス設定(命令用) ----- */
    // AWチャンネル
    assign M_INST_AXI_AWID       = 'b0;
    assign M_INST_AXI_AWADDR     = 32'b0;
    assign M_INST_AXI_AWLEN      = 8'b0;
    assign M_INST_AXI_AWSIZE     = 3'b010;
    assign M_INST_AXI_AWBURST    = 2'b01;
    assign M_INST_AXI_AWLOCK     = 2'b00;
    assign M_INST_AXI_AWCACHE    = 4'b0011;
    assign M_INST_AXI_AWPROT     = 3'h0;
    assign M_INST_AXI_AWQOS      = 4'h0;
    assign M_INST_AXI_AWUSER     = 'b0;
    assign M_INST_AXI_AWVALID    = 1'b0;

    // Wチャンネル
    assign M_INST_AXI_WDATA      = 32'b0;
    assign M_INST_AXI_WSTRB      = 4'b1111;
    assign M_INST_AXI_WLAST      = 1'b0;
    assign M_INST_AXI_WUSER      = 'b0;
    assign M_INST_AXI_WVALID     = 1'b0;

    // Bチャンネル
    assign M_INST_AXI_BREADY     = 1'b0;

    /* ----- CPU状態 ----- */
    assign STAT = {
        stall,
        inst_mem_wait,
        data_mem_wait,
        flush
    };

    /* ----- 全体制御 ----- */
    wire        inst_mem_wait, do_jmp;
    wire [31:0] new_pc;

    wire stall = inst_mem_wait | data_mem_wait;
    wire flush = do_jmp;

    /* ------ プログラムカウンタ ----- */
    wire [31:0] p_pc;
    wire        p_valid;

    pc pc (
        .CLK    (CLK),
        .RST    (RST),

        .STALL  (stall),
        .FLUSH  (flush),
        .NEW_PC (new_pc),

        .EXEC   (EXEC),

        .P_PC   (p_pc),
        .P_VALID(p_valid)
    );

    /* ----- 命令フェッチ部 ----- */
    wire [31:0] i_pc, i_inst;
    wire        i_valid;

    inst_fetch # (
        .C_M_AXI_THREAD_ID_WIDTH(C_M_AXI_THREAD_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH     (C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH     (C_M_AXI_DATA_WIDTH),
        .C_M_AXI_ARUSER_WIDTH   (C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH    (C_M_AXI_RUSER_WIDTH)
    ) inst_fetch (
        .CLK            (CLK),
        .RST            (RST),

        .STALL          (stall),
        .FLUSH          (flush),
        .MEM_WAIT       (inst_mem_wait),

        .P_PC           (p_pc),
        .P_VALID        (p_valid),

        .I_PC           (i_pc),
        .I_INST         (i_inst),
        .I_VALID        (i_valid),

        .M_AXI_ARID     (M_INST_AXI_ARID),
        .M_AXI_ARADDR   (M_INST_AXI_ARADDR),
        .M_AXI_ARLEN    (M_INST_AXI_ARLEN),
        .M_AXI_ARSIZE   (M_INST_AXI_ARSIZE),
        .M_AXI_ARBURST  (M_INST_AXI_ARBURST),
        .M_AXI_ARLOCK   (M_INST_AXI_ARLOCK),
        .M_AXI_ARCACHE  (M_INST_AXI_ARCACHE),
        .M_AXI_ARPROT   (M_INST_AXI_ARPROT),
        .M_AXI_ARQOS    (M_INST_AXI_ARQOS),
        .M_AXI_ARUSER   (M_INST_AXI_ARUSER),
        .M_AXI_ARVALID  (M_INST_AXI_ARVALID),
        .M_AXI_ARREADY  (M_INST_AXI_ARREADY),
        .M_AXI_RID      (M_INST_AXI_RID),
        .M_AXI_RDATA    (M_INST_AXI_RDATA),
        .M_AXI_RRESP    (M_INST_AXI_RRESP),
        .M_AXI_RLAST    (M_INST_AXI_RLAST),
        .M_AXI_RUSER    (M_INST_AXI_RUSER),
        .M_AXI_RVALID   (M_INST_AXI_RVALID),
        .M_AXI_RREADY   (M_INST_AXI_RREADY)
    );

    /* ----- デコード部 ----- */
    wire [31:0] d_pc, d_inst, d_imm;
    wire        d_valid;
    wire [6:0]  d_opcode;
    wire [2:0]  d_funct3;
    wire [6:0]  d_funct7;
    wire [4:0]  d_reg_d, d_reg_s1, d_reg_s2;
    wire [31:0] d_reg_s1_v, d_reg_s2_v;

    decode decode (
        .CLK        (CLK),
        .RST        (RST),

        .STALL      (stall),
        .FLUSH      (flush),

        .I_PC       (i_pc),
        .I_INST     (i_inst),
        .I_VALID    (i_valid),

        .D_PC       (d_pc),
        .D_INST     (d_inst),
        .D_VALID    (d_valid),
        .D_OPCODE   (d_opcode),
        .D_FUNCT3   (d_funct3),
        .D_FUNCT7   (d_funct7),
        .D_IMM      (d_imm),
        .D_REG_D    (d_reg_d),
        .D_REG_S1   (d_reg_s1),
        .D_REG_S2   (d_reg_s2)
    );

    /* ----- ALU ----- */
    wire [31:0] a_pc, a_inst;
    wire        a_valid;
    wire        a_do_jmp;
    wire [31:0] a_new_pc;
    wire [4:0]  a_reg_d;
    wire [31:0] a_reg_d_v;
    wire        a_load_rden, a_load_signed;
    wire [31:0] a_load_addr;
    wire [1:0]  a_load_size;
    wire        a_store_wren;
    wire [31:0] a_store_addr, a_store_data;
    wire [3:0]  a_store_strb;

    alu alu (
        .CLK            (CLK),
        .RST            (RST),

        .STALL          (stall),
        .FLUSH          (flush),

        .D_PC           (d_pc),
        .D_INST         (d_inst),
        .D_VALID        (d_valid),
        .D_OPCODE       (d_opcode),
        .D_FUNCT3       (d_funct3),
        .D_FUNCT7       (d_funct7),
        .D_IMM          (d_imm),
        .D_REG_D        (d_reg_d),
        .D_REG_S1       (d_reg_s1),
        .D_REG_S1_V     (d_reg_s1_v),
        .D_REG_S2       (d_reg_s2),
        .D_REG_S2_V     (d_reg_s2_v),

        .FWD_M_VALID    (m_valid),
        .FWD_M_REG_D    (m_reg_d),
        .FWD_M_REG_D_V  (m_reg_d_v),
        .FWD_W_VALID    (w_valid),
        .FWD_W_REG_D    (w_reg_d),
        .FWD_W_REG_D_V  (w_reg_d_v),

        .A_PC           (a_pc),
        .A_INST         (a_inst),
        .A_VALID        (a_valid),
        .A_DO_JMP       (a_do_jmp),
        .A_NEW_PC       (a_new_pc),
        .A_REG_D        (a_reg_d),
        .A_REG_D_V      (a_reg_d_v),
        .A_LOAD_RDEN    (a_load_rden),
        .A_LOAD_ADDR    (a_load_addr),
        .A_LOAD_SIZE    (a_load_size),
        .A_LOAD_SIGNED  (a_load_signed),
        .A_STORE_WREN   (a_store_wren),
        .A_STORE_ADDR   (a_store_addr),
        .A_STORE_STRB   (a_store_strb),
        .A_STORE_DATA   (a_store_data)
    );

    /* ----- メモリアクセス(読み)部 ---- */
    wire [31:0] m_pc, m_inst;
    wire        m_valid;
    wire [4:0]  m_reg_d;
    wire [31:0] m_reg_d_v;
    wire        m_store_wren;
    wire [31:0] m_store_addr, m_store_data;
    wire [3:0]  m_store_strb;

    mem_rd mem_rd (
        .CLK            (CLK),
        .RST            (RST),

        .STALL          (stall),
        .FLUSH          (flush),
        .DO_JMP         (do_jmp),
        .NEW_PC         (new_pc),

        .A_PC           (a_pc),
        .A_INST         (a_inst),
        .A_VALID        (a_valid),
        .A_DO_JMP       (a_do_jmp),
        .A_NEW_PC       (a_new_pc),
        .A_REG_D        (a_reg_d),
        .A_REG_D_V      (a_reg_d_v),
        .A_STORE_WREN   (a_store_wren),
        .A_STORE_ADDR   (a_store_addr),
        .A_STORE_STRB   (a_store_strb),
        .A_STORE_DATA   (a_store_data),

        .DATA_RDVALID   (data_rdvalid),
        .DATA_RDDATA    (data_rddata),

        .M_PC           (m_pc),
        .M_INST         (m_inst),
        .M_VALID        (m_valid),
        .M_REG_D        (m_reg_d),
        .M_REG_D_V      (m_reg_d_v),
        .M_STORE_WREN   (m_store_wren),
        .M_STORE_ADDR   (m_store_addr),
        .M_STORE_STRB   (m_store_strb),
        .M_STORE_DATA   (m_store_data)
    );

    /* ----- メモリ・レジスタアクセス(書き)部 ----- */
    wire [31:0] w_pc, w_inst;
    wire        w_valid;
    wire [4:0]  w_reg_d;
    wire [31:0] w_reg_d_v;
    wire        w_store_wren;
    wire [31:0] w_store_addr, w_store_data;
    wire [3:0]  w_store_strb;

    wb wb (
        .CLK            (CLK),
        .RST            (RST),

        .STALL          (stall),
        .FLUSH          (flush),

        .M_PC           (m_pc),
        .M_INST         (m_inst),
        .M_VALID        (m_valid),
        .M_REG_D        (m_reg_d),
        .M_REG_D_V      (m_reg_d_v),
        .M_STORE_WREN   (m_store_wren),
        .M_STORE_ADDR   (m_store_addr),
        .M_STORE_STRB   (m_store_strb),
        .M_STORE_DATA   (m_store_data),

        .W_PC           (w_pc),
        .W_INST         (w_inst),
        .W_VALID        (w_valid),
        .W_REG_D        (w_reg_d),
        .W_REG_D_V      (w_reg_d_v),
        .W_STORE_WREN   (w_store_wren),
        .W_STORE_ADDR   (w_store_addr),
        .W_STORE_STRB   (w_store_strb),
        .W_STORE_DATA   (w_store_data)
    );

    /* ----- レジスタ ----- */
    register register (
        .CLK        (CLK),
        .RST        (RST),

        .STALL      (stall),
        .FLUSH      (flush),

        .WRVALID    (m_valid),
        .WRADDR     (m_reg_d),
        .WRDATA     (m_reg_d_v),

        .RDADDR_1   (d_reg_s1),
        .RDDATA_1   (d_reg_s1_v),

        .RDADDR_2   (d_reg_s2),
        .RDDATA_2   (d_reg_s2_v),

        .REG01      (REG01),
        .REG02      (REG02),
        .REG03      (REG03),
        .REG04      (REG04),
        .REG05      (REG05),
        .REG06      (REG06),
        .REG07      (REG07),
        .REG08      (REG08),
        .REG09      (REG09),
        .REG10      (REG10),
        .REG11      (REG11),
        .REG12      (REG12),
        .REG13      (REG13),
        .REG14      (REG14),
        .REG15      (REG15),
        .REG16      (REG16),
        .REG17      (REG17),
        .REG18      (REG18),
        .REG19      (REG19),
        .REG20      (REG20),
        .REG21      (REG21),
        .REG22      (REG22),
        .REG23      (REG23),
        .REG24      (REG24),
        .REG25      (REG25),
        .REG26      (REG26),
        .REG27      (REG27),
        .REG28      (REG28),
        .REG29      (REG29),
        .REG30      (REG30),
        .REG31      (REG31)
    );

    /* ----- データ用キャッシュメモリ ----- */
    wire [31:0] data_rddata;
    wire        data_rdvalid;
    wire        data_mem_wait;

    datamem # (
        .C_M_AXI_THREAD_ID_WIDTH(C_M_AXI_THREAD_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH     (C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH     (C_M_AXI_DATA_WIDTH),
        .C_M_AXI_AWUSER_WIDTH   (C_M_AXI_AWUSER_WIDTH),
        .C_M_AXI_ARUSER_WIDTH   (C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_WUSER_WIDTH    (C_M_AXI_WUSER_WIDTH),
        .C_M_AXI_BUSER_WIDTH    (C_M_AXI_BUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH    (C_M_AXI_RUSER_WIDTH)
    ) datamem (
        .CLK            (CLK),
        .RST            (RST),

        .RDEN           (a_load_rden),
        .RDADDR         (a_load_addr),
        .RDSIZE         (a_load_size),
        .RDSIGNED       (a_load_signed),
        .RDDATA         (data_rddata),
        .RDVALID        (data_rdvalid),

        .WREN           (m_store_wren),
        .WRADDR         (m_store_addr),
        .WRSTRB         (m_store_strb),
        .WRDATA         (m_store_data),

        .LOADING        (data_mem_wait),

        .M_AXI_AWID     (M_DATA_AXI_AWID),
        .M_AXI_AWADDR   (M_DATA_AXI_AWADDR),
        .M_AXI_AWLEN    (M_DATA_AXI_AWLEN),
        .M_AXI_AWSIZE   (M_DATA_AXI_AWSIZE),
        .M_AXI_AWBURST  (M_DATA_AXI_AWBURST),
        .M_AXI_AWLOCK   (M_DATA_AXI_AWLOCK),
        .M_AXI_AWCACHE  (M_DATA_AXI_AWCACHE),
        .M_AXI_AWPROT   (M_DATA_AXI_AWPROT),
        .M_AXI_AWQOS    (M_DATA_AXI_AWQOS),
        .M_AXI_AWUSER   (M_DATA_AXI_AWUSER),
        .M_AXI_AWVALID  (M_DATA_AXI_AWVALID),
        .M_AXI_AWREADY  (M_DATA_AXI_AWREADY),
        .M_AXI_WDATA    (M_DATA_AXI_WDATA),
        .M_AXI_WSTRB    (M_DATA_AXI_WSTRB),
        .M_AXI_WLAST    (M_DATA_AXI_WLAST),
        .M_AXI_WUSER    (M_DATA_AXI_WUSER),
        .M_AXI_WVALID   (M_DATA_AXI_WVALID),
        .M_AXI_WREADY   (M_DATA_AXI_WREADY),
        .M_AXI_BID      (M_DATA_AXI_BID),
        .M_AXI_BRESP    (M_DATA_AXI_BRESP),
        .M_AXI_BUSER    (M_DATA_AXI_BUSER),
        .M_AXI_BVALID   (M_DATA_AXI_BVALID),
        .M_AXI_BREADY   (M_DATA_AXI_BREADY),
        .M_AXI_ARID     (M_DATA_AXI_ARID),
        .M_AXI_ARADDR   (M_DATA_AXI_ARADDR),
        .M_AXI_ARLEN    (M_DATA_AXI_ARLEN),
        .M_AXI_ARSIZE   (M_DATA_AXI_ARSIZE),
        .M_AXI_ARBURST  (M_DATA_AXI_ARBURST),
        .M_AXI_ARLOCK   (M_DATA_AXI_ARLOCK),
        .M_AXI_ARCACHE  (M_DATA_AXI_ARCACHE),
        .M_AXI_ARPROT   (M_DATA_AXI_ARPROT),
        .M_AXI_ARQOS    (M_DATA_AXI_ARQOS),
        .M_AXI_ARUSER   (M_DATA_AXI_ARUSER),
        .M_AXI_ARVALID  (M_DATA_AXI_ARVALID),
        .M_AXI_ARREADY  (M_DATA_AXI_ARREADY),
        .M_AXI_RID      (M_DATA_AXI_RID),
        .M_AXI_RDATA    (M_DATA_AXI_RDATA),
        .M_AXI_RRESP    (M_DATA_AXI_RRESP),
        .M_AXI_RLAST    (M_DATA_AXI_RLAST),
        .M_AXI_RUSER    (M_DATA_AXI_RUSER),
        .M_AXI_RVALID   (M_DATA_AXI_RVALID),
        .M_AXI_RREADY   (M_DATA_AXI_RREADY)
    );

    /* ----- デバッグ用 ----- */
    assign REG00 = 32'b0;
    assign REGPC = p_pc;
    // assign REG01    = 32'd1;
    // assign REG02    = 32'd2;
    // assign REG03    = 32'd3;
    // assign REG04    = 32'd4;
    // assign REG05    = 32'd5;
    // assign REG06    = 32'd6;
    // assign REG07    = 32'd7;
    // assign REG08    = 32'd8;
    // assign REG09    = 32'd9;
    // assign REG10    = 32'd10;
    // assign REG11    = 32'd11;
    // assign REG12    = 32'd12;
    // assign REG13    = 32'd13;
    // assign REG14    = 32'd14;
    // assign REG15    = 32'd15;
    // assign REG16    = 32'd16;
    // assign REG17    = 32'd17;
    // assign REG18    = 32'd18;
    // assign REG19    = 32'd19;
    // assign REG20    = 32'd20;
    // assign REG21    = 32'd21;
    // assign REG22    = 32'd22;
    // assign REG23    = 32'd23;
    // assign REG24    = 32'd24;
    // assign REG25    = 32'd25;
    // assign REG26    = 32'd26;
    // assign REG27    = 32'd27;
    // assign REG28    = 32'd28;
    // assign REG29    = 32'd29;
    // assign REG30    = 32'd30;
    // assign REG31    = 32'd31;
    // assign REGPC    = 32'h2000_0000;

endmodule
