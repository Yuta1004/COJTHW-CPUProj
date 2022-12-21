#include <unistd.h>

#include "xil_printf.h"
#include "xil_cache.h"
#include "xparameters.h"
#include "ff.h"

#include "cojt.h"
#include "mycpu.h"

void write_instructions(unsigned int *instructions) {
	unsigned int *wp = INSTRAM;
	unsigned int *inst = instructions;

	while (*inst != 0) {
		*(wp++) = *(inst++);
	}
	*(wp++) = 0x0000006f;	// jal x0, 0
}

void write_instructions_f(const char *pfile) {
	UINT num;
	FATFS FatFs;
	FRESULT fr;
	FIL Fil;
	char buff[4100];

	unsigned int *inst_wp = INSTRAM;

	f_mount(&FatFs, "", 0);
	fr = f_open(&Fil, pfile, FA_READ);
	if (!fr) {
		while(1) {
			f_read(&Fil, buff, 4096, &num);
			for (int idx = 0; idx < num; idx += 4) {
				*(inst_wp++) = (buff[idx+3] << 24) | (buff[idx+2] << 16) | (buff[idx+1] << 8) | buff[idx];
			}
			if (num < 4096)
				break;
		}
		f_close(&Fil);
	} else {
		xil_printf("File open error!\n");
	}
}

void view_registers() {
	xil_printf("PC = %08x (%8d)\n", REG[32], REG[32]);
	for (int i = 0; i < 32; ++ i) {
		xil_printf("REG[%2d] = %08x (%8d)", i, REG[i], REG[i]);
		xil_printf(i % 4 == 3 ? "\n" : "\t\t\t");
	}
	xil_printf("\n");
}


void exec_on_origcpu() {
	CEXEC = 1; sleep(1);
	CEXEC = 0; sleep(1);
	view_registers();
}
