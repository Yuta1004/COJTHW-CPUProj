//-----------------------------------------------------------------------------
// Title       : SCCB回路経由でカメラ「OV9655」を初期化
// Project     : キャプチャ回路
// Filename    : init_ov9655.c
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2014/02/22  1.00     M.Kobayashi   Created
//-----------------------------------------------------------------------------

#include "xgpio_l.h"
#include "xil_types.h"
#include "xparameters.h"
#include "init_ov9655.h"

void sccb_write(u32 daddr, u32 waddr, u32 wdata) {
    while ( (Xil_In32(SCCB_STAT) & SCCB_BUSY) !=0 );
    Xil_Out32(SCCB_DATA, (daddr<<16) | (waddr<<8) | wdata);
}

void init_ov9655( unsigned char* ov9655 ) {
    int i = 0;
    while (1) {
        if ( ov9655[i]==0xff && ov9655[i+1]==0xff )
            return;
        else
            sccb_write( 0x60, ov9655[i], ov9655[i+1]);
        i += 2;
    }
}
