//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I) : Register
// Project     : cpu_proj
// Filename    : mem/register.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/15  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module register
    (
        /* ----- クロック&リセット信号 ----- */
        input               CLK,
        input               RST,

        /* ----- 制御信号 ----- */
        input wire          STALL,
        input wire          FLUSH,

        /* ----- レジスタアクセス用信号 ----- */
        input wire          WRVALID,
        input wire  [4:0]   WRADDR,
        input wire  [31:0]  WRDATA,

        input wire  [4:0]   RDADDR_1,
        output wire [31:0]  RDDATA_1,

        input wire  [4:0]   RDADDR_2,
        output wire [31:0]  RDDATA_2,

        /* ----- レジスタ ----- */
        output reg  [31:0]  REG01,
        output reg  [31:0]  REG02,
        output reg  [31:0]  REG03,
        output reg  [31:0]  REG04,
        output reg  [31:0]  REG05,
        output reg  [31:0]  REG06,
        output reg  [31:0]  REG07,
        output reg  [31:0]  REG08,
        output reg  [31:0]  REG09,
        output reg  [31:0]  REG10,
        output reg  [31:0]  REG11,
        output reg  [31:0]  REG12,
        output reg  [31:0]  REG13,
        output reg  [31:0]  REG14,
        output reg  [31:0]  REG15,
        output reg  [31:0]  REG16,
        output reg  [31:0]  REG17,
        output reg  [31:0]  REG18,
        output reg  [31:0]  REG19,
        output reg  [31:0]  REG20,
        output reg  [31:0]  REG21,
        output reg  [31:0]  REG22,
        output reg  [31:0]  REG23,
        output reg  [31:0]  REG24,
        output reg  [31:0]  REG25,
        output reg  [31:0]  REG26,
        output reg  [31:0]  REG27,
        output reg  [31:0]  REG28,
        output reg  [31:0]  REG29,
        output reg  [31:0]  REG30,
        output reg  [31:0]  REG31
    );

    // 読み
    assign RDDATA_1 = select_reg(
        RDADDR_1,
        REG01, REG02, REG03, REG04, REG05, REG06, REG07, REG08, REG09, REG10,
        REG11, REG12, REG13, REG14, REG15, REG16, REG17, REG18, REG19, REG20,
        REG21, REG22, REG23, REG24, REG25, REG26, REG27, REG28, REG29, REG30, REG31
    );
    assign RDDATA_2 = select_reg(
        RDADDR_2,
        REG01, REG02, REG03, REG04, REG05, REG06, REG07, REG08, REG09, REG10,
        REG11, REG12, REG13, REG14, REG15, REG16, REG17, REG18, REG19, REG20,
        REG21, REG22, REG23, REG24, REG25, REG26, REG27, REG28, REG29, REG30, REG31
    );

    function [31:0] select_reg;
        input [4:0]  TARGET_REG;
        input [31:0] REG01;
        input [31:0] REG02;
        input [31:0] REG03;
        input [31:0] REG04;
        input [31:0] REG05;
        input [31:0] REG06;
        input [31:0] REG07;
        input [31:0] REG08;
        input [31:0] REG09;
        input [31:0] REG10;
        input [31:0] REG11;
        input [31:0] REG12;
        input [31:0] REG13;
        input [31:0] REG14;
        input [31:0] REG15;
        input [31:0] REG16;
        input [31:0] REG17;
        input [31:0] REG18;
        input [31:0] REG19;
        input [31:0] REG20;
        input [31:0] REG21;
        input [31:0] REG22;
        input [31:0] REG23;
        input [31:0] REG24;
        input [31:0] REG25;
        input [31:0] REG26;
        input [31:0] REG27;
        input [31:0] REG28;
        input [31:0] REG29;
        input [31:0] REG30;
        input [31:0] REG31;

        case (TARGET_REG)
            5'd0:  select_reg = 32'b0;
            5'd1:  select_reg = REG01;
            5'd2:  select_reg = REG02;
            5'd3:  select_reg = REG03;
            5'd4:  select_reg = REG04;
            5'd5:  select_reg = REG05;
            5'd6:  select_reg = REG06;
            5'd7:  select_reg = REG07;
            5'd8:  select_reg = REG08;
            5'd9:  select_reg = REG09;
            5'd10: select_reg = REG10;
            5'd11: select_reg = REG11;
            5'd12: select_reg = REG12;
            5'd13: select_reg = REG13;
            5'd14: select_reg = REG14;
            5'd15: select_reg = REG15;
            5'd16: select_reg = REG16;
            5'd17: select_reg = REG17;
            5'd18: select_reg = REG18;
            5'd19: select_reg = REG19;
            5'd20: select_reg = REG20;
            5'd21: select_reg = REG21;
            5'd22: select_reg = REG22;
            5'd23: select_reg = REG23;
            5'd24: select_reg = REG24;
            5'd25: select_reg = REG25;
            5'd26: select_reg = REG26;
            5'd27: select_reg = REG27;
            5'd28: select_reg = REG28;
            5'd29: select_reg = REG29;
            5'd30: select_reg = REG30;
            5'd31: select_reg = REG31;
            default: select_reg = 32'b0;
        endcase
    endfunction

    // 書き
    always @ (posedge CLK) begin
        if (RST) begin
            REG01 <= 32'b0;
            REG02 <= 32'b0;
            REG03 <= 32'b0;
            REG04 <= 32'b0;
            REG05 <= 32'b0;
            REG06 <= 32'b0;
            REG07 <= 32'b0;
            REG08 <= 32'b0;
            REG09 <= 32'b0;
            REG10 <= 32'b0;
            REG11 <= 32'b0;
            REG12 <= 32'b0;
            REG13 <= 32'b0;
            REG14 <= 32'b0;
            REG15 <= 32'b0;
            REG16 <= 32'b0;
            REG17 <= 32'b0;
            REG18 <= 32'b0;
            REG19 <= 32'b0;
            REG20 <= 32'b0;
            REG21 <= 32'b0;
            REG22 <= 32'b0;
            REG23 <= 32'b0;
            REG24 <= 32'b0;
            REG25 <= 32'b0;
            REG26 <= 32'b0;
            REG27 <= 32'b0;
            REG28 <= 32'b0;
            REG29 <= 32'b0;
            REG30 <= 32'b0;
            REG31 <= 32'b0;
        end
        else if (WRVALID && !STALL) begin
            case (WRADDR)
                5'd1:   REG01 <= WRDATA;
                5'd2:   REG02 <= WRDATA;
                5'd3:   REG03 <= WRDATA;
                5'd4:   REG04 <= WRDATA;
                5'd5:   REG05 <= WRDATA;
                5'd6:   REG06 <= WRDATA;
                5'd7:   REG07 <= WRDATA;
                5'd8:   REG08 <= WRDATA;
                5'd9:   REG09 <= WRDATA;
                5'd10:  REG10 <= WRDATA;
                5'd11:  REG11 <= WRDATA;
                5'd12:  REG12 <= WRDATA;
                5'd13:  REG13 <= WRDATA;
                5'd14:  REG14 <= WRDATA;
                5'd15:  REG15 <= WRDATA;
                5'd16:  REG16 <= WRDATA;
                5'd17:  REG17 <= WRDATA;
                5'd18:  REG18 <= WRDATA;
                5'd19:  REG19 <= WRDATA;
                5'd20:  REG20 <= WRDATA;
                5'd21:  REG21 <= WRDATA;
                5'd22:  REG22 <= WRDATA;
                5'd23:  REG23 <= WRDATA;
                5'd24:  REG24 <= WRDATA;
                5'd25:  REG25 <= WRDATA;
                5'd26:  REG26 <= WRDATA;
                5'd27:  REG27 <= WRDATA;
                5'd28:  REG28 <= WRDATA;
                5'd29:  REG29 <= WRDATA;
                5'd30:  REG30 <= WRDATA;
                5'd31:  REG31 <= WRDATA;
                default: ;
            endcase
        end
    end

endmodule
