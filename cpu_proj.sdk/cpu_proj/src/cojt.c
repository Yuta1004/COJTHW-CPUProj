//-----------------------------------------------------------------------------
// Title       : 各課題で共有する関数
// Project     : 表示回路以降のプロジェクト
// Filename    : cojt.c
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2014/04/06  1.00     M.Kobayashi   Created
// 2014/04/23  1.10     M.Kobayashi   Modified
// 2014/09/22  1.20     M.Kobayashi   PS/2マウス用の関数を追加
// 2017/04/10  1.21     M.Kobayashi   グローバル変数はcojt.cで宣言（SDK C++対策）
//-----------------------------------------------------------------------------

#include "xil_printf.h"
#include "xparameters.h"
#include "cojt.h"

/* 表示用変数 */
int XSIZE, YSIZE;
unsigned int *VRAM;

/* 割り込み関連 */
XScuGic InterruptController; /* Instance of the Interrupt Controller */
XScuGic_Config *GicConfig;/* The configuration parameters of the　controller */

/* 割り込みコントローラの初期化 */
int ScuGicInt_Init( void )
{
    int Status;
    /*
     * Initialize the interrupt controller driver so that it is ready to
     * use.
     * */
    GicConfig = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
    if (NULL == GicConfig) {
        xil_printf("SCUGIC INIT FAILED \n");
        return XST_FAILURE;
    }
    Status = XScuGic_CfgInitialize(&InterruptController, GicConfig,
            GicConfig->CpuBaseAddress);
    if (Status != XST_SUCCESS) {
        xil_printf("SCUGIC INIT FAILED \n");
        return XST_FAILURE;
    }
    /*
     * Connect the interrupt controller interrupt handler to the hardware
     * interrupt handling logic in the ARM processor.
     */
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
            (Xil_ExceptionHandler) XScuGic_InterruptHandler,
            &InterruptController);
    /*
     * Enable interrupts in the ARM
     */
    Xil_ExceptionEnable();
    return XST_SUCCESS;
}

/* 割り込み処理関数の登録 */
int ScuGicInt_Reg(u32 Int_Id, CojtCtr *InstancePtr, void *IntHandler)
{
    int Status;
    /*
     * Connect a device driver handler that will be called when an
     * interrupt for the device occurs, the device driver handler performs
     * the specific interrupt processing for the device
     */
    Status = XScuGic_Connect(&InterruptController,
            Int_Id,
            (Xil_ExceptionHandler)IntHandler,
            (void *)InstancePtr);
    if (Status != XST_SUCCESS) {
        xil_printf("Int_Id=%d SCUGIC REGISTRATION FAILED \n", Int_Id);
        return XST_FAILURE;
    }
    /*
     * Enable the interrupt for the device and then cause (simulate) an
     * interrupt so the handlers will be called
     */
    XScuGic_Enable(&InterruptController, Int_Id);
    return XST_SUCCESS;
}

/* 表示回路のVBLANK待ち */
void wait_vblank( void ) {
    DISPCTRL |= VBLANK;
    while( (DISPCTRL & VBLANK) == 0 );
}

/* キャプチャ回路のCBLANK待ち */
void wait_cblank( void ) {
    CAPCTRL |= CBLANK;
    while( (CAPCTRL & CBLANK) == 0 );
}

/* 解像度設定 */
void set_resolution( int resol ) {
    RESOL_CTRL = 0;
    RESOLUTION = resol;
    if ( resol==VGA ) {
        XSIZE=640;
        YSIZE=480;
    }
    else if  ( resol==XGA ) {
        XSIZE=1024;
        YSIZE=768;
    }
    else if ( resol==SXGA ) {
        XSIZE=1280;
        YSIZE=1024;
    }
}

/* 原点（xpos, ypos)、大きさ（width, height）、色（color）を指定して箱を書く */
void drawbox( int xpos, int ypos, int width, int height, int col ) {
    int x, y;

    for ( x=xpos; x<xpos+width; x++ ) {
        VRAM[ ypos*XSIZE + x ] = col;
        VRAM[ (ypos+height-1)*XSIZE + x ] = col;
    }
    for ( y=ypos; y<ypos+height; y++ ) {
        VRAM[ y*XSIZE + xpos ] = col;
        VRAM[ y*XSIZE + xpos + width -1 ] = col;
    }
}

/* ポインタ変数VRAMのアドレス設定 */
void setVRAM( int page ) {
    VRAM = (unsigned int *)(0x20000000 + XSIZE*YSIZE*4*page);
}

/* 表示先頭アドレスレジスタDISPADDRのアドレス設定 */
void set_disp_page( int page ) {
    DISPADDR = 0x20000000 + XSIZE*YSIZE*4*page;
}

/* キャプチャ先頭アドレスレジスタCAPADDRのアドレス設定 */
void set_cap_page( int page ) {
    CAPADDR = 0x20000000 + XSIZE*YSIZE*4*page;
}

/* PS/2マウスの初期化                                                    */
/* 表示の解像度を設定すると、マウス位置はその範囲に収まる                */
/* 左上が(0, 0)、右下が(XSIZE-1, YSIZE-1)となる                          */
/* マウス速度は、MOUSE_FAST，MOUSE_NORM, MOUSE_SLOW, MOUSE_SLOW2 の4段階 */
/* PS/2マウス回路を初期化すると、マウス位置は設定解像度の中心座標になる  */

void init_mouse(int disp_resol, int mouse_speed)
{
    PS2_CTRL  = 0x02;
    PS2_RESOL = 0x10 | (disp_resol<<2) | mouse_speed;
}

/* PS/2マウスからデータ取得                                */
/* マウス位置やボタンに変化があれば1、なければ0を返す      */
/* xpos:右側がプラス、ypos:下側がプラス、zpos:手前がプラス */
/* zposは4ビットの2の補数値。手前は0、1～、奥側はF、E、～  */
/* button: 下位3ビットが左、中、右に対応。押せば1、離せば0 */

int get_mouse( int *xpos, int *ypos, int *zpos, int *button )
{
    if ( (PS2_CTRL & PS2VALID) !=0 ) {
        *xpos   = PS2_XPOS;
        *ypos   = PS2_YPOS;
        *zpos   = PS2_ZPOS;
        *button = PS2_BTN;
        PS2_CTRL &= ~PS2VALID;
        return(1);
    }
    else
        return(0);
}
