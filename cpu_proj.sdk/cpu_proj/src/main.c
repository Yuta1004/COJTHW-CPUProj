#include <xparameters.h>
#include <xil_cache.h>
#include <ff.h>

#include "mycpu.h"
#include "riscv_program.h"

int main() {
	Xil_DCacheDisable();

//	init_tpf410();
//	init_xclk(XCLK24MHz);
//	init_ov9655(OV9655_SXGA);
//	RESOL_CTRL = 0;
//	RESOL_SET = SXGA;

//	write_instructions(ADDI_REQUIRE_FORWARD);
//	write_instructions(BEQ);
//	write_instructions(SIMPLE_CALC);
//	write_instructions(LOGIC_CALC_1);
//	write_instructions(SHIFT_CALC);
//	write_instructions(LOGIC_CALC_2);
//	write_instructions(BRANCH_BLT_1);
//	write_instructions(BRANCH_BLT_2);
//	write_instructions(BRANCH_BLTU_1);
//	write_instructions(BRANCH_BLTU_2);
//	write_instructions(WRITE_MEM);
//	write_instructions(CAP_DISP_CONTROL);
//	write_instructions(UART_HELLOWORLD);
//	write_instructions(MEM_W);
//	write_instructions(MEM_RW);
	write_instructions_f("out.raw");

	exec_on_origcpu();

	return 0;
}
