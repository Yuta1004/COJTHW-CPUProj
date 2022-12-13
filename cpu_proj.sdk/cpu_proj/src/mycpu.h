#ifndef MYCPU_H
#define MYCPU_H

#define RESOL_SET 	(*(volatile unsigned int *) (XPAR_AXI_GPIO_0_BASEADDR + 0x00))
#define RESOL_CTRL  (*(volatile unsigned int *) (XPAR_AXI_GPIO_0_BASEADDR + 0x04))
#define VGA 		0x00
#define XGA			0x01
#define SXGA 		0x02

#define CEXEC 		(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0000))
#define CEXEC1 		(*(volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x0004))
#define REG 		((volatile unsigned int *) (XPAR_CPU_CORE_CONTROLLER_0_S_AXI_BASEADDR + 0x1000))
#define INSTRAM 	((volatile unsigned int *) 0x20000000)

void write_instructions(unsigned int *instructions);
void view_registers();
void exec_on_origcpu(unsigned int *instructions);

#endif
