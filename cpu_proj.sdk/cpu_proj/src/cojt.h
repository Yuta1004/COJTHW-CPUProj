//-----------------------------------------------------------------------------
// Title       : 各課題共通のレジスタおよび定数の宣言
// Project     : 表示回路以降のプロジェクト
// Filename    : cojt.h
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2014/04/06  1.00     M.Kobayashi   Created
// 2014/04/23  1.10     M.Kobayashi   Modified
// 2014/07/28  1.20     M.Kobayashi   描画およびサウンド回路のレジスタを追加
// 2014/09/22  1.30     M.Kobayashi   PS/2マウス回路のレジスタを追加
// 2015/03/11  1.31     M.Kobayashi   マウス未実装システム対策他
// 2017/04/10  1.32     M.Kobayashi   グローバル変数はcojt.cで宣言（SDK C++対策）
//-----------------------------------------------------------------------------

#ifndef COJT_H_
#define COJT_H_

#include "xparameters.h"
#ifndef XPAR_PS2IF_0_BASEADDR   /* マウス未実装システム対策 */
    #define XPAR_PS2IF_0_BASEADDR 0x60000000
#endif
#ifndef XPAR_AXI_GPIO_0_BASEADDR   /* 解像度切り替え未実装システム対策 */
    #define XPAR_AXI_GPIO_0_BASEADDR 0x61000000
#endif
#include "xscugic.h"

/* 割り込み関連 */
typedef void (*CojtCtr_Handler) ( void );

typedef struct {
    CojtCtr_Handler Handler;
    void *CallBackRef;
} CojtCtr;

extern XScuGic InterruptController; /* Instance of the Interrupt Controller */
extern XScuGic_Config *GicConfig;/* The configuration parameters of the　controller */

int ScuGicInt_Init( void );
int ScuGicInt_Reg(u32, CojtCtr *, void *);

/* 解像度 */
#define RESOLUTION (*(volatile unsigned int *) (XPAR_AXI_GPIO_0_BASEADDR + 0x00))
#define RESOL_CTRL (*(volatile unsigned int *) (XPAR_AXI_GPIO_0_BASEADDR + 0x04))

#define VGA  0
#define XGA  1
#define SXGA 2

/* 表示回路のレジスタ */
#define DISPADDR (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x0000))
#define DISPCTRL (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x0004))
#define DISPINT  (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x0008))
#define DISPFIFO (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x000c))

#define VBLANK      0x02
#define DISPON      0x01
#define DISPOFF     0x00
#define DISPINTENBL 0x01
#define DISPINTCLR  0x02
#define DSP_FIFO_OVER  0x02
#define DSP_FIFO_UNDER 0x01

/* キャプチャ回路のレジスタ */
#define CAPADDR (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x1000))
#define CAPCTRL (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x1004))
#define CAPINT  (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x1008))
#define CAPFIFO (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x100c))

#define CBLANK     0x02
#define CAPON      0x01
#define CAPOFF     0x00
#define CAPINTENBL 0x01
#define CAPINTCLR  0x02
#define CAP_FIFO_OVER  0x02
#define CAP_FIFO_UNDER 0x01

/* 描画回路のレジスタ */
#define DRAWCTRL    (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x2000))
#define DRAWSTAT    (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x2004))
#define DRAWBUFSTAT (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x2008))
#define DRAWCMD     (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x200c))
#define DRAWINT     (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x2010))

#define DRAWRST     0x02
#define DRAWEXE     0x01
#define DRAWBUSY    0x01
#define DRAWINTENBL 0x01
#define DRAWINTCLR  0x02

/* サウンド回路のレジスタ */
#define SNDADDR (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x3000))
#define SNDSIZE (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x3004))
#define SNDVOL  (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x3008))
#define SNDCTRL (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x300c))
#define SNDSTAT (*(volatile unsigned int *) (XPAR_REGBUS_0_BASEADDR + 0x3010))

#define SNDPLAY    0x01
#define SNDPAUSE   0x02
#define SNDSTOP    0x03
#define SNDLOOP    0x04
#define SNDBUSY    0x01

/* PS/2マウス回路のレジスタ */
#define PS2_XPOS  *((volatile unsigned int *) (XPAR_PS2IF_0_BASEADDR + 0x0000) )
#define PS2_YPOS  *((volatile unsigned int *) (XPAR_PS2IF_0_BASEADDR + 0x0004) )
#define PS2_ZPOS  *((volatile unsigned int *) (XPAR_PS2IF_0_BASEADDR + 0x0008) )
#define PS2_BTN   *((volatile unsigned int *) (XPAR_PS2IF_0_BASEADDR + 0x000C) )
#define PS2_CTRL  *((volatile unsigned int *) (XPAR_PS2IF_0_BASEADDR + 0x0010) )
#define PS2_RESOL *((volatile unsigned int *) (XPAR_PS2IF_0_BASEADDR + 0x0014) )

#define PS2VALID  0x01

#define MOUSE_FAST  0
#define MOUSE_NORM  1
#define MOUSE_SLOW  2
#define MOUSE_SLOW2 3

#define MOUSE_LEFT   0x04
#define MOUSE_CENTER 0x02
#define MOUSE_RIGHT  0x01

/* 表示用変数 */
extern int XSIZE, YSIZE;
extern unsigned int *VRAM;

/* 表示およびキャプチャ回路用関数 */
void set_resolution( int resol );
void wait_vblank( void );
void wait_cblank( void );
void drawbox(int xpos, int ypos, int width, int height, int col);
void setVRAM( int page );
void set_disp_page( int page  );
void set_cap_page( int page  );

/* PS/2マウス用関数 */
void init_mouse(int disp_resol, int mouse_speed);
int  get_mouse( int *xpos, int *ypos, int *zpos, int *button );

#endif /* COJT_H_ */
