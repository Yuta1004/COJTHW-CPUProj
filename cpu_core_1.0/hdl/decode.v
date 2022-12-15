//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I) : Decode
// Project     : cpu_proj
// Filename    : decode.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/10  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module decode
    (
        /* ----- クロック&リセット信号 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- 上位との接続用 ----- */
        // 制御
        input wire          STALL,
        input wire          FLUSH,

        // 入力
        input wire  [31:0]  I_PC,
        input wire  [31:0]  I_INST,
        input wire          I_VALID,

        // 出力
        output wire [31:0]  D_PC,
        output wire [31:0]  D_INST,
        output wire         D_VALID,
        output wire [6:0]   D_OPCODE,
        output wire [2:0]   D_FUNCT3,
        output wire [6:0]   D_FUNCT7,
        output wire [31:0]  D_IMM,
        output wire [4:0]   D_REG_D,
        output wire [4:0]   D_REG_S1,
        output wire [4:0]   D_REG_S2
    );

    /* ----- 入力(ラッチ取り込み) ----- */
    reg [31:0]  i_pc, i_inst;
    reg         i_valid;

    always @ (posedge CLK) begin
        if (RST) begin
            i_pc <= 32'b0;
            i_inst <= 32'b0;
            i_valid <= 1'b0;
        end
        else if (STALL)
            ;
        else if (FLUSH) begin
            i_pc <= 32'b0;
            i_inst <= 32'b0;
            i_valid <= 1'b0;
        end
        else begin
            i_pc <= I_PC;
            i_inst <= I_INST;
            i_valid <= I_VALID;
        end
    end

    /* ----- 出力 ----- */
    // PC, INST, VALID
    assign D_PC     = i_pc;
    assign D_INST   = i_inst;
    assign D_VALID  = i_valid;

    // opcode, funct3, funct7
    assign D_OPCODE = i_inst[6:0];
    assign D_FUNCT3 = i_inst[14:12];
    assign D_FUNCT7 = i_inst[31:25];

    // imm
    assign D_IMM = gen_imm(i_inst, D_OPCODE);

    function [31:0] gen_imm;
        input [31:0]    INST;
        input [6:0]     OPCODE;

        // R形式
        if (
            INST[6:0] == 7'b0110011
        )
            gen_imm = 32'b0;

        // I形式
        else if (
            INST[6:0] == 7'b1100111 ||
            INST[6:0] == 7'b0000011 ||
            INST[6:0] == 7'b0010011 ||
            INST[6:0] == 7'b0001111 ||
            INST[6:0] == 7'b1110011
        )
            gen_imm = { 20'b0, INST[31:20] };

        // S形式
        else if (
            INST[6:0] == 7'b0100011
        )
            gen_imm = { 20'b0, INST[31:25], INST[11:7] };

        // B形式
        else if (
            INST[6:0] == 7'b1100011
        )
            gen_imm = { 19'b0, INST[31], INST[7], INST[30:25], INST[11:8], 1'b0 };

        // U形式
        else if (
            INST[6:0] == 7'b0110111 ||
            INST[6:0] == 7'b0010111
        )
            gen_imm = { INST[31:12], 12'b0 };

        // J形式
        else if (
            INST[6:0] == 7'b1101111
        )
            gen_imm = { 11'b0, INST[31], INST[19:12], INST[20], INST[30:21], 1'b0 };

        // 未対応命令
        else
            gen_imm = 32'b0;
    endfunction

    // rd, rs1, rs2
    assign D_REG_D  = check_reg_d(i_inst);
    assign D_REG_S1 = i_inst[19:15];
    assign D_REG_S2 = i_inst[24:20];

    function [4:0] check_reg_d;
        input [31:0] INST;

        // S形式 or B形式
        if (
            INST[6:0] == 7'b0100011 ||
            INST[6:0] == 7'b1100011
        )
            check_reg_d = 5'b0;
        else
            check_reg_d = INST[11:7];
    endfunction

endmodule
