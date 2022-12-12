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
	init_tpf410();
	init_xclk(XCLK24MHz);
	init_ov9655(OV9655_SXGA);

	exec_on_origcpu(ADDI_REQUIRE_FORWARD);

	return 0;
}
