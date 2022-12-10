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
wire            INST_MEM_WAIT   = core.inst_fetch.MEM_WAIT;

// 命令フェッチ
wire            EXEC_           = EXEC;

wire [31:0]     I_PC            = core.inst_fetch.I_PC;
wire            I_VALID         = core.inst_fetch.I_VALID;
wire [31:0]     I_INST          = core.inst_fetch.I_INST;

wire [31:0]     D_PC            = core.decode.D_PC;
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

/* ----- メモリ(命令)書き込み ----- */
task write_inst;
integer i;
begin
    axi_slave_bfm_inst.ram_array[0] = 32'b00111110100000000000000010010011;  // addi x1, x0, 1000
    axi_slave_bfm_inst.ram_array[1] = 32'b01111101000000001000000100010011;  // addi x2, x1, 2000
    axi_slave_bfm_inst.ram_array[2] = 32'b11000001100000010000000110010011;  // addi x3, x2, -1000
    axi_slave_bfm_inst.ram_array[3] = 32'b10000011000000011000001000010011;  // addi x4, x3, -2000
    axi_slave_bfm_inst.ram_array[4] = 32'b00111110100000100000001010010011;  // addi x5, x4, 1000

    // 余白
    for (i = 5; i < 1024*2; i = i + 1)
        axi_slave_bfm_inst.ram_array[i] = 0;
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
