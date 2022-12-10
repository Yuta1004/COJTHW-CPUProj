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

wire [31:0]     A_PC            = core.alu.A_PC;
wire [31:0]     A_INST          = core.alu.A_INST;
wire            A_VALID         = core.alu.A_VALID;
wire            A_DO_JMP        = core.alu.A_DO_JMP;
wire [31:0]     A_NEW_PC        = core.alu.A_NEW_PC;
wire [4:0]      A_REG_D         = core.alu.A_REG_D;
wire [31:0]     A_REG_D_V       = core.alu.A_REG_D_V;

wire [31:0]     M_PC            = core.mem_rd.M_PC;
wire [31:0]     M_INST          = core.mem_rd.M_INST;
wire            M_VALID         = core.mem_rd.M_VALID;
wire [4:0]      M_REG_D         = core.mem_rd.M_REG_D;
wire [31:0]     M_REG_D_V       = core.mem_rd.M_REG_D_V;

wire [31:0]     W_PC            = core.wb.W_PC;
wire [31:0]     W_INST          = core.wb.W_INST;
wire            W_VALID         = core.wb.W_VALID;
wire [4:0]      W_REG_D         = core.wb.W_REG_D;
wire [31:0]     W_REG_D_V       = core.wb.W_REG_D_V;

/* ----- メモリ(命令)書き込み ----- */
task write_inst;
integer i;
begin
    for (i = 0; i < 1024*2; i = i + 1)
        axi_slave_bfm_inst.ram_array[i] = 0;

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

    // 3. 多段beq + ストール
    axi_slave_bfm_inst.ram_array[0] = 32'b00000000000000000000000110010011; // addi x3, x0, 0
    axi_slave_bfm_inst.ram_array[1] = 32'b00000000101000000000000010010011; // addi x1, x0, 10
    axi_slave_bfm_inst.ram_array[2] = 32'b00000001010000000000000100010011; // addi x2, x0, 20
    axi_slave_bfm_inst.ram_array[3] = 32'b00000000001000001000010001100011; // beq x1, x2, 8
    axi_slave_bfm_inst.ram_array[4] = 32'b00000000101000011000000110010011; // addi x3, x3, 10
    axi_slave_bfm_inst.ram_array[5] = 32'b00000001010000011000000110010011; // addi x3, x3, 20  -> x3 = 30
    axi_slave_bfm_inst.ram_array[6] = 32'b00000001010000000000000010010011; // addi x1, x0, 20
    axi_slave_bfm_inst.ram_array[7] = 32'b00111110001000001000000001100011;    // beq x1, x2, 992
    axi_slave_bfm_inst.ram_array[255] = 32'b00000000000000000000000000010011;  // nop
    axi_slave_bfm_inst.ram_array[256] = 32'b01000000001000001000000001100011;  // beq x1, x2, 1024
    axi_slave_bfm_inst.ram_array[512] = 32'b01000000001000001000000001100011;  // beq x1, x2, 1024
    axi_slave_bfm_inst.ram_array[768] = 32'b01000000001000001000000001100011;  // beq x1, x2, 1024
    axi_slave_bfm_inst.ram_array[1024] = 32'b00000001010000011000000110010011; // addi x3, x3, 20  -> x3 = 50
end
endtask

/* ----- メモリ(データ)書き込み ----- */
task write_data;
integer i;
begin
    for (i = 0; i < 1024*2; i = i + 1)
        axi_slave_bfm_data.ram_array[i] = 0;
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

    $stop;
end

endmodule
