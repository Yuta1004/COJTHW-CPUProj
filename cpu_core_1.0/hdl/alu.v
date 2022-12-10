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

module alu
    (
        /* ----- クロック&リセット信号 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- 上位との接続用 ----- */
        // 制御
        input wire          STALL,

        // 入力
        input wire  [31:0]  D_PC,
        input wire  [31:0]  D_INST,
        input wire          D_VALID,
        input wire  [6:0]   D_OPCODE,
        input wire  [2:0]   D_FUNCT3,
        input wire  [6:0]   D_FUNCT7,
        input wire  [31:0]  D_IMM,
        input wire  [4:0]   D_REG_D,
        input wire  [4:0]   D_REG_S1,
        input wire  [31:0]  D_REG_S1_V,
        input wire  [4:0]   D_REG_S2,
        input wire  [31:0]  D_REG_S2_V,

        // 出力
        output wire [31:0]  A_PC,
        output wire [31:0]  A_INST,
        output wire         A_VALID,
        output wire [4:0]   A_REG_D,
        output wire [31:0]  A_REG_D_V
        // output wire [31:0]  A_LOAD_ADDR,
        // output wire [31:0]  A_LOAD_STRB,
        // output wire [31:0]  A_STORE_ADDR,
        // output wire [31:0]  A_STORE_STRB,
        // output wire [31:0]  A_STORE_DATA
    );

    /* ----- 入力(ラッチ取り込み) ----- */
    reg [31:0] pc, inst, imm;
    reg        valid;
    reg [6:0]  opcode;
    reg [2:0]  funct3;
    reg [6:0]  funct7;
    reg [4:0]  reg_d, reg_s1, reg_s2;
    reg [31:0] reg_s1_v, reg_s2_v;

    always @ (posedge CLK) begin
        pc <= D_PC;
        inst <= D_INST;
        valid <= D_VALID;
        opcode <= D_OPCODE;
        funct3 <= D_FUNCT3;
        funct7 <= D_FUNCT7;
        imm <= D_IMM;
        reg_d <= D_REG_D;
        reg_s1 <= D_REG_S1;
        reg_s1_v <= D_REG_S1_V;
        reg_s2 <= D_REG_S2;
        reg_s2_v <= D_REG_S2_V;
    end

    /* ----- 出力 ----- */
    // PC, INST, VALID
    assign A_PC = pc;
    assign A_INST = inst;
    assign A_VALID = valid;

    // rd
    assign A_REG_D = reg_d;
    assign A_REG_D_V = rd_calc(opcode, funct3, funct7, reg_s1_v, reg_s2_v, imm);

    function [31:0] rd_calc;
        input [6:0]  OPCODE;
        input [2:0]  FUNCT3;
        input [6:0]  FUNCT7;
        input [31:0] REG_S1_V;
        input [31:0] REG_S2_V;
        input [31:0] IMM;

        casez ({ OPCODE, FUNCT3, FUNCT7 })
            // addi
            17'b0010011_000_zzzzzzz: rd_calc = REG_S1_V + { { 20{ IMM[11] } }, IMM[11:0] };

            // 未対応命令
            default: rd_calc = 32'b0;
        endcase

    endfunction

endmodule
