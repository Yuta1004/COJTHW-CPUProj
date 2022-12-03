//-----------------------------------------------------------------------------
// Title       : 拡張ボード上のクロックシンセサイザの初期化関数
// Project     : キャプチャ回路
// Filename    : init_xclk.c
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2014/02/22  1.00     M.Kobayashi   Created
//-----------------------------------------------------------------------------

#include "init_dvi.h"
#include "init_xclk.h"

#define CDCE925_BYTE_RW 0x80

void init_xclk( unsigned char *XCLK ) {
    int i;
    iic_switch(IIC_SEL_DVI);
    for ( i=0; i<48; i++ ) {
        iic_write(0xC8, CDCE925_BYTE_RW | i, XCLK[i]);
    }
}
