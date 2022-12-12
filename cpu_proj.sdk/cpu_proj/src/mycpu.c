#include "xil_printf.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "cojt.h"
#include "mycpu.h"

void write_instructions(unsigned int *instructions) {
	unsigned int *inst = instructions;

	int page = 0;
	for (; *inst != 0; ++ page) {
		for (int idx = 0; idx < 1024; ++ idx) {
			Xil_Out32((unsigned int)(INSTRAM + page*1024 + idx), 0);
		}
		for (int idx = 0; *inst != 0; ++ idx) {
			Xil_Out32((unsigned int)(INSTRAM + page*1024 + idx), *(inst++));
			++ idx;
		}
	}

	Xil_DCacheFlushRange((unsigned int)INSTRAM, 4 * 1024 * (page+1));
}

void view_registers() {
	xil_printf("PC = %08x (%8d)\n", REG[32], REG[32]);
	for (int i = 0; i < 32; ++ i) {
		xil_printf("REG[%2d] = %08x (%8d)", i, REG[i], REG[i]);
		xil_printf(i % 4 == 3 ? "\n" : "\t\t\t");
	}
	xil_printf("\n");
}
