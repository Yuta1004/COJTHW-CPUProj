//-----------------------------------------------------------------------------
// Title       : coreのテストベンチ（スレーブBFMとの直結による単体検証）
// Project     : cpu_proj
// Filename    : core_tb.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/09  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------


`timescale 1ns/1ps

module core_tb;

/* ----- 各種定数 ----- */
localparam integer C_AXI_DATA_WIDTH = 32;
localparam integer C_OFFSET_WIDTH = 28;
localparam integer STEP  = 1000 / 50;   // 50Mhz

/* ----- Coreとの接続用 ----- */
reg             EXEC;
wire [7:0]      STAT;

wire [31:0]     REG00;
wire [31:0]     REG01;
wire [31:0]     REG02;
wire [31:0]     REG03;
wire [31:0]     REG04;
wire [31:0]     REG05;
wire [31:0]     REG06;
wire [31:0]     REG07;
wire [31:0]     REG08;
wire [31:0]     REG09;
wire [31:0]     REG10;
wire [31:0]     REG11;
wire [31:0]     REG12;
wire [31:0]     REG13;
wire [31:0]     REG14;
wire [31:0]     REG15;
wire [31:0]     REG16;
wire [31:0]     REG17;
wire [31:0]     REG18;
wire [31:0]     REG19;
wire [31:0]     REG20;
wire [31:0]     REG21;
wire [31:0]     REG22;
wire [31:0]     REG23;
wire [31:0]     REG24;
wire [31:0]     REG25;
wire [31:0]     REG26;
wire [31:0]     REG27;
wire [31:0]     REG28;
wire [31:0]     REG29;
wire [31:0]     REG30;
wire [31:0]     REG31;
wire [31:0]     REGPC;

/* ----- クロック&リセット信号 ----- */
reg CLK;
reg RST;

always begin
    CLK = 0; #(STEP/2);
    CLK = 1; #(STEP/2);
end

/* ----- 共通化した接続部分の記述を読み込む ----- */
`include "core_axibfm.vh"

/* ----- 監視対象信号 ----- */
// 全体制御
wire            STALL           = core.stall;
wire            FLUSH           = core.flush;
wire            INST_MEM_WAIT   = core.inst_fetch.MEM_WAIT;
wire            DO_JMP          = core.mem_rd.DO_JMP;
wire [31:0]     NEW_PC          = core.mem_rd.NEW_PC;

// 命令フェッチ
wire            EXEC_           = EXEC;

wire [31:0]     P_PC            = core.inst_fetch.pc;
wire            P_VALID         = core.inst_fetch.pc_valid;

wire [31:0]     I_PC            = core.inst_fetch.I_PC;
wire [31:0]     I_INST          = core.inst_fetch.I_INST;
wire            I_VALID         = core.inst_fetch.I_VALID;

wire [31:0]     D_PC            = core.decode.D_PC;
wire [31:0]     D_INST          = core.decode.D_INST;
wire            D_VALID         = core.decode.D_VALID;
wire [6:0]      D_OPCODE        = core.decode.D_OPCODE;
wire [2:0]      D_FUNCT3        = core.decode.D_FUNCT3;
wire [6:0]      D_FUNCT7        = core.decode.D_FUNCT7;
wire [31:0]     D_IMM           = core.decode.D_IMM;
wire [4:0]      D_REG_D         = core.decode.D_REG_D;
wire [4:0]      D_REG_S1        = core.decode.D_REG_S1;
wire [31:0]     D_REG_S1_V      = core.decode.D_REG_S1_V;
wire [4:0]      D_REG_S2        = core.decode.D_REG_S2;
wire [31:0]     D_REG_S2_V      = core.decode.D_REG_S2_V;

wire [31:0]     TEST_1          = core.alu.forwarded_reg_s1_v;
wire [31:0]     TEST_2          = core.alu.forwarded_reg_s2_v;

