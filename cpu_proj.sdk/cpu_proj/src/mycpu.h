#ifndef MYCPU_H
#define MYCPU_H

#define CRST 	(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0000))
#define CEXEC 	(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0004))
#define CEXEC1 	(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0008))
#define REG 	((volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x1000))

#endif
