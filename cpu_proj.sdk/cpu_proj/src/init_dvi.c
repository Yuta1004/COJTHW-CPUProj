//-----------------------------------------------------------------------------
// Title       : DVIチップの初期化（本体）
// Project     : 表示を行うすべてのプロジェクト
// Filename    : init_dvi.c
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2014/04/08  1.00     M.Kobayashi   Created
//-----------------------------------------------------------------------------

#include "xgpio_l.h"
#include "init_dvi.h"

void init_iic( void ) {
    Xil_Out32(IIC_CTRLREG, 0x02);	// reset tx fifo
    Xil_Out32(IIC_CTRLREG, 0x01);	// enable iic
}

void iic_write(u32 daddr, u32 waddr, u32 wdata) {
    Xil_Out32(IIC_TXREG, (0x100 | daddr)); // select
    Xil_Out32(IIC_TXREG, waddr); // address
    Xil_Out32(IIC_TXREG, (0x200 | wdata)); // data
    while ((Xil_In32(IIC_STATUSREG) &
            (IIC_TX_FIFO_EMPTY | IIC_BUS_BUSY)) != IIC_TX_FIFO_EMPTY);
}

void iic_switch( int IICSEL ){
    init_iic();
    Xil_Out32(IIC_TXREG, (0x100 | 0xE0)); // IIC Switch device addr
    Xil_Out32(IIC_TXREG, (0x200 | IICSEL));
    while ((Xil_In32(IIC_STATUSREG) &
            (IIC_TX_FIFO_EMPTY | IIC_BUS_BUSY)) != IIC_TX_FIFO_EMPTY);
}

void init_tpf410( void ){
    iic_switch(IIC_SEL_DVI);
    Xil_Out32(IIC_GPIO, 0);          // IIC GPO: HDMI_RST# = 0
    Xil_Out32(IIC_GPIO, 0xFFFFFFFF); // IIC GPO: HDMI_RST# = 1
    iic_write(0x70, 0x08, 0x39);  // DSEL=1, BSEL=0, EDGE=0
}
