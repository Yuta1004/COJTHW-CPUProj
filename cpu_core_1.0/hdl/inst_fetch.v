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
        /* ----- AXI�o�X�p�N���b�N ----- */
        input wire          ACLK,
        input wire          ARST,

        /* ----- AXI�o�X�M�� ----- */
        // AW�`�����l��
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

        // W�`�����l��
        output wire [C_M_AXI_DATA_WIDTH-1:0]        M_AXI_WDATA,
        output wire [C_M_AXI_DATA_WIDTH/8-1:0]      M_AXI_WSTRB,
        output wire                                 M_AXI_WLAST,
        output wire [C_M_AXI_WUSER_WIDTH-1:0]       M_AXI_WUSER,
        output wire                                 M_AXI_WVALID,
        input  wire                                 M_AXI_WREADY,

        // B�`�����l��
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_BID,
        input  wire [2-1:0]                         M_AXI_BRESP,
        input  wire [C_M_AXI_BUSER_WIDTH-1:0]       M_AXI_BUSER,
        input  wire                                 M_AXI_BVALID,
        output wire                                 M_AXI_BREADY,

        // AR�`�����l��
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

        // R�`�����l��
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_RID,
        input  wire [C_M_AXI_DATA_WIDTH-1:0]        M_AXI_RDATA,
        input  wire [2-1:0]                         M_AXI_RRESP,
        input  wire                                 M_AXI_RLAST,
        input  wire [C_M_AXI_RUSER_WIDTH-1:0]       M_AXI_RUSER,
        input  wire                                 M_AXI_RVALID,
        output wire                                 M_AXI_RREADY,

        /* ----- �N���b�N&���Z�b�g(CCLK�n) ----- */
        input wire          CCLK,
        input wire          CRST,

        /* ----- ��ʂƂ̐ڑ��p ----- */
        input wire          PC_VALID,
        input wire [31:0]   PC,

        output reg          INST_VALID,
        output reg [31:0]   INST,
        output reg          MEM_WAIT
    );

    /* ----- AXI�o�X�ݒ� ----- */
    // AW�`�����l��
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

    // W�`�����l��
    assign M_AXI_WDATA      = 32'b0;
    assign M_AXI_WSTRB      = 4'b1111;
    assign M_AXI_WLAST      = 1'b0;
    assign M_AXI_WUSER      = 'b0;
    assign M_AXI_WVALID     = 1'b0;

    // B�`�����l��
    assign M_AXI_BREADY     = 1'b0;

    // AR�`�����l��
    assign M_AXI_ARID       = 'b0;
    assign M_AXI_ARLEN      = 8'h1f;
    assign M_AXI_ARSIZE     = 3'b010;
    assign M_AXI_ARBURST    = 2'b01;
    assign M_AXI_ARLOCK     = 1'b0;
    assign M_AXI_ARCACHE    = 4'b0011;
    assign M_AXI_ARPROT     = 3'h0;
    assign M_AXI_ARQOS      = 4'h0;
    assign M_AXI_ARUSER     = 'b0;

    // R�`�����l��
    assign M_AXI_RREADY     = 1'b1;

    /* ----- �y�[�W���݊m�F ----- */
    reg [19:0]  loaded_page_addr;

    wire loaded = loaded_page_addr == PC[31:12];

    always @ (posedge CCLK) begin
        if (CRST)
            loaded_page_addr <= 20'b1111_1111_1111_1111_1111;
        else if (dram_access_finished)
            loaded_page_addr <= PC[31:12];
    end

    /* ----- ���ߏo�� ----- */
    always @ (posedge CCLK) begin
        if (CRST)
            INST_VALID <= 1'b0;
        else
            INST_VALID <= PC_VALID && loaded;
    end

    always @ (posedge CCLK) begin
        if (CRST)
            INST <= 32'b0;
        else if (PC_VALID && loaded)
            INST <= PC;
        else
            INST <= 32'b0;
    end

    always @ (posedge CCLK) begin
        if (CRST)
            MEM_WAIT <= 1'b0;
        else if (PC_VALID && !loaded)
            MEM_WAIT <= 1'b1;
        else if (dram_access_finished)
            MEM_WAIT <= 1'b0;
    end

    /* ----- DRAM�A�N�Z�X�`�F�b�N�p�M��(ACLK�œ�����) ----- */
    reg  [31:0] cache_pc [0:1];
    reg  [1:0]  cache_pc_valid_and_loaded;

    wire [31:0] draw_startaddr = { cache_pc[1][31:12], 12'b0 };
    wire        do_access_dram = cache_pc_valid_and_loaded[1];

    always @ (posedge ACLK) begin
        cache_pc[0] <= PC;
        cache_pc[1] <= cache_pc[0];
        cache_pc_valid_and_loaded <= { cache_pc_valid_and_loaded[0], PC_VALID && !loaded };
    end

    /* ----- DRAM�A�N�Z�X��ԋ��L(ACLK & CCLK) ----- */
    reg dram_access_finished;

    always @ (posedge ACLK) begin
        if (ARST)
            dram_access_finished <= 1'b0;
        else if (M_AXI_RVALID && M_AXI_RLAST && M_AXI_ARADDR[11:0] == 12'b0)
            dram_access_finished <= 1'b1;
        else if (dram_access_finished && !MEM_WAIT)
            dram_access_finished <= 1'b0;
    end

    /* ----- DRAM�A�N�Z�X(AR&R)�p�X�e�[�g�}�V�� ----- */
    parameter S_AR_IDLE = 2'b00;
    parameter S_AR_ADDR = 2'b01;
    parameter S_AR_WAIT = 2'b11;

    reg [1:0] ar_state, ar_next_state;

    always @ (posedge ACLK) begin
        if (ARST)
            ar_state <= S_AR_IDLE;
        else
            ar_state <= ar_next_state;
    end

    always @* begin
        case (ar_state)
            S_AR_IDLE:
                if (do_access_dram)
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

    always @ (posedge ACLK) begin
        if (ARST)
            M_AXI_ARADDR <= 32'h2000_0000;
        else if (ar_state == S_AR_IDLE && ar_next_state == S_AR_ADDR)
            M_AXI_ARADDR <= draw_startaddr;
        else if (ar_state == S_AR_ADDR && M_AXI_ARREADY)
            M_AXI_ARADDR <= M_AXI_ARADDR + 32'd128;
    end

    always @ (posedge ACLK) begin
        if (ARST)
            M_AXI_ARVALID <= 1'b0;
        else if (ar_next_state == S_AR_ADDR)
            M_AXI_ARVALID <= 1'b1;
        else if (ar_state == S_AR_ADDR && M_AXI_ARREADY)
            M_AXI_ARVALID <= 1'b0;
    end

    always @ (posedge ACLK) begin
        // RDATA
    end

    always @ (posedge ACLK) begin
        // RVALID
    end

endmodule