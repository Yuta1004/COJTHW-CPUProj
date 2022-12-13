//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I) : Write back
// Project     : cpu_proj
// Filename    : wb.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/10  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module wb
    (
        /* ----- クロック&リセット信号 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- 上位との接続用 ----- */
        // 制御
        input wire          STALL,
        input wire          FLUSH,

        // 入力
        input wire  [31:0]  M_PC,
        input wire  [31:0]  M_INST,
        input wire          M_VALID,
        input wire  [4:0]   M_REG_D,
        input wire  [31:0]  M_REG_D_V,
        // output wire [31:0]  M_LOAD_ADDR,
        // output wire [31:0]  M_LOAD_STRB,
        // output wire [31:0]  M_STORE_ADDR,
        // output wire [31:0]  M_STORE_STRB,
        // output wire [31:0]  M_STORE_DATA

        // 出力
        output wire [31:0]  W_PC,
        output wire [31:0]  W_INST,
        output wire         W_VALID,
        output wire [4:0]   W_REG_D,
        output wire [31:0]  W_REG_D_V
        // output wire [31:0]  W_LOAD_STRB,
        // output wire [31:0]  W_LOAD_DATA,
        // output wire [31:0]  W_STORE_ADDR,
        // output wire [31:0]  W_STORE_STRB,
        // output wire [31:0]  W_STORE_DATA
    );

    /* ----- 入力(ラッチ取り込み) ----- */
    reg [31:0]  pc, inst;
    reg         valid;
    reg [4:0]   reg_d;
    reg [31:0]  reg_d_v;

    always @ (posedge CLK) begin
        if (RST) begin
            pc <= 32'b0;
            inst <= 32'b0;
            valid <= 1'b0;
            reg_d <= 5'b0;
            reg_d_v <= 5'b0;
        end
        else if (STALL)
            ;
        else if (FLUSH) begin
            pc <= 32'b0;
            inst <= 32'b0;
            valid <= 1'b0;
            reg_d <= 5'b0;
            reg_d_v <= 5'b0;
        end
        else begin
            pc <= M_PC;
            inst <= M_INST;
            valid <= M_VALID;
            reg_d <= M_REG_D;
            reg_d_v <= M_REG_D_V;
        end
    end

    /* ----- 出力 ----- */
    assign W_PC         = pc;
    assign W_INST       = inst;
    assign W_VALID      = valid;
    assign W_REG_D      = reg_d;
    assign W_REG_D_V    = reg_d_v;

endmodule
