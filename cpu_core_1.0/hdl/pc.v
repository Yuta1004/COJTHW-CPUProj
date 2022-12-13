//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I) : Program Counter
// Project     : cpu_proj
// Filename    : pc.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/14  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module pc
    (
        /* ----- クロック&リセット信号 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- 上位との接続用 ----- */
        // 制御
        input wire          STALL,
        input wire          FLUSH,
        input wire  [31:0]  NEW_PC,

        // 入力
        input               EXEC,

        // 出力
        output reg  [31:0]  P_PC,
        output reg          P_VALID
    );

    /* ----- プログラムカウンタ ----- */
    reg delayed_exec, delayed_flush;

    always @ (posedge CLK) begin
        delayed_exec <= EXEC;
        delayed_flush <= FLUSH;
    end

    always @ (posedge CLK) begin
        if (RST)
            P_PC <= 32'h2000_0000;
        else if (FLUSH)
            P_PC <= NEW_PC;
        else if (delayed_exec && !STALL)
            P_PC <= P_PC + 32'd4;
    end

    always @ (posedge CLK) begin
        if (RST)
            P_VALID <= 1'b0;
        else if (EXEC && !STALL)
            P_VALID <= 1'b1;
        else if (!EXEC)
            P_VALID <= 1'b0;
    end

endmodule
