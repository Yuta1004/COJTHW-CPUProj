//-----------------------------------------------------------------------------
// Title       : core�̃e�X�g�x���`�i�X���[�uBFM�Ƃ̒����ɂ��P�̌��؁j
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

/* ----- �e��萔 ----- */
localparam integer C_AXI_DATA_WIDTH = 32;
localparam integer C_OFFSET_WIDTH = 28;
localparam integer STEP  = 1000 / 50;   // 50Mhz

/* ----- Core�Ƃ̐ڑ��p ----- */
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

/* ----- �N���b�N&���Z�b�g�M�� ----- */
reg CLK;
reg RST;

always begin
    CLK = 0; #(STEP/2);
    CLK = 1; #(STEP/2);
end

/* ----- ���ʉ������ڑ������̋L�q��ǂݍ��� ----- */
`include "core_axibfm.vh"

/* ----- �Ď��ΏېM�� ----- */
// �S�̐���
wire            STALL           = core.stall;
wire            INST_MEM_WAIT   = core.inst_fetch.MEM_WAIT;

// ���߃t�F�b�`
wire            EXEC_           = CEXEC;
wire [31:0]     PC              = core.inst_fetch.PC;
wire            INST_VALID      = core.inst_fetch.INST_VALID;
wire [31:0]     INST            = core.inst_fetch.INST;

/* ----- ������(����)�������� ----- */
task write_inst;
integer i;
begin
    for (i = 0; i < 1024*2; i = i + 1)
        axi_slave_bfm_inst.ram_array[i] = i;
end
endtask

/* ----- ������(�f�[�^)�������� ----- */
task write_data;
integer i;
begin
    for (i = 0; i < 1024*2; i = i + 1)
        axi_slave_bfm_data.ram_array[i] = 0;
end
endtask

/* ----- �e�X�g�x���`�{�� ----- */
initial begin
    RST = 0;
    CEXEC = 0;
    #(STEP*10)

    // ������������
    write_inst;
    write_data;

    // ���Z�b�g
    RST = 1;
    #(STEP*10);
    RST = 0;

    // ���s
    #(STEP*5);
    CEXEC = 1;
    #(STEP*4500);

    $stop;
end

endmodule
