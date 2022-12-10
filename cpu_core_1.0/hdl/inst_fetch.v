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
        /* ----- �N���b�N&���Z�b�g�M�� ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- ��ʂƂ̐ڑ��p ----- */
        // ����
        input wire          STALL,
        output wire         MEM_WAIT,

        // ����
        input               EXEC,

        // �o��
        output wire [31:0]  PC,
        output wire         INST_VALID,
        output wire [31:0]  INST,

        /* ----- AXI�o�X�M�� ----- */
        // AR�`�����l��
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

        // R�`�����l��
        input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0]   M_AXI_RID,
        input  wire [C_M_AXI_DATA_WIDTH-1:0]        M_AXI_RDATA,
        input  wire [2-1:0]                         M_AXI_RRESP,
        input  wire                                 M_AXI_RLAST,
        input  wire [C_M_AXI_RUSER_WIDTH-1:0]       M_AXI_RUSER,
        input  wire                                 M_AXI_RVALID,
        output wire                                 M_AXI_RREADY
    );

    /* ----- �v���O�����J�E���^ ----- */
    reg         delayed_exec, pc_valid;
    reg [31:0]  pc;

    always @ (posedge CLK) begin
        delayed_exec <= EXEC;
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
        else if (EXEC && delayed_exec && !STALL)
            pc <= pc + 32'd4;
    end

    /* ----- �L���b�V�������� ----- */
    cachemem_rd # (
        .C_M_AXI_THREAD_ID_WIDTH(C_M_AXI_THREAD_ID_WIDTH),
        .C_M_AXI_ADDR_WIDTH     (C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH     (C_M_AXI_DATA_WIDTH),
        .C_M_AXI_ARUSER_WIDTH   (C_M_AXI_ARUSER_WIDTH),
        .C_M_AXI_RUSER_WIDTH    (C_M_AXI_RUSER_WIDTH)
    ) cachemem_rd (
        .CLK            (CLK),
        .RST            (RST),

        .ADDR           (pc),
        .RDEN           (pc_valid),
        .OADDR          (PC),
        .DOUT           (INST),
        .VALID          (INST_VALID),

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