wire [31:0]     A_PC            = core.alu.A_PC;
wire [31:0]     A_INST          = core.alu.A_INST;
wire            A_VALID         = core.alu.A_VALID;
wire            A_DO_JMP        = core.alu.A_DO_JMP;
wire [31:0]     A_NEW_PC        = core.alu.A_NEW_PC;
wire [4:0]      A_REG_D         = core.alu.A_REG_D;
wire [31:0]     A_REG_D_V       = core.alu.A_REG_D_V;
wire            A_STORE_WREN    = core.alu.A_STORE_WREN;
wire [31:0]     A_STORE_ADDR    = core.alu.A_STORE_ADDR;
wire [3:0]      A_STORE_STRB    = core.alu.A_STORE_STRB;
wire [31:0]     A_STORE_DATA    = core.alu.A_STORE_DATA;

wire [31:0]     M_PC            = core.mem_rd.M_PC;
wire [31:0]     M_INST          = core.mem_rd.M_INST;
wire            M_VALID         = core.mem_rd.M_VALID;
wire [4:0]      M_REG_D         = core.mem_rd.M_REG_D;
wire [31:0]     M_REG_D_V       = core.mem_rd.M_REG_D_V;
wire            M_STORE_WREN    = core.mem_rd.M_STORE_WREN;
wire [31:0]     M_STORE_ADDR    = core.mem_rd.M_STORE_ADDR;
wire [3:0]      M_STORE_STRB    = core.mem_rd.M_STORE_STRB;
wire [31:0]     M_STORE_DATA    = core.mem_rd.M_STORE_DATA;

wire [31:0]     W_PC            = core.wb.W_PC;
wire [31:0]     W_INST          = core.wb.W_INST;
wire            W_VALID         = core.wb.W_VALID;
wire [4:0]      W_REG_D         = core.wb.W_REG_D;
wire [31:0]     W_REG_D_V       = core.wb.W_REG_D_V;
wire            W_STORE_WREN    = core.wb.W_STORE_WREN;
wire [31:0]     W_STORE_ADDR    = core.wb.W_STORE_ADDR;
wire [3:0]      W_STORE_STRB    = core.wb.W_STORE_STRB;
wire [31:0]     W_STORE_DATA    = core.wb.W_STORE_DATA;

