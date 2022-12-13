#include <stdio.h>
#include <xparameters.h>
#include <xil_cache.h>

#include "init_dvi.h"
#include "init_ov9655.h"
#include "init_xclk.h"
#include "cojt.h"
#include "mycpu.h"
#include "riscv_program.h"

int main() {
	Xil_DCacheDisable();

	init_tpf410();
	init_xclk(XCLK24MHz);
	init_ov9655(OV9655_SXGA);
	RESOL_CTRL = 0;
	RESOL_SET = SXGA;

//	exec_on_origcpu(ADDI_REQUIRE_FORWARD);
//	exec_on_origcpu(BEQ);
//	exec_on_origcpu(SIMPLE_CALC);
//	exec_on_origcpu(LOGIC_CALC_1);
//	exec_on_origcpu(SHIFT_CALC);
//	exec_on_origcpu(LOGIC_CALC_2);
//	exec_on_origcpu(BRANCH_BLT_1);
//	exec_on_origcpu(BRANCH_BLT_2);
//	exec_on_origcpu(BRANCH_BLTU_1);
//	exec_on_origcpu(BRANCH_BLTU_2);
//	exec_on_origcpu(WRITE_MEM);
	exec_on_origcpu(CAP_DISP_CONTROL);

	return 0;
}
