#ifndef MYCPU_H
#define MYCPU_H

#define CRST (*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0000))
#define REG ((volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x1000))

#endif
