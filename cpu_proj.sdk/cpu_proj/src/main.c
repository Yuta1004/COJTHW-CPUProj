#include <xil_cache.h>
#include <ff.h>

#define CEXEC	(*(volatile unsigned int*)(XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0000))
#define CEXEC1 	(*(volatile unsigned int*)(XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0004))
#define REG 	( (volatile unsigned int*)(XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x1000))

void deploy_to_ram(unsigned int *addr, const char *fname) {
	UINT num;
	FATFS FatFs;
	FRESULT fr;
	FIL Fil;
	char buff[4100];

	f_mount(&FatFs, "", 0);
	fr = f_open(&Fil, fname, FA_READ);
	if (!fr) {
		while(1) {
			f_read(&Fil, buff, 4096, &num);
			for (int idx = 0; idx < num; idx += 4) {
				*(addr++) = (buff[idx+3] << 24) | (buff[idx+2] << 16) | (buff[idx+1] << 8) | buff[idx];
			}
			if (num < 4096)
				break;
		}
		f_close(&Fil);
	}
}

int main() {
	Xil_DCacheDisable();

	deploy_to_ram((unsigned int*)0x20000000, "kernel.raw");
	deploy_to_ram((unsigned int*)0x25000000, "fs.raw");
	CEXEC = 1;

	while (1) {}
}
