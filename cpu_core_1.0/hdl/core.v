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
        /* ----- AXI�o�X�p�N���b�N ----- */
        input wire          ACLK,
        input wire          ARESETN,

        /* ----- AXI�o�X�M��(���ߗp) ----- */
        // AW�`�����l��
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

        // W�`�����l��
        output wire [C_M_AXI_DATA_WIDTH-1:0]        M_INST_AXI_WDATA,
        output wire [C_M_AXI_DATA_WIDTH/8-1:0]      M_INST_AXI_WSTRB,
        output wire                                 M_INST_AXI_WLAST,
        output wire [C_M_AXI_WUSER_WIDTH-1:0]       M_INST_AXI_WUSER,
        output wire                                 M_INST_AXI_WVALID,
        input  wire                                 M_INST_AXI_WREADY,

        // B�`�����l��
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_INST_AXI_BID,
        input  wire [2-1:0]                         M_INST_AXI_BRESP,
        input  wire [C_M_AXI_BUSER_WIDTH-1:0]       M_INST_AXI_BUSER,
        input  wire                                 M_INST_AXI_BVALID,
        output wire                                 M_INST_AXI_BREADY,

        // AR�`�����l��
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

        // R�`�����l��
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_INST_AXI_RID,
        input  wire [C_M_AXI_DATA_WIDTH-1:0]        M_INST_AXI_RDATA,
        input  wire [2-1:0]                         M_INST_AXI_RRESP,
        input  wire                                 M_INST_AXI_RLAST,
        input  wire [C_M_AXI_RUSER_WIDTH-1:0]       M_INST_AXI_RUSER,
        input  wire                                 M_INST_AXI_RVALID,
        output wire                                 M_INST_AXI_RREADY,

        /* ----- AXI�o�X�M��(�f�[�^�p) ----- */
        // AW�`�����l��
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

        // W�`�����l��
        output wire [C_M_AXI_DATA_WIDTH-1:0]        M_DATA_AXI_WDATA,
        output wire [C_M_AXI_DATA_WIDTH/8-1:0]      M_DATA_AXI_WSTRB,
        output wire                                 M_DATA_AXI_WLAST,
        output wire [C_M_AXI_WUSER_WIDTH-1:0]       M_DATA_AXI_WUSER,
        output wire                                 M_DATA_AXI_WVALID,
        input  wire                                 M_DATA_AXI_WREADY,

        // B�`�����l��
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_DATA_AXI_BID,
        input  wire [2-1:0]                         M_DATA_AXI_BRESP,
        input  wire [C_M_AXI_BUSER_WIDTH-1:0]       M_DATA_AXI_BUSER,
        input  wire                                 M_DATA_AXI_BVALID,
        output wire                                 M_DATA_AXI_BREADY,

        // AR�`�����l��
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

        // R�`�����l��
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_DATA_AXI_RID,
        input  wire [C_M_AXI_DATA_WIDTH-1:0]        M_DATA_AXI_RDATA,
        input  wire [2-1:0]                         M_DATA_AXI_RRESP,
        input  wire                                 M_DATA_AXI_RLAST,
        input  wire [C_M_AXI_RUSER_WIDTH-1:0]       M_DATA_AXI_RUSER,
        input  wire                                 M_DATA_AXI_RVALID,
        output wire                                 M_DATA_AXI_RREADY,

        /*----- CPU����M�� ----- */
        // �N���b�N
        input wire          CCLK,
        input wire          CRST,
        input wire          CEXEC,

        // CPU���
        output wire [7:0]   STAT,

        // �f�o�b�O�p
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
        output wire [31:0]  REGPC
    );

    /* ----- AXI�o�X�ݒ�(���ߗp) ----- */
    // AW�`�����l��
    assign M_INST_AXI_AWID      = 'b0;
    assign M_INST_AXI_AWADDR    = 32'b0;   // *
    assign M_INST_AXI_AWLEN     = 8'b0;    // *
    assign M_INST_AXI_AWSIZE    = 3'b010;
    assign M_INST_AXI_AWBURST   = 2'b01;
    assign M_INST_AXI_AWLOCK    = 2'b00;
    assign M_INST_AXI_AWCACHE   = 4'b0011;
    assign M_INST_AXI_AWPROT    = 3'h0;
    assign M_INST_AXI_AWQOS     = 4'h0;
    assign M_INST_AXI_AWUSER    = 'b0;
    assign M_INST_AXI_AWVALID   = 1'b0;    // *

    // W�`�����l��
    assign M_INST_AXI_WDATA     = 32'b0;   // *
    assign M_INST_AXI_WSTRB     = 4'b1111;
    assign M_INST_AXI_WLAST     = 1'b0;    // *
    assign M_INST_AXI_WUSER     = 'b0;
    assign M_INST_AXI_WVALID    = 1'b0;     // *

    // B�`�����l��
    assign M_INST_AXI_BREADY    = 1'b0;     // *

    // AR�`�����l��
    assign M_INST_AXI_ARID      = 'b0;
    assign M_INST_AXI_ARADDR    = 32'b0;   // *
    assign M_INST_AXI_ARLEN     = 8'b0;    // *
    assign M_INST_AXI_ARSIZE    = 3'b010;
    assign M_INST_AXI_ARBURST   = 2'b01;
    assign M_INST_AXI_ARLOCK    = 1'b0;
    assign M_INST_AXI_ARCACHE   = 4'b0011;
    assign M_INST_AXI_ARPROT    = 3'h0;
    assign M_INST_AXI_ARQOS     = 4'h0;
    assign M_INST_AXI_ARUSER    = 'b0;
    assign M_INST_AXI_ARVALID   = 1'b0;    // *

    // R�`�����l��
    assign M_INST_AXI_RREADY    = 1'b0;    // *

    /* ----- AXI�o�X�ݒ�(�f�[�^�p) ----- */
    // AW�`�����l��
    assign M_DATA_AXI_AWID      = 'b0;
    assign M_DATA_AXI_AWADDR    = 32'b0;   // *
    assign M_DATA_AXI_AWLEN     = 8'b0;    // *
    assign M_DATA_AXI_AWSIZE    = 3'b010;
    assign M_DATA_AXI_AWBURST   = 2'b01;
    assign M_DATA_AXI_AWLOCK    = 2'b00;
    assign M_DATA_AXI_AWCACHE   = 4'b0011;
    assign M_DATA_AXI_AWPROT    = 3'h0;
    assign M_DATA_AXI_AWQOS     = 4'h0;
    assign M_DATA_AXI_AWUSER    = 'b0;
    assign M_DATA_AXI_AWVALID   = 1'b0;    // *

    // W�`�����l��
    assign M_DATA_AXI_WDATA     = 32'b0;   // *
    assign M_DATA_AXI_WSTRB     = 4'b1111;
    assign M_DATA_AXI_WLAST     = 1'b0;    // *
    assign M_DATA_AXI_WUSER     = 'b0;
    assign M_DATA_AXI_WVALID    = 1'b0;     // *

    // B�`�����l��
    assign M_DATA_AXI_BREADY    = 1'b0;     // *

    // AR�`�����l��
    assign M_DATA_AXI_ARID      = 'b0;
    assign M_DATA_AXI_ARADDR    = 32'b0;   // *
    assign M_DATA_AXI_ARLEN     = 8'b0;    // *
    assign M_DATA_AXI_ARSIZE    = 3'b010;
    assign M_DATA_AXI_ARBURST   = 2'b01;
    assign M_DATA_AXI_ARLOCK    = 1'b0;
    assign M_DATA_AXI_ARCACHE   = 4'b0011;
    assign M_DATA_AXI_ARPROT    = 3'h0;
    assign M_DATA_AXI_ARQOS     = 4'h0;
    assign M_DATA_AXI_ARUSER    = 'b0;
    assign M_DATA_AXI_ARVALID   = 1'b0;    // *

    // R�`�����l��
    assign M_DATA_AXI_RREADY    = 1'b0;    // *

    /* ----- CPU��� ----- */
    assign STAT = 8'b10101010;

    /* ----- �f�o�b�O�p ----- */
    assign REG00    = 32'b0;
    assign REG01    = 32'b0;
    assign REG02    = 32'b0;
    assign REG03    = 32'b0;
    assign REG04    = 32'b0;
    assign REG05    = 32'b0;
    assign REG06    = 32'b0;
    assign REG07    = 32'b0;
    assign REG08    = 32'b0;
    assign REG09    = 32'b0;
    assign REG10    = 32'b0;
    assign REG11    = 32'b0;
    assign REG12    = 32'b0;
    assign REG13    = 32'b0;
    assign REG14    = 32'b0;
    assign REG15    = 32'b0;
    assign REG16    = 32'b0;
    assign REG17    = 32'b0;
    assign REG18    = 32'b0;
    assign REG19    = 32'b0;
    assign REG20    = 32'b0;
    assign REG21    = 32'b0;
    assign REG22    = 32'b0;
    assign REG23    = 32'b0;
    assign REG24    = 32'b0;
    assign REG25    = 32'b0;
    assign REG26    = 32'b0;
    assign REG27    = 32'b0;
    assign REG28    = 32'b0;
    assign REG29    = 32'b0;
    assign REG30    = 32'b0;
    assign REG31    = 32'b0;
    assign REGPC    = 32'b0;

endmodule