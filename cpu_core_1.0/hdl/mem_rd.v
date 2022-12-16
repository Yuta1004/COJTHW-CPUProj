//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I) : ALU
// Project     : cpu_proj
// Filename    : alu.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/10  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module mem_rd
    (
        /* ----- �N���b�N&���Z�b�g�M�� ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- ��ʂƂ̐ڑ��p ----- */
        // ����
        input wire          STALL,
        input wire          FLUSH,
        output wire         DO_JMP,
        output wire [31:0]  NEW_PC,

        // ����
        input wire  [31:0]  A_PC,
        input wire  [31:0]  A_INST,
        input wire          A_VALID,
        input wire          A_DO_JMP,
        input wire  [31:0]  A_NEW_PC,
        input wire  [4:0]   A_REG_D,
        input wire  [31:0]  A_REG_D_V,
        input wire  [31:0]  A_LOAD_ADDR,
        input wire          A_LOAD_RDEN,
        input wire  [1:0]   A_LOAD_SIZE,
        input wire          A_LOAD_SIGNED,
        input wire          A_STORE_WREN,
        input wire  [31:0]  A_STORE_ADDR,
        input wire  [3:0]   A_STORE_STRB,
        input wire  [31:0]  A_STORE_DATA,

        input wire  [31:0]  DATA_RDDATA,

        // �o��
        output wire [31:0]  M_PC,
        output wire [31:0]  M_INST,
        output wire         M_VALID,
        output wire [4:0]   M_REG_D,
        output wire [31:0]  M_REG_D_V,
        output wire         M_STORE_WREN,
        output wire [31:0]  M_STORE_ADDR,
        output wire [3:0]   M_STORE_STRB,
        output wire [31:0]  M_STORE_DATA
    );

    /* ----- ����(���b�`��荞��) ----- */
    reg [31:0]  pc, inst;
    reg         valid;
    reg         do_jmp;
    reg [31:0]  new_pc;
    reg [4:0]   reg_d;
    reg [31:0]  reg_d_v;
    reg [31:0]  load_addr;
    reg         load_rden;
    reg [1:0]   load_size;
    reg         load_signed;
    reg         store_wren;
    reg [31:0]  store_addr, store_data;
    reg [3:0]   store_strb;

    always @ (posedge CLK) begin
        if (RST) begin
            pc <= 32'b0;
            inst <= 32'b0;
            valid <= 1'b0;
            do_jmp <= 1'b0;
            new_pc <= 32'b0;
            reg_d <= 5'b0;
            reg_d_v <= 32'b0;
            load_addr <= 32'b0;
            load_rden <= 1'b0;
            load_size <= 2'b0;
            load_signed <= 1'b0;
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
            do_jmp <= 1'b0;
            new_pc <= 32'b0;
            reg_d <= 5'b0;
            reg_d_v <= 32'b0;
            load_addr <= 32'b0;
            load_rden <= 1'b0;
            load_size <= 2'b0;
            load_signed <= 1'b0;
            store_wren <= 1'b0;
            store_addr <= 32'b0;
            store_strb <= 4'b0;
            store_data <= 32'b0;
        end
        else begin
            pc <= A_PC;
            inst <= A_INST;
            valid <= A_VALID;
            do_jmp <= A_DO_JMP;
            new_pc <= A_NEW_PC;
            reg_d <= A_REG_D;
            reg_d_v <= A_REG_D_V;
            load_addr <= A_LOAD_ADDR;
            load_rden <= A_LOAD_RDEN;
            load_size <= A_LOAD_SIZE;
            load_signed <= A_LOAD_SIGNED;
            store_wren <= A_STORE_WREN;
            store_addr <= A_STORE_ADDR;
            store_strb <= A_STORE_STRB;
            store_data <= A_STORE_DATA;
        end
    end

    /* ----- �o�� ----- */
    // ����t���O
    assign DO_JMP       = do_jmp;
    assign NEW_PC       = new_pc;

    // PC, INST, VALID, ...
    assign M_PC         = pc;
    assign M_INST       = inst;
    assign M_VALID      = valid;
    assign M_REG_D      = reg_d;
    assign M_STORE_WREN = store_wren;
    assign M_STORE_ADDR = store_addr;
    assign M_STORE_STRB = store_strb;
    assign M_STORE_DATA = store_data;

    // reg_d_v
    assign M_REG_D_V    = load_rden ? load_reg_d_v(load_addr, DATA_RDDATA, load_size, load_signed) : reg_d_v;

    function [31:0] load_reg_d_v;
        input [31:0] ADDR;
        input [31:0] VALUE;
        input [1:0]  SIZE;
        input        SIGNED;

        case (SIZE)
            2'b00: // byte
                if (ADDR[1:0] == 2'b00) begin
                    if (SIGNED)
                        load_reg_d_v = { { { 24{ VALUE[7] } }, VALUE[7:0] } };
                    else
                        load_reg_d_v = { 24'b0, VALUE[7:0] };
                end
                else if (ADDR[1:0] == 2'b01) begin
                    if (SIGNED)
                        load_reg_d_v = { { { 24{ VALUE[15] } }, VALUE[15:8] } };
                    else
                        load_reg_d_v = { 24'b0, VALUE[15:8] };
                end
                else if (ADDR[1:0] == 2'b10) begin
                    if (SIGNED)
                        load_reg_d_v = { { { 24{ VALUE[23] } }, VALUE[23:16] } };
                    else
                        load_reg_d_v = { 24'b0, VALUE[23:16] };
                end
                else begin
                    if (SIGNED)
                        load_reg_d_v = { { { 24{ VALUE[31] } }, VALUE[31:24] } };
                    else
                        load_reg_d_v = { 24'b0, VALUE[31:24] };
                end
            2'b01: // half
                if (ADDR[1:0] == 2'b00) begin
                    if (SIGNED)
                        load_reg_d_v = { { { 16{ VALUE[15] } }, VALUE[15:0] } };
                    else
                        load_reg_d_v = { 16'b0, VALUE[15:0] };
                end
                else if (ADDR[1:0] == 2'b01) begin
                    if (SIGNED)
                        load_reg_d_v = { { { 16{ VALUE[23] } }, VALUE[23:8] } };
                    else
                        load_reg_d_v = { 16'b0, VALUE[23:8] };
                end
                else if (ADDR[1:0] == 2'b10) begin
                    if (SIGNED)
                        load_reg_d_v = { { { 16{ VALUE[31] } }, VALUE[31:16] } };
                    else
                        load_reg_d_v = { 16'b0, VALUE[31:16] };
                end
                else
                    load_reg_d_v = { 24'b0, VALUE[31:24] };
            2'b11: // word
                load_reg_d_v = VALUE;
            default:
                load_reg_d_v = 32'b0;
        endcase
    endfunction

endmodule
