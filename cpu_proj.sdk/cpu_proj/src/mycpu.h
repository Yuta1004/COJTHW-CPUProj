#ifndef MYCPU_H
#define MYCPU_H

#define CRST 	(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0000))
#define CEXEC 	(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0004))
#define CEXEC1 	(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0008))

static volatile unsigned int* INST = (volatile unsigned int *)0x20000000;
static volatile unsigned int* REG = (volatile unsigned int *)(XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x1000);

void write_inst_list(unsigned int *inst_list) {
	for (int idx = 0; *inst_list != 0; ++ inst_list) {
		INST[idx] = *inst_list;
	}
}

#endif
