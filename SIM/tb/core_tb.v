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

localparam integer ASTEP  = 1000 / 125; // 125MHz
localparam integer CSTEP  = 1000 / 1;   // 1Mhz

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

/* ----- システムクロックおよびリセット ----- */
reg ACLK;
reg ARESETN;

always begin
    ACLK = 0; #(ASTEP/2);
    ACLK = 1; #(ASTEP/2);
end

/* ----- Core用クロックおよびリセット ----- */
reg CCLK;
reg CRST;

always begin
    CCLK = 0; #(CSTEP/2);
    CCLK = 1; #(CSTEP/2);
end

/* ----- 共通化した接続部分の記述を読み込む ----- */
`include "core_axibfm.vh"

/* ----- メモリ(命令)書き込み ----- */
task write_inst;
begin
    axi_slave_bfm_inst.ram_array[0] = 32'h0000_0000;
end
endtask

/* ----- メモリ(データ)書き込み ----- */
task write_data;
begin
    axi_slave_bfm_data.ram_array[0] = 32'h0000_0000;
end
endtask

/* ----- テストベンチ本体 ----- */
initial begin
    ARESETN = 1;
    CRST = 0;
    CEXEC = 0;

    // メモリ初期化
    write_inst;
    write_data;

    // リセット(ACLK系)
    #ASTEP;
    ARESETN = 0;
    #(ASTEP*10);
    ARESETN = 1;

    // リセット(CCLK系)
    #(CSTEP - ASTEP*11)
    #(CSTEP/2);
    CRST = 1;
    #CSTEP;
    CRST = 0;

    // 実行
    #(CSTEP*2);
    CEXEC = 1;
    #(CSTEP*10);
    CEXEC = 0;

    $stop;
end

endmodule