/* ----- メモリ(命令)書き込み ----- */
task write_inst;
integer i;
begin
    // 範囲外にx1を破壊する命令を敷き詰める (addi x1, x0, 1234)
    for (i = 0; i < 1024*4; i = i + 1)
        axi_slave_bfm_inst.ram_array[i] = 32'h4d20_0093;

    // 1. addi & フォワーディング
    // axi_slave_bfm_inst.ram_array[0] = 32'b00111110100000000000000010010011;     // addi x1, x0, 1000    -> 1000
    // axi_slave_bfm_inst.ram_array[1] = 32'b00000000000000000000000000010011;     // nop
    // axi_slave_bfm_inst.ram_array[2] = 32'b01111101000000001000000100010011;     // addi x2, x1, 2000    -> 3000
    // axi_slave_bfm_inst.ram_array[3] = 32'b11000001100000010000000110010011;     // addi x3, x2, -1000   -> 2000
    // axi_slave_bfm_inst.ram_array[4] = 32'b00000000000000000000000000010011;     // nop
    // axi_slave_bfm_inst.ram_array[5] = 32'b10000011000000011000001000010011;     // addi x4, x3, -2000   -> 0
    // axi_slave_bfm_inst.ram_array[6] = 32'b00111110100000100000001010010011;     // addi x5, x4, 1000    -> 1000
    // axi_slave_bfm_inst.ram_array[7] = 32'b10000011000000101000001100010011;     // addi x6, x5, -2000   -> -1000
    // axi_slave_bfm_inst.ram_array[8] = 32'b00000000000000000000000000010011;     // nop
    // axi_slave_bfm_inst.ram_array[9] = 32'b00000000000000000000000000010011;     // nop
    // axi_slave_bfm_inst.ram_array[10] = 32'b10000011000000110000001110010011;    // addi x7, x6, -2000   -> -3000
    // axi_slave_bfm_inst.ram_array[11] = 32'b01111101000000111000010000010011;    // addi x8, x7, 2000    -> -1000
    // axi_slave_bfm_inst.ram_array[12] = 32'b01111101000001000000010010010011;    // addi x9, x8, 3000    -> 1000
    // axi_slave_bfm_inst.ram_array[13] = 32'b00000000000000000000000000010011;    // nop
    // axi_slave_bfm_inst.ram_array[14] = 32'b11110011100001001000010010010011;    // addi x9, x9, -200    -> 800
    // axi_slave_bfm_inst.ram_array[15] = 32'b11101101010001001000010010010011;    // addi x9, x9, -300    -> 500
    // axi_slave_bfm_inst.ram_array[16] = 32'b11100111000001001000010010010011;    // addi x9, x9, -400    -> 100
    // axi_slave_bfm_inst.ram_array[17] = 32'b11111100111001001000010010010011;    // addi x9, x9, -50     -> 50
    // axi_slave_bfm_inst.ram_array[18] = 32'b00000110010001001000010010010011;    // addi x9, x9, 100     -> 150
    // axi_slave_bfm_inst.ram_array[19] = 32'h0000_006f;

    // 2. beq
    // axi_slave_bfm_inst.ram_array[0] = 32'b00000000000000000000000110010011; // addi x3, x0, 0
    // axi_slave_bfm_inst.ram_array[1] = 32'b00000000101000000000000010010011; // addi x1, x0, 10
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000001010000000000000100010011; // addi x2, x0, 20
    // axi_slave_bfm_inst.ram_array[3] = 32'b00000000001000001000010001100011; // beq x1, x2, 8
    // axi_slave_bfm_inst.ram_array[4] = 32'b00000000101000011000000110010011; // addi x3, x3, 10
    // axi_slave_bfm_inst.ram_array[5] = 32'b00000001010000011000000110010011; // addi x3, x3, 20  -> x3 = 30
    // axi_slave_bfm_inst.ram_array[6] = 32'b00000001010000000000000010010011; // addi x1, x0, 20
    // axi_slave_bfm_inst.ram_array[7] = 32'b00000000001000001000010001100011; // beq x1, x2, 8
    // axi_slave_bfm_inst.ram_array[8] = 32'b00000000101000011000000110010011; // addi x3, x3, 10
    // axi_slave_bfm_inst.ram_array[9] = 32'b00000001010000011000000110010011; // addi x3, x3, 20  -> x3 = 50
    // axi_slave_bfm_inst.ram_array[10] = 32'h0000_006f;

    // 3. 多段beq + ストール
    // axi_slave_bfm_inst.ram_array[0] = 32'b00000000000000000000000110010011; // addi x3, x0, 0
    // axi_slave_bfm_inst.ram_array[1] = 32'b00000000101000000000000010010011; // addi x1, x0, 10
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000001010000000000000100010011; // addi x2, x0, 20
    // axi_slave_bfm_inst.ram_array[3] = 32'b00000000001000001000010001100011; // beq x1, x2, 8
    // axi_slave_bfm_inst.ram_array[4] = 32'b00000000101000011000000110010011; // addi x3, x3, 10
    // axi_slave_bfm_inst.ram_array[5] = 32'b00000001010000011000000110010011; // addi x3, x3, 20  -> x3 = 30
    // axi_slave_bfm_inst.ram_array[6] = 32'b00000001010000000000000010010011; // addi x1, x0, 20
    // axi_slave_bfm_inst.ram_array[7] = 32'b00111110001000001000000001100011;    // beq x1, x2, 992
    // axi_slave_bfm_inst.ram_array[255] = 32'b00000000000000000000000000010011;  // nop
    // axi_slave_bfm_inst.ram_array[256] = 32'b01000000001000001000000001100011;  // beq x1, x2, 1024
    // axi_slave_bfm_inst.ram_array[512] = 32'b01000000001000001000000001100011;  // beq x1, x2, 1024
    // axi_slave_bfm_inst.ram_array[768] = 32'b01000000001000001000000001100011;  // beq x1, x2, 1024
    // axi_slave_bfm_inst.ram_array[1024] = 32'b00000001010000011000000110010011; // addi x3, x3, 20  -> x3 = 50
    // axi_slave_bfm_inst.ram_array[1025] = 32'h0000_006f;

    // 4. シンプルな演算
    // axi_slave_bfm_inst.ram_array[0] = 32'b00000000110000000000000010010011; // addi x1, x0, 12 -> x1 = 12
    // axi_slave_bfm_inst.ram_array[1] = 32'b00000000010000000000000100010011; // addi x2, x0, 4  -> x2 = 4
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000001000000000000000110010011; // addi x3, x0, 16 -> x3 = 16
    // axi_slave_bfm_inst.ram_array[3] = 32'b00000000001000001000001000110011; // add x4, x1, x2  -> x4 = 16
    // axi_slave_bfm_inst.ram_array[4] = 32'b00000000001100001000001010110011; // add x5, x1, x3  -> x5 = 28
    // axi_slave_bfm_inst.ram_array[5] = 32'b01000000001000001000001100110011; // sub x6, x1, x2  -> x6 = 8
    // axi_slave_bfm_inst.ram_array[6] = 32'b01000000001100001000001110110011; // sub x7, x1, x3  -> x7 = -4
    // axi_slave_bfm_inst.ram_array[7] = 32'h0000_006f;

    // 5. 論理演算
    // axi_slave_bfm_inst.ram_array[0] = 32'b00000000111000000000000010010011; // addi x1, x0, 14 -> x1 = b01110
    // axi_slave_bfm_inst.ram_array[1] = 32'b00000001010000000000000100010011; // addi x2, x0, 20 -> x2 = b10100
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000000001000001111000110110011; // and x3, x1, x2  -> x3 = b00100
    // axi_slave_bfm_inst.ram_array[3] = 32'b00000000001000001110001000110011; // or x4, x1, x2   -> x4 = b11110
    // axi_slave_bfm_inst.ram_array[4] = 32'b00000000001000001100001010110011; // xor x5, x1, x2  -> x5 = b11010
    // axi_slave_bfm_inst.ram_array[5] = 32'b00000001010000001111001100010011; // andi x6, x1, 20 -> x6 = b00100
    // axi_slave_bfm_inst.ram_array[6] = 32'b00000001010000001110001110010011; // ori x7, x1, 20  -> x7 = b11110
    // axi_slave_bfm_inst.ram_array[7] = 32'b00000001010000001100010000010011; // xori x8, x1, x2 -> x8 = b11010
    // axi_slave_bfm_inst.ram_array[8] = 32'h0000_006f;

    // 6. シフト演算
    // axi_slave_bfm_inst.ram_array[0] = 32'b10000000000000000000000010110111; // lui x1, 0x80000
    // axi_slave_bfm_inst.ram_array[1] = 32'b00000000111000001000000010010011; // add x1, x1, 14
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000000001000000000000100010011; // addi x2, x0, 2
    // axi_slave_bfm_inst.ram_array[3] = 32'b00000000001000001001000110110011; // sll x3, x1, x2
    // axi_slave_bfm_inst.ram_array[4] = 32'b01000000001000001101001000110011; // sra x4, x1, x2
    // axi_slave_bfm_inst.ram_array[5] = 32'b00000000001000001101001010110011; // srl x5, x1, x2
    // axi_slave_bfm_inst.ram_array[6] = 32'b00000000001000001001001100010011; // slli x6, x1, 2
    // axi_slave_bfm_inst.ram_array[7] = 32'b01000000001000001101001110010011; // srai s7, x1, 2
    // axi_slave_bfm_inst.ram_array[8] = 32'b00000000001000001101010000010011; // srli s8, x1, 2
    // axi_slave_bfm_inst.ram_array[9] = 32'h0000_006f;

    // 7. auipcを使った大ジャンプ + ストール
    // axi_slave_bfm_inst.ram_array[0]    = 32'b00000000000000000001000010010111; // auipc x1, 1    -> x1 = 0x2000_1000
    // axi_slave_bfm_inst.ram_array[1024] = 32'b00000000101000000000000100010011; // addi x2, 10    -> x2 = 10
    // axi_slave_bfm_inst.ram_array[1025] = 32'b00000001010000000000000110010011; // addi x3, 20    -> x3 = 20
    // axi_slave_bfm_inst.ram_array[1026] = 32'b00000000001100010000001000110011; // add x4, x2, x3 -> x4 = 30
    // axi_slave_bfm_inst.ram_array[1027] = 32'h0000_006f;

    // 8. 論理演算2
    // axi_slave_bfm_inst.ram_array[0] = 32'b00000000101000000000000010010011; // addi x1, x0, 10 -> x1 = 10
    // axi_slave_bfm_inst.ram_array[1] = 32'b00000001010000000000000100010011; // addi x2, x0, 20 -> x2 = 20
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000000010100000000000110010011; // addi x3, x0, 5  -> x3 = 5
    // axi_slave_bfm_inst.ram_array[3] = 32'b00000000001000001010001000110011; // slt x4, x1, x2  -> x4 = 1
    // axi_slave_bfm_inst.ram_array[4] = 32'b00000000001100001010001010110011; // slt x5, x1, x3  -> x5 = 0
    // axi_slave_bfm_inst.ram_array[5] = 32'b00000001010000001010001100010011; // slti x6, x1, 20 -> x6 = 1
    // axi_slave_bfm_inst.ram_array[6] = 32'b00000000010100001010001110010011; // slti x7, x1, 5  -> x7 = 0
    // axi_slave_bfm_inst.ram_array[7] = 32'h0000_006f;

    // 9. 条件分岐 blt-1
    // axi_slave_bfm_inst.ram_array[0] = 32'b00000000101000000000000010010011; // addi x1, x0, 10 -> x1 = 10
    // axi_slave_bfm_inst.ram_array[1] = 32'b01000000000100000000000010110011; // sub x1, x0, x1  -> x1 = -10
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000001010000000000000100010011; // addi x2, x0, 20 -> x2 = 20
    // axi_slave_bfm_inst.ram_array[3] = 32'b00000000001000001100010001100011; // blt x1, x2, 8
    // axi_slave_bfm_inst.ram_array[4] = 32'b00000000101000000000000110010011; // addi x3, x0, 10
    // axi_slave_bfm_inst.ram_array[5] = 32'b00000001010000011000000110010011; // add x3, x3, 20  -> x3 = 20
    // axi_slave_bfm_inst.ram_array[6] = 32'h0000_006f;

    // 10. 条件分岐 blt-2
    // axi_slave_bfm_inst.ram_array[0] = 32'b00000000101000000000000010010011; // addi x1, x0, 10 -> x1 = 10
    // axi_slave_bfm_inst.ram_array[1] = 32'b01000000000100000000000010110011; // sub x1, x0, x1  -> x1 = -10
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000001010000000000000100010011; // addi x2, x0, 20 -> x2 = 20
    // axi_slave_bfm_inst.ram_array[3] = 32'b00000000000100010100010001100011; // blt x2, x1, 8
    // axi_slave_bfm_inst.ram_array[4] = 32'b00000000101000000000000110010011; // addi x3, x0, 10 -> x3 = 10
    // axi_slave_bfm_inst.ram_array[5] = 32'b00000001010000011000000110010011; // add x3, x3, 20  -> x3 = 30
    // axi_slave_bfm_inst.ram_array[6] = 32'h0000_006f;

    // 11. 条件分岐 bltu-1
    // axi_slave_bfm_inst.ram_array[0] = 32'b00000000101000000000000010010011; // addi x1, x0, 10 -> x1 = 10
    // axi_slave_bfm_inst.ram_array[1] = 32'b01000000000100000000000010110011; // sub x1, x0, x1  -> x1 = -10
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000001010000000000000100010011; // addi x2, x0, 20 -> x2 = 20
    // axi_slave_bfm_inst.ram_array[3] = 32'b00000000001000001110010001100011; // bltu x1, x2, 8
    // axi_slave_bfm_inst.ram_array[4] = 32'b00000000101000000000000110010011; // addi x3, x0, 10 -> x3 = 10
    // axi_slave_bfm_inst.ram_array[5] = 32'b00000001010000011000000110010011; // add x3, x3, 20  -> x3 = 30
    // axi_slave_bfm_inst.ram_array[6] = 32'h0000_006f;

    // 12. 条件分岐 bltu-2
    // axi_slave_bfm_inst.ram_array[0] = 32'b00000000101000000000000010010011; // addi x1, x0, 10 -> x1 = 10
    // axi_slave_bfm_inst.ram_array[1] = 32'b01000000000100000000000010110011; // sub x1, x0, x1  -> x1 = -10
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000001010000000000000100010011; // addi x2, x0, 20 -> x2 = 20
    // axi_slave_bfm_inst.ram_array[3] = 32'b00000000000100010110010001100011; // bltu x2, x1, 8
    // axi_slave_bfm_inst.ram_array[4] = 32'b00000000101000000000000110010011; // addi x3, x0, 10
    // axi_slave_bfm_inst.ram_array[5] = 32'b00000001010000011000000110010011; // add x3, x3, 20  -> x3 = 20
    // axi_slave_bfm_inst.ram_array[6] = 32'h0000_006f;

    // 13. jalを使用したジャンプ
    // axi_slave_bfm_inst.ram_array[0] = 32'b00000000100000000000000011101111; // jal x1, 8       -> x1 = 0x2000_0004
    // axi_slave_bfm_inst.ram_array[1] = 32'b00000000101000000000000100010011; // addi x2, x0, 10
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000001010000010000000100010011; // addi x2, x2, 20 -> x2 = 20
    // axi_slave_bfm_inst.ram_array[3] = 32'h0000_006f;

    // 14. jalrを使用したジャンプ
    // axi_slave_bfm_inst.ram_array[0] = 32'b00100000000000000001000010110111; // lui x1, 0x20001   -> x1 = 0x2000_1000
    // axi_slave_bfm_inst.ram_array[1] = 32'b00000000000000001000000101100111; // jalr x2, 0(x1)    -> x2 = 0x2000_0008
    // axi_slave_bfm_inst.ram_array[2] = 32'b00000000101000000000001000010011; // addi x4, x0, 10   -> x4 = 10
    // axi_slave_bfm_inst.ram_array[3] = 32'h0000_006f;
    // axi_slave_bfm_inst.ram_array[1024] = 32'b00000000000000010000000111100111; // jalr x3, 0(x2) -> x3 = 0x2001_0004

    // 15. メモリ書き込み
    axi_slave_bfm_inst.ram_array[0] = 32'b00100000000000000001000010110111; // lui x1, 0x20001
    axi_slave_bfm_inst.ram_array[1] = 32'b00010010001101000101000100110111; // lui x2, 0x12345
    axi_slave_bfm_inst.ram_array[2] = 32'b01100111100000010000000100010011; // addi x2, x2, 0x678
    axi_slave_bfm_inst.ram_array[3] = 32'b00000000001000001000000110100011; // sb x2, 3(x1)
    axi_slave_bfm_inst.ram_array[4] = 32'b00000000001000001001001100100011; // sh x2, 6(x1)
    axi_slave_bfm_inst.ram_array[5] = 32'b00000000001000001010010000100011; // sw x2, 8(x1)
    axi_slave_bfm_inst.ram_array[6] = 32'h0000_006f;
end
endtask

/* ----- メモリ(データ)書き込み ----- */
task write_data;
integer i;
begin
    for (i = 0; i < 1024*4; i = i + 1)
        axi_slave_bfm_data.ram_array[i] = 0;
end
endtask

/* ----- メモリダンプ ----- */
task memdump;
integer fd, i;
begin
    fd = $fopen("dump.txt");
    for (i = 0; i < 4*1024; i = i + 1) begin
        $fdisplay(fd, "%08x: %08x", 32'h20000000 + i*4, axi_slave_bfm_data.ram_array[i]);
    end
    $fclose(fd);
end
endtask

/* ----- テストベンチ本体 ----- */
initial begin
    RST = 0;
    EXEC = 0;
    #(STEP*10)

    // メモリ初期化
    write_inst;
    write_data;

    // リセット
    RST = 1;
    #(STEP*10);
    RST = 0;

    // 実行
    #(STEP*5);
    EXEC = 1;
    #(STEP*4500);

    // 結果出力
    memdump;

    $stop;
end

endmodule
