#ifndef MYCPU_H
#define MYCPU_H

#define CRST 	(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0000))
#define CEXEC 	(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0004))
#define CEXEC1 	(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0008))

#define INSTRAM ((volatile unsigned int *)0x20000000)
#define REG 	((volatile unsigned int *)(XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x1000))

void write_instructions(unsigned int *instructions);
void view_registers();
void exec_on_origcpu(unsigned int *instructions);

#endif
