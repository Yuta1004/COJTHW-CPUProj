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
        input wire          FLUSH,

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

        // 入力 (フォワーディング)
        input wire          FWD_M_VALID,
        input wire  [4:0]   FWD_M_REG_D,
        input wire  [31:0]  FWD_M_REG_D_V,

        input wire          FWD_W_VALID,
        input wire  [4:0]   FWD_W_REG_D,
        input wire  [31:0]  FWD_W_REG_D_V,

        // 出力
        output wire [31:0]  A_PC,
        output wire [31:0]  A_INST,
        output wire         A_VALID,
        output wire         A_DO_JMP,
        output wire [31:0]  A_NEW_PC,
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
        if (STALL)
            ;
        else if (FLUSH) begin
            pc <= 32'b0;
            inst <= 32'b0;
            valid <= 1'b0;
            opcode <= 7'b0;
            funct3 <= 3'b0;
            funct7 <= 7'b0;
            imm <= 32'b0;
            reg_d <= 5'b0;
            reg_s1 <= 5'b0;
            reg_s1_v <= 32'b0;
            reg_s2 <= 5'b0;
            reg_s2_v <= 32'b0;
        end
        else begin
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
    end

    /* ----- データフォワーディング ----- */
    wire [31:0] forwarded_reg_s1_v = forward(
        reg_s1, reg_s1_v,
        FWD_M_VALID, FWD_M_REG_D, FWD_M_REG_D_V,
        FWD_W_VALID, FWD_W_REG_D, FWD_W_REG_D_V
    );
    wire [31:0] forwarded_reg_s2_v = forward(
        reg_s2, reg_s2_v,
        FWD_M_VALID, FWD_M_REG_D, FWD_M_REG_D_V,
        FWD_W_VALID, FWD_W_REG_D, FWD_W_REG_D_V
    );

    function [31:0] forward;
        input [4:0]     TARGET_REG;
        input [31:0]    TARGET_REG_V;
        input           FWD_M_VALID;
        input [4:0]     FWD_M_REG_D;
        input [31:0]    FWD_M_REG_D_V;
        input           FWD_W_VALID;
        input [4:0]     FWD_W_REG_D;
        input [31:0]    FWD_W_REG_D_V;

        if (TARGET_REG == 5'b0)
            forward = 32'b0;
        else if (FWD_M_VALID && FWD_M_REG_D == TARGET_REG)
            forward = FWD_M_REG_D_V;
        else if (FWD_W_VALID && FWD_W_REG_D == TARGET_REG)
            forward = FWD_W_REG_D_V;
        else
            forward = TARGET_REG_V;
    endfunction

    /* ----- 出力 ----- */
    // PC, INST, VALID
    assign A_PC = pc;
    assign A_INST = inst;
    assign A_VALID = valid;

    // DO_JMP, NEW_PC
    assign A_DO_JMP = check_do_jmp(
        opcode, funct3, funct7,
        forwarded_reg_s1_v, forwarded_reg_s1_v, forwarded_reg_s2_v, forwarded_reg_s2_v
    );
    assign A_NEW_PC = pc_calc(
        opcode, funct3, funct7,
        pc, forwarded_reg_s1_v, imm
    );

    function check_do_jmp;
        input        [6:0]  OPCODE;
        input        [2:0]  FUNCT3;
        input        [6:0]  FUNCT7;
        input        [31:0] REG_S1_V;
        input signed [31:0] REG_S1_V_S;
        input        [31:0] REG_S2_V;
        input signed [31:0] REG_S2_V_S;

        casez ({ OPCODE, FUNCT3, FUNCT7 })
            17'b0010111_zzz_zzzzzzz: check_do_jmp = 1'b1;                       // auipc
            17'b1100011_000_zzzzzzz: check_do_jmp = REG_S1_V == REG_S2_V;       // beq
            17'b1100011_001_zzzzzzz: check_do_jmp = REG_S1_V != REG_S2_V;       // bne
            17'b1100011_101_zzzzzzz: check_do_jmp = REG_S1_V_S >= REG_S2_V_S;   // bge
            17'b1100011_111_zzzzzzz: check_do_jmp = REG_S1_V >= REG_S2_V;       // bgeu
            17'b1100011_100_zzzzzzz: check_do_jmp = REG_S1_V_S < REG_S2_V_S;    // blt
            17'b1100011_110_zzzzzzz: check_do_jmp = REG_S1_V < REG_S2_V;        // bltu
            17'b1101111_zzz_zzzzzzz: check_do_jmp = 1'b1;                       // jal
            17'b1100111_000_zzzzzzz: check_do_jmp = 1'b1;                       // jalr

            // 未対応命令
            default: check_do_jmp = 0;
        endcase
    endfunction

    function [31:0] pc_calc;
        input [6:0]  OPCODE;
        input [2:0]  FUNCT3;
        input [6:0]  FUNCT7;
        input [31:0] PC;
        input [31:0] REG_S1_V;
        input [31:0] IMM;

        casez ({ OPCODE, FUNCT3, FUNCT7 })
            17'b0010111_zzz_zzzzzzz: pc_calc = PC + ((IMM[31:12]) << 12);                   // auipc
            17'b1100011_000_zzzzzzz: pc_calc = PC + { { 11{ IMM[20] } }, IMM[20:1], 1'b0 }; // beq
            17'b1100011_001_zzzzzzz: pc_calc = PC + { { 11{ IMM[20] } }, IMM[20:1], 1'b0 }; // bne
            17'b1100011_101_zzzzzzz: pc_calc = PC + { { 11{ IMM[20] } }, IMM[20:1], 1'b0 }; // bge
            17'b1100011_111_zzzzzzz: pc_calc = PC + { { 11{ IMM[20] } }, IMM[20:1], 1'b0 }; // bgeu
            17'b1100011_100_zzzzzzz: pc_calc = PC + { { 11{ IMM[20] } }, IMM[20:1], 1'b0 }; // blt
            17'b1100011_110_zzzzzzz: pc_calc = PC + { { 11{ IMM[20] } }, IMM[20:1], 1'b0 }; // bltu
            17'b1101111_zzz_zzzzzzz: pc_calc = PC + { { 11{ IMM[20] } }, IMM[20:1], 1'b0 }; // jal
            17'b1100111_000_zzzzzzz: pc_calc = (REG_S1_V + { { 20{ IMM[11] } }, IMM[11:0] }) & (~32'b1);    // jalr

            // 未対応命令
            default: pc_calc = 32'b0;
        endcase
    endfunction

    // rd
    assign A_REG_D = reg_d;
    assign A_REG_D_V = rd_calc(
        opcode, funct3, funct7,
        pc, forwarded_reg_s1_v, forwarded_reg_s1_v, forwarded_reg_s2_v, forwarded_reg_s2_v, imm
    );

    function [31:0] rd_calc;
        input        [6:0]  OPCODE;
        input        [2:0]  FUNCT3;
        input        [6:0]  FUNCT7;
        input        [31:0] PC;
        input        [31:0] REG_S1_V;
        input signed [31:0] REG_S1_V_S;
        input        [31:0] REG_S2_V;
        input signed [31:0] REG_S2_V_S;
        input        [31:0] IMM;

        casez ({ OPCODE, FUNCT3, FUNCT7 })
            17'b0110011_000_0000000: rd_calc = REG_S1_V + REG_S2_V;                             // add
            17'b0010011_000_zzzzzzz: rd_calc = REG_S1_V + { { 20{ IMM[11] } }, IMM[11:0] };     // addi
            17'b0110011_000_0100000: rd_calc = REG_S1_V - REG_S2_V;                             // sub
            17'b0110011_111_0000000: rd_calc = REG_S1_V & REG_S2_V;                             // and
            17'b0010011_111_zzzzzzz: rd_calc = REG_S1_V & { { 20{ IMM[11] } }, IMM[11:0] };     // andi
            17'b0110011_110_0000000: rd_calc = REG_S1_V | REG_S2_V;                             // or
            17'b0010011_110_zzzzzzz: rd_calc = REG_S1_V | { { 20{ IMM[11] } }, IMM[11:0] };     // ori
            17'b0110011_100_0000000: rd_calc = REG_S1_V ^ REG_S2_V;                             // xor
            17'b0010011_100_zzzzzzz: rd_calc = REG_S1_V ^ { { 20{ IMM[11] } }, IMM[11:0] };     // xori
            17'b0110011_001_0000000: rd_calc = REG_S1_V << (REG_S2_V[4:0]);                     // sll
            17'b0010011_001_0000000: rd_calc = REG_S1_V << (IMM[4:0]);                          // slli
            17'b0110011_101_0100000: rd_calc = REG_S1_V_S >>> (REG_S2_V[4:0]);                  // sra
            17'b0010011_101_0100000: rd_calc = REG_S1_V_S >>> (IMM[4:0]);                       // srai
            17'b0110011_101_0000000: rd_calc = REG_S1_V >> (REG_S2_V[4:0]);                     // srl
            17'b0010011_101_0000000: rd_calc = REG_S1_V >> (IMM[4:0]);                          // srli
            17'b0110111_zzz_zzzzzzz: rd_calc = (IMM[31:12]) << 12;                              // lui
            17'b0010111_zzz_zzzzzzz: rd_calc = PC + ((IMM[31:12]) << 12);                       // auipc
            17'b0110011_010_0000000: rd_calc = REG_S1_V_S < REG_S2_V_S ? 32'b1 : 32'b0;         // slt
            17'b0110011_011_0000000: rd_calc = REG_S1_V < REG_S2_V ? 32'b1 : 32'b0;             // sltu
            17'b0010011_010_zzzzzzz: rd_calc = REG_S1_V_S < { { 20{ IMM[11] } }, IMM[11:0] } ? 32'b1 : 32'b0;   // slti
            17'b0010011_011_zzzzzzz: rd_calc = REG_S1_V < { { 20{ IMM[11] } }, IMM[11:0] } ? 32'b1 : 32'b0;     // sltiu
            17'b1101111_zzz_zzzzzzz: rd_calc = PC + 32'd4;                                      // jal
            17'b1100111_000_zzzzzzz: rd_calc = PC + 32'd4;                                      // jalr

            // 未対応命令
            default: rd_calc = 32'b0;
        endcase
    endfunction

endmodule
