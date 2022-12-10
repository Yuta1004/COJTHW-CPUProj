//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I) : Decode
// Project     : cpu_proj
// Filename    : decode.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/10  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module decode
    (
        /* ----- クロック&リセット信号 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- 上位との接続用 ----- */
        // 制御
        input wire          STALL,

        // 入力
        input wire  [31:0]  I_PC,
        input wire  [31:0]  I_INST,
        input wire          I_VALID,

        // 出力
        output wire [31:0]  D_PC,
        output wire [31:0]  D_INST,
        output wire         D_VALID,
        output wire [6:0]   D_OPCODE,
        output wire [2:0]   D_FUNCT3,
        output wire [6:0]   D_FUNCT7,
        output wire [31:0]  D_IMM,
        output wire [4:0]   D_REG_D,
        output wire [4:0]   D_REG_S1,
        output wire [31:0]  D_REG_S1_V,
        output wire [4:0]   D_REG_S2,
        output wire [31:0]  D_REG_S2_V,

        /* ----- デバッグ用 ----- */
        output wire [31:0]  REG01,
        output wire [31:0]  REG02,
        output wire [31:0]  REG03,
        output wire [31:0]  REG04,
        output wire [31:0]  REG05,
        output wire [31:0]  REG06,
        output wire [31:0]  REG07,
        output wire [31:0]  REG08,
        output wire [31:0]  REG09,
        output wire [31:0]  REG10,
        output wire [31:0]  REG11,
        output wire [31:0]  REG12,
        output wire [31:0]  REG13,
        output wire [31:0]  REG14,
        output wire [31:0]  REG15,
        output wire [31:0]  REG16,
        output wire [31:0]  REG17,
        output wire [31:0]  REG18,
        output wire [31:0]  REG19,
        output wire [31:0]  REG20,
        output wire [31:0]  REG21,
        output wire [31:0]  REG22,
        output wire [31:0]  REG23,
        output wire [31:0]  REG24,
        output wire [31:0]  REG25,
        output wire [31:0]  REG26,
        output wire [31:0]  REG27,
        output wire [31:0]  REG28,
        output wire [31:0]  REG29,
        output wire [31:0]  REG30,
        output wire [31:0]  REG31
    );

    /* ----- 入力(ラッチ取り込み) ----- */
    reg [31:0]  i_pc, i_inst;
    reg         i_valid;

    always @ (posedge CLK) begin
        i_pc <= I_PC;
        i_inst <= I_INST;
        i_valid <= I_VALID;
    end

    /* ----- 出力 ----- */
    // PC, INST, VALID
    assign D_PC     = i_pc;
    assign D_INST   = i_inst;
    assign D_VALID  = i_valid;

    // opcode, funct3, funct7
    assign D_OPCODE = i_inst[6:0];
    assign D_FUNCT3 = i_inst[14:12];
    assign D_FUNCT7 = i_inst[31:25];

    // imm
    assign D_IMM = gen_imm(i_inst, D_OPCODE);

    function [31:0] gen_imm;
        input [31:0]    INST;
        input [6:0]     OPCODE;

        // R形式
        if (
            INST[6:0] == 7'b0110011
        )
            gen_imm = 32'b0;

        // I形式
        else if (
            INST[6:0] == 7'b1100111 ||
            INST[6:0] == 7'b0000011 ||
            INST[6:0] == 7'b0010011 ||
            INST[6:0] == 7'b0001111 ||
            INST[6:0] == 7'b1110011
        )
            gen_imm = { 20'b0, INST[31:20] };

        // S形式
        else if (
            INST[6:0] == 7'b0100011
        )
            gen_imm = { 20'b0, INST[31:25], INST[11:7] };

        // B形式
        else if (
            INST[6:0] == 7'b1100011
        )
            gen_imm = { 19'b0, INST[31], INST[7], INST[30:25], INST[11:8], 1'b0 };

        // U形式
        else if (
            INST[6:0] == 7'b0110111 ||
            INST[6:0] == 7'b0010111
        )
            gen_imm = { INST[31:12], 12'b0 };

        // J形式
        else if (
            INST[6:0] == 7'b1101111
        )
            gen_imm = { 11'b0, INST[31], INST[19:12], INST[20], INST[30:21], 1'b0 };

        // 未対応命令
        else
            gen_imm = 32'b0;
    endfunction

    // rd, rs1, rs2
    assign D_REG_D    = i_inst[11:7];
    assign D_REG_S1   = i_inst[19:15];
    assign D_REG_S1_V = select_reg(D_REG_S1);
    assign D_REG_S2   = i_inst[24:20];
    assign D_REG_S2_V = select_reg(D_REG_S2);

    reg [31:0] REG01, REG02, REG03, REG04, REG05, REG06, REG07, REG08, REG09, REG10;
    reg [31:0] REG11, REG12, REG13, REG14, REG15, REG16, REG17, REG18, REG19, REG20;
    reg [31:0] REG21, REG22, REG23, REG24, REG25, REG26, REG27, REG28, REG29, REG30, REG31;

    function [31:0] select_reg;
        input [4:0] REG;

        case (REG)
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
    end

endmodule
