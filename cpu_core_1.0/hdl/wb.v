//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I) : Write back
// Project     : cpu_proj
// Filename    : wb.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/10  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module wb
    (
        /* ----- �N���b�N&���Z�b�g�M�� ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- ��ʂƂ̐ڑ��p ----- */
        // ����
        input wire          STALL,
        input wire          FLUSH,

        // ����
        input wire  [31:0]  M_PC,
        input wire  [31:0]  M_INST,
        input wire          M_VALID,
        input wire  [4:0]   M_REG_D,
        input wire  [31:0]  M_REG_D_V,
        // output wire [31:0]  M_LOAD_ADDR,
        // output wire [31:0]  M_LOAD_STRB,
        input wire          M_STORE_WREN,
        input wire  [31:0]  M_STORE_ADDR,
        input wire  [3:0]   M_STORE_STRB,
        input wire  [31:0]  M_STORE_DATA,

        // �o��
        output wire [31:0]  W_PC,
        output wire [31:0]  W_INST,
        output wire         W_VALID,
        output wire [4:0]   W_REG_D,
        output wire [31:0]  W_REG_D_V,
        // output wire [31:0]  W_LOAD_STRB,
        // output wire [31:0]  W_LOAD_DATA,
        output wire         W_STORE_WREN,
        output wire [31:0]  W_STORE_ADDR,
        output wire [3:0]   W_STORE_STRB,
        output wire [31:0]  W_STORE_DATA
    );

    /* ----- ����(���b�`��荞��) ----- */
    reg [31:0]  pc, inst;
    reg         valid;
    reg [4:0]   reg_d;
    reg [31:0]  reg_d_v;
    reg         store_wren;
    reg [31:0]  store_addr, store_data;
    reg [3:0]   store_strb;

    always @ (posedge CLK) begin
        if (RST) begin
            pc <= 32'b0;
            inst <= 32'b0;
            valid <= 1'b0;
            reg_d <= 5'b0;
            reg_d_v <= 5'b0;
            store_wren <= 1'b0;
            store_addr <= 32'b0;
            store_strb <= 4'b0;
            store_data <= 32'b0;
        end
        else if (STALL)
            ;
        else if (FLUSH) begin
            pc <= 32'b0;
            inst <= 32'b0;
            valid <= 1'b0;
            reg_d <= 5'b0;
            reg_d_v <= 5'b0;
            store_wren <= 1'b0;
            store_addr <= 32'b0;
            store_strb <= 4'b0;
            store_data <= 32'b0;
        end
        else begin
            pc <= M_PC;
            inst <= M_INST;
            valid <= M_VALID;
            reg_d <= M_REG_D;
            reg_d_v <= M_REG_D_V;
            store_wren <= M_STORE_WREN;
            store_addr <= M_STORE_ADDR;
            store_strb <= M_STORE_STRB;
            store_data <= M_STORE_DATA;
        end
    end

    /* ----- �o�� ----- */
    assign W_PC         = pc;
    assign W_INST       = inst;
    assign W_VALID      = valid;
    assign W_REG_D      = reg_d;
    assign W_REG_D_V    = reg_d_v;
    assign W_STORE_WREN = store_wren;
    assign W_STORE_ADDR = store_addr;
    assign W_STORE_STRB = store_strb;
    assign W_STORE_DATA = store_data;

endmodule
