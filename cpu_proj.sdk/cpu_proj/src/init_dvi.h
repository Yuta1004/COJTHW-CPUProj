//-----------------------------------------------------------------------------
// Title       : DVIチップの初期化（ヘッダファイル）
// Project     : 表示を行うすべてのプロジェクト
// Filename    : init_dvi.h
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2014/04/08  1.00     M.Kobayashi   Created
//-----------------------------------------------------------------------------

#ifndef INIT_DVI_H_
#define INIT_DVI_H_

#include "xparameters.h"
#include "xil_types.h"

#define IIC_BASEADDR XPAR_AXI_IIC_0_BASEADDR
#define IIC_CTRLREG   (IIC_BASEADDR + 0x100)
#define IIC_STATUSREG (IIC_BASEADDR + 0x104)
#define IIC_TXREG     (IIC_BASEADDR + 0x108)
#define IIC_GPIO      (IIC_BASEADDR + 0x124)

#define IIC_SEL_DVI  0x04
#define IIC_TX_FIFO_EMPTY 0x80
#define IIC_BUS_BUSY      0x04
#define IIC_TX_FIFO_FULL  0x10

void init_iic( void );
void iic_write(u32, u32, u32);
void iic_switch( int );
void init_tpf410( void );

#endif /* INIT_DVI_H_ */
