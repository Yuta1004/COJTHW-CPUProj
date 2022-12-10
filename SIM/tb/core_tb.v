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
reg             CEXEC;
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
wire            EXEC_           = CEXEC;
wire [31:0]     PC              = core.inst_fetch.PC;
wire            INST_VALID      = core.inst_fetch.INST_VALID;
wire [31:0]     INST            = core.inst_fetch.INST;

/* ----- メモリ(命令)書き込み ----- */
task write_inst;
integer i;
begin
    for (i = 0; i < 1024*2; i = i + 1)
        axi_slave_bfm_inst.ram_array[i] = i;
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
    CEXEC = 0;
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
    CEXEC = 1;
    #(STEP*4500);

    $stop;
end

endmodule
