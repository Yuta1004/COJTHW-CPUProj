#include "xil_printf.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "cojt.h"
#include "mycpu.h"

void write_instructions(unsigned int *instructions) {
	unsigned int *wp = INSTRAM;
	unsigned int *inst = instructions;

	while (*inst != 0) {
		*(wp++) = *(inst++);
	}
	*(wp++) = 0x0000006f;	// jal x0, 0

	Xil_DCacheFlushRange((unsigned int)INSTRAM, wp - inst);
}

void view_registers() {
	xil_printf("PC = %08x (%8d)\n", REG[32], REG[32]);
	for (int i = 0; i < 32; ++ i) {
		xil_printf("REG[%2d] = %08x (%8d)", i, REG[i], REG[i]);
		xil_printf(i % 4 == 3 ? "\n" : "\t\t\t");
	}
	xil_printf("\n");
}
