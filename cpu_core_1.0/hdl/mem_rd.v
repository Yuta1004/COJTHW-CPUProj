//-----------------------------------------------------------------------------
// Title       : CPU Core (RV32I) : ALU
// Project     : cpu_proj
// Filename    : alu.v
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Revisions   :
// Date        Version  Author        Description
// 2022/12/10  1.00     Y.Nakagami    Created
//-----------------------------------------------------------------------------

module mem_rd
    (
        /* ----- クロック&リセット信号 ----- */
        input wire          CLK,
        input wire          RST,

        /* ----- 上位との接続用 ----- */
        // 制御
        input wire          STALL,
        input wire          FLUSH,
        output wire         DO_JMP,
        output wire [31:0]  NEW_PC,

        // 入力
        input wire  [31:0]  A_PC,
        input wire  [31:0]  A_INST,
        input wire          A_VALID,
        input wire          A_DO_JMP,
        input wire  [31:0]  A_NEW_PC,
        input wire  [4:0]   A_REG_D,
        input wire  [31:0]  A_REG_D_V,
        input wire          A_LOAD_RDEN,
        input wire  [1:0]   A_LOAD_SIZE,
        input wire          A_LOAD_SIGNED,
        input wire          A_STORE_WREN,
        input wire  [31:0]  A_STORE_ADDR,
        input wire  [3:0]   A_STORE_STRB,
        input wire  [31:0]  A_STORE_DATA,

        input wire  [31:0]  DATA_RDDATA,

        // 出力
        output wire [31:0]  M_PC,
        output wire [31:0]  M_INST,
        output wire         M_VALID,
        output wire [4:0]   M_REG_D,
        output wire [31:0]  M_REG_D_V,
        output wire         M_STORE_WREN,
        output wire [31:0]  M_STORE_ADDR,
        output wire [3:0]   M_STORE_STRB,
        output wire [31:0]  M_STORE_DATA
    );

    /* ----- 入力(ラッチ取り込み) ----- */
    reg [31:0]  pc, inst;
    reg         valid;
    reg         do_jmp;
    reg [31:0]  new_pc;
    reg [4:0]   reg_d;
    reg [31:0]  reg_d_v;
    reg         load_rden;
    reg [1:0]   load_size;
    reg         load_signed;
    reg         store_wren;
    reg [31:0]  store_addr, store_data;
    reg [3:0]   store_strb;

    always @ (posedge CLK) begin
        if (RST) begin
            pc <= 32'b0;
            inst <= 32'b0;
            valid <= 1'b0;
            do_jmp <= 1'b0;
            new_pc <= 32'b0;
            reg_d <= 5'b0;
            reg_d_v <= 32'b0;
            load_rden <= 1'b0;
            load_size <= 2'b0;
            load_signed <= 1'b0;
            store_wren <= 1'b0;
            store_addr <= 32'b0;
            store_strb <= 4'b0;
            store_data <= 32'b0;
        end
        else if (STALL)
            ;
        else if (FLUSH) begin
            pc <= 32'b0;
            inst <= 32'b0;
            valid <= 1'b0;
            do_jmp <= 1'b0;
            new_pc <= 32'b0;
            reg_d <= 5'b0;
            reg_d_v <= 32'b0;
            load_rden <= 1'b0;
            load_size <= 2'b0;
            load_signed <= 1'b0;
            store_wren <= 1'b0;
            store_addr <= 32'b0;
            store_strb <= 4'b0;
            store_data <= 32'b0;
        end
        else begin
            pc <= A_PC;
            inst <= A_INST;
            valid <= A_VALID;
            do_jmp <= A_DO_JMP;
            new_pc <= A_NEW_PC;
            reg_d <= A_REG_D;
            reg_d_v <= A_REG_D_V;
            load_rden <= A_LOAD_RDEN;
            load_size <= A_LOAD_SIZE;
            load_signed <= A_LOAD_SIGNED;
            store_wren <= A_STORE_WREN;
            store_addr <= A_STORE_ADDR;
            store_strb <= A_STORE_STRB;
            store_data <= A_STORE_DATA;
        end
    end

    /* ----- 出力 ----- */
    assign DO_JMP       = do_jmp;
    assign NEW_PC       = new_pc;

    assign M_PC         = pc;
    assign M_INST       = inst;
    assign M_VALID      = valid;
    assign M_REG_D      = reg_d;
    assign M_REG_D_V    = load_rden ? DATA_RDDATA : reg_d_v;
    assign M_STORE_WREN = store_wren;
    assign M_STORE_ADDR = store_addr;
    assign M_STORE_STRB = store_strb;
    assign M_STORE_DATA = store_data;

endmodule
