module cpu_core_controller_v1_0_S_AXI #
    (
        parameter integer C_S_AXI_DATA_WIDTH    = 32,
        parameter integer C_S_AXI_ADDR_WIDTH    = 16
    )
    (
        // COREとの接続ポート
        input wire          CCLK,
        output reg          CEXEC,

        input wire [31:0]   REG00,
        input wire [31:0]   REG01,
        input wire [31:0]   REG02,
        input wire [31:0]   REG03,
        input wire [31:0]   REG04,
        input wire [31:0]   REG05,
        input wire [31:0]   REG06,
        input wire [31:0]   REG07,
        input wire [31:0]   REG08,
        input wire [31:0]   REG09,
        input wire [31:0]   REG10,
        input wire [31:0]   REG11,
        input wire [31:0]   REG12,
        input wire [31:0]   REG13,
        input wire [31:0]   REG14,
        input wire [31:0]   REG15,
        input wire [31:0]   REG16,
        input wire [31:0]   REG17,
        input wire [31:0]   REG18,
        input wire [31:0]   REG19,
        input wire [31:0]   REG20,
        input wire [31:0]   REG21,
        input wire [31:0]   REG22,
        input wire [31:0]   REG23,
        input wire [31:0]   REG24,
        input wire [31:0]   REG25,
        input wire [31:0]   REG26,
        input wire [31:0]   REG27,
        input wire [31:0]   REG28,
        input wire [31:0]   REG29,
        input wire [31:0]   REG30,
        input wire [31:0]   REG31,
        input wire [31:0]   REGPC,

        // Global Clock Signal
        input wire  S_AXI_ACLK,
        // Global Reset Signal. This Signal is Active LOW
        input wire  S_AXI_ARESETN,
        // Write address (issued by master, acceped by Slave)
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
        // Write channel Protection type. This signal indicates the
            // privilege and security level of the transaction, and whether
            // the transaction is a data access or an instruction access.
        input wire [2 : 0] S_AXI_AWPROT,
        // Write address valid. This signal indicates that the master signaling
            // valid write address and control information.
        input wire  S_AXI_AWVALID,
        // Write address ready. This signal indicates that the slave is ready
            // to accept an address and associated control signals.
        output wire  S_AXI_AWREADY,
        // Write data (issued by master, acceped by Slave)
        input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
        // Write strobes. This signal indicates which byte lanes hold
            // valid data. There is one write strobe bit for each eight
            // bits of the write data bus.
        input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
        // Write valid. This signal indicates that valid write
            // data and strobes are available.
        input wire  S_AXI_WVALID,
        // Write ready. This signal indicates that the slave
            // can accept the write data.
        output wire  S_AXI_WREADY,
        // Write response. This signal indicates the status
            // of the write transaction.
        output wire [1 : 0] S_AXI_BRESP,
        // Write response valid. This signal indicates that the channel
            // is signaling a valid write response.
        output wire  S_AXI_BVALID,
        // Response ready. This signal indicates that the master
            // can accept a write response.
        input wire  S_AXI_BREADY,
        // Read address (issued by master, acceped by Slave)
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
        // Protection type. This signal indicates the privilege
            // and security level of the transaction, and whether the
            // transaction is a data access or an instruction access.
        input wire [2 : 0] S_AXI_ARPROT,
        // Read address valid. This signal indicates that the channel
            // is signaling valid read address and control information.
        input wire  S_AXI_ARVALID,
        // Read address ready. This signal indicates that the slave is
            // ready to accept an address and associated control signals.
        output wire  S_AXI_ARREADY,
        // Read data (issued by slave)
        output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
        // Read response. This signal indicates the status of the
            // read transfer.
        output wire [1 : 0] S_AXI_RRESP,
        // Read valid. This signal indicates that the channel is
            // signaling the required read data.
        output wire  S_AXI_RVALID,
        // Read ready. This signal indicates that the master can
            // accept the read data and response information.
        input wire  S_AXI_RREADY
    );

    // AXI4LITE signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_awaddr;
    reg     axi_awready;
    reg     axi_wready;
    reg [1 : 0]     axi_bresp;
    reg     axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_araddr;
    reg     axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0]  axi_rdata;
    reg [1 : 0]     axi_rresp;
    reg     axi_rvalid;

    // Example-specific design signals
    // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    // ADDR_LSB is used for addressing 32/64 bit registers/memories
    // ADDR_LSB = 2 for 32 bits (n downto 2)
    // ADDR_LSB = 3 for 64 bits (n downto 3)
    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 1;
    //----------------------------------------------
    //-- Signals for user logic register space example
    //------------------------------------------------
    //-- Number of Slave Registers 4
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg0;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg1;
    wire    slv_reg_rden;
    wire    slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0]    reg_data_out;
    integer  byte_index;
    reg  aw_en;

    // I/O Connections assignments

    assign S_AXI_AWREADY    = axi_awready;
    assign S_AXI_WREADY     = axi_wready;
    assign S_AXI_BRESP      = axi_bresp;
    assign S_AXI_BVALID     = axi_bvalid;
    assign S_AXI_ARREADY    = axi_arready;
    assign S_AXI_RDATA      = axi_rdata;
    assign S_AXI_RRESP      = axi_rresp;
    assign S_AXI_RVALID     = axi_rvalid;
    // Implement axi_awready generation
    // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
    // de-asserted when reset is low.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_awready <= 1'b0;
          aw_en <= 1'b1;
        end
      else
        begin
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
              // slave is ready to accept write address when
              // there is a valid write address and write data
              // on the write address and data bus. This design
              // expects no outstanding transactions.
              axi_awready <= 1'b1;
              aw_en <= 1'b0;
            end
            else if (S_AXI_BREADY && axi_bvalid)
                begin
                  aw_en <= 1'b1;
                  axi_awready <= 1'b0;
                end
          else
            begin
              axi_awready <= 1'b0;
            end
        end
    end

    // Implement axi_awaddr latching
    // This process is used to latch the address when both
    // S_AXI_AWVALID and S_AXI_WVALID are valid.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_awaddr <= 0;
        end
      else
        begin
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
              // Write Address latching
              axi_awaddr <= S_AXI_AWADDR;
            end
        end
    end

    // Implement axi_wready generation
    // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is
    // de-asserted when reset is low.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_wready <= 1'b0;
        end
      else
        begin
          if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
            begin
              // slave is ready to accept write data when
              // there is a valid write address and write data
              // on the write address and data bus. This design
              // expects no outstanding transactions.
              axi_wready <= 1'b1;
            end
          else
            begin
              axi_wready <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // Slave register write enable is asserted when valid address and data are available
    // and the slave is ready to accept the write address and write data.
    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    always @(posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0) begin
            slv_reg0 <= 32'b0;
            slv_reg1 <= 32'b0;
        end
        else begin
            if (slv_reg_wren) begin
                case (axi_awaddr)
                    16'h0000:   slv_reg0 <= S_AXI_WDATA;
                    16'h0004:   slv_reg1 <= S_AXI_WDATA;
                endcase
            end
            else begin
                slv_reg0 <= slv_reg0;
                slv_reg1 <= 32'b0;
            end
        end
    end

    // Implement write response logic generation
    // The write response and response valid signals are asserted by the slave
    // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
    // This marks the acceptance of address and indicates the status of
    // write transaction.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_bvalid  <= 0;
          axi_bresp   <= 2'b0;
        end
      else
        begin
          if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
            begin
              // indicates a valid write response is available
              axi_bvalid <= 1'b1;
              axi_bresp  <= 2'b0; // 'OKAY' response
            end                   // work error responses in future
          else
            begin
              if (S_AXI_BREADY && axi_bvalid)
                //check if bready is asserted while bvalid is high)
                //(there is a possibility that bready is always asserted high)
                begin
                  axi_bvalid <= 1'b0;
                end
            end
        end
    end

    // Implement axi_arready generation
    // axi_arready is asserted for one S_AXI_ACLK clock cycle when
    // S_AXI_ARVALID is asserted. axi_awready is
    // de-asserted when reset (active low) is asserted.
    // The read address is also latched when S_AXI_ARVALID is
    // asserted. axi_araddr is reset to zero on reset assertion.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_arready <= 1'b0;
          axi_araddr  <= 32'b0;
        end
      else
        begin
          if (~axi_arready && S_AXI_ARVALID)
            begin
              // indicates that the slave has acceped the valid read address
              axi_arready <= 1'b1;
              // Read address latching
              axi_araddr  <= S_AXI_ARADDR;
            end
          else
            begin
              axi_arready <= 1'b0;
            end
        end
    end

    // Implement axi_arvalid generation
    // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_ARVALID and axi_arready are asserted. The slave registers
    // data are available on the axi_rdata bus at this instance. The
    // assertion of axi_rvalid marks the validity of read data on the
    // bus and axi_rresp indicates the status of read transaction.axi_rvalid
    // is deasserted on reset (active low). axi_rresp and axi_rdata are
    // cleared to zero on reset (active low).
    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_rvalid <= 0;
          axi_rresp  <= 0;
        end
      else
        begin
          if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
            begin
              // Valid read data is available at the read data bus
              axi_rvalid <= 1'b1;
              axi_rresp  <= 2'b0; // 'OKAY' response
            end
          else if (axi_rvalid && S_AXI_RREADY)
            begin
              // Read data is accepted by the master
              axi_rvalid <= 1'b0;
            end
        end
    end

    // REG**の同期化
    reg [31:0] reg00 [0:1];
    reg [31:0] reg01 [0:1];
    reg [31:0] reg02 [0:1];
    reg [31:0] reg03 [0:1];
    reg [31:0] reg04 [0:1];
    reg [31:0] reg05 [0:1];
    reg [31:0] reg06 [0:1];
    reg [31:0] reg07 [0:1];
    reg [31:0] reg08 [0:1];
    reg [31:0] reg09 [0:1];
    reg [31:0] reg10 [0:1];
    reg [31:0] reg11 [0:1];
    reg [31:0] reg12 [0:1];
    reg [31:0] reg13 [0:1];
    reg [31:0] reg14 [0:1];
    reg [31:0] reg15 [0:1];
    reg [31:0] reg16 [0:1];
    reg [31:0] reg17 [0:1];
    reg [31:0] reg18 [0:1];
    reg [31:0] reg19 [0:1];
    reg [31:0] reg20 [0:1];
    reg [31:0] reg21 [0:1];
    reg [31:0] reg22 [0:1];
    reg [31:0] reg23 [0:1];
    reg [31:0] reg24 [0:1];
    reg [31:0] reg25 [0:1];
    reg [31:0] reg26 [0:1];
    reg [31:0] reg27 [0:1];
    reg [31:0] reg28 [0:1];
    reg [31:0] reg29 [0:1];
    reg [31:0] reg30 [0:1];
    reg [31:0] reg31 [0:1];
    reg [31:0] regpc [0:1];

    always @ (posedge S_AXI_ACLK) begin
        reg00[1] <= reg00[0]; reg00[0] <= REG00;
        reg01[1] <= reg01[0]; reg01[0] <= REG01;
        reg02[1] <= reg02[0]; reg02[0] <= REG02;
        reg03[1] <= reg03[0]; reg03[0] <= REG03;
        reg04[1] <= reg04[0]; reg04[0] <= REG04;
        reg05[1] <= reg05[0]; reg05[0] <= REG05;
        reg06[1] <= reg06[0]; reg06[0] <= REG06;
        reg07[1] <= reg07[0]; reg07[0] <= REG07;
        reg08[1] <= reg08[0]; reg08[0] <= REG08;
        reg09[1] <= reg09[0]; reg09[0] <= REG09;
        reg10[1] <= reg10[0]; reg10[0] <= REG10;
        reg11[1] <= reg11[0]; reg11[0] <= REG11;
        reg12[1] <= reg12[0]; reg12[0] <= REG12;
        reg13[1] <= reg13[0]; reg13[0] <= REG13;
        reg14[1] <= reg14[0]; reg14[0] <= REG14;
        reg15[1] <= reg15[0]; reg15[0] <= REG15;
        reg16[1] <= reg16[0]; reg16[0] <= REG16;
        reg17[1] <= reg17[0]; reg17[0] <= REG17;
        reg18[1] <= reg18[0]; reg18[0] <= REG18;
        reg19[1] <= reg19[0]; reg19[0] <= REG19;
        reg20[1] <= reg20[0]; reg20[0] <= REG20;
        reg21[1] <= reg21[0]; reg21[0] <= REG21;
        reg22[1] <= reg22[0]; reg22[0] <= REG22;
        reg23[1] <= reg23[0]; reg23[0] <= REG23;
        reg24[1] <= reg24[0]; reg24[0] <= REG24;
        reg25[1] <= reg25[0]; reg25[0] <= REG25;
        reg26[1] <= reg26[0]; reg26[0] <= REG26;
        reg27[1] <= reg27[0]; reg27[0] <= REG27;
        reg28[1] <= reg28[0]; reg28[0] <= REG28;
        reg29[1] <= reg29[0]; reg29[0] <= REG29;
        reg30[1] <= reg30[0]; reg30[0] <= REG30;
        reg31[1] <= reg31[0]; reg31[0] <= REG31;
        regpc[1] <= regpc[0]; regpc[0] <= REGPC;
    end

    // Implement memory mapped register select and read logic generation
    // Slave register read enable is asserted when valid address is available
    // and the slave is ready to accept the read address.
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    always @* begin
        case (axi_araddr)
            16'h0000    : reg_data_out <= slv_reg0;
            16'h1000    : reg_data_out <= reg00[1];
            16'h1004    : reg_data_out <= reg01[1];
            16'h1008    : reg_data_out <= reg02[1];
            16'h100C    : reg_data_out <= reg03[1];
            16'h1010    : reg_data_out <= reg04[1];
            16'h1014    : reg_data_out <= reg05[1];
            16'h1018    : reg_data_out <= reg06[1];
            16'h101C    : reg_data_out <= reg07[1];
            16'h1020    : reg_data_out <= reg08[1];
            16'h1024    : reg_data_out <= reg09[1];
            16'h1028    : reg_data_out <= reg10[1];
            16'h102C    : reg_data_out <= reg11[1];
            16'h1030    : reg_data_out <= reg12[1];
            16'h1034    : reg_data_out <= reg13[1];
            16'h1038    : reg_data_out <= reg14[1];
            16'h103C    : reg_data_out <= reg15[1];
            16'h1040    : reg_data_out <= reg16[1];
            16'h1044    : reg_data_out <= reg17[1];
            16'h1048    : reg_data_out <= reg18[1];
            16'h104C    : reg_data_out <= reg19[1];
            16'h1050    : reg_data_out <= reg20[1];
            16'h1054    : reg_data_out <= reg21[1];
            16'h1058    : reg_data_out <= reg22[1];
            16'h105C    : reg_data_out <= reg23[1];
            16'h1060    : reg_data_out <= reg24[1];
            16'h1064    : reg_data_out <= reg25[1];
            16'h1068    : reg_data_out <= reg26[1];
            16'h106C    : reg_data_out <= reg27[1];
            16'h1070    : reg_data_out <= reg28[1];
            16'h1074    : reg_data_out <= reg29[1];
            16'h1078    : reg_data_out <= reg30[1];
            16'h107C    : reg_data_out <= reg31[1];
            16'h1080    : reg_data_out <= regpc[1];
            default : reg_data_out <= 0;
        endcase
    end

    // Output register or memory read data
    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_rdata  <= 0;
        end
      else
        begin
          // When there is a valid read address (S_AXI_ARVALID) with
          // acceptance of read address by the slave (axi_arready),
          // output the read dada
          if (slv_reg_rden)
            begin
              axi_rdata <= reg_data_out;     // register read data
            end
        end
    end

    /* ----- CEXEC ----- */
    reg         cache_slv_reg0, cache_slv_reg1;
    reg [1:0]   acexec;

    always @ (posedge S_AXI_ACLK) begin
        acexec <= { acexec[0], CEXEC };
    end

    always @ (posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0)
            cache_slv_reg0 <= 1'b0;
        else if (slv_reg0 > 32'b0)
            cache_slv_reg0 <= 1'b1;
        else if (acexec[1])
            cache_slv_reg0 <= 1'b0;
    end

    always @ (posedge S_AXI_ACLK) begin
        if (S_AXI_ARESETN == 1'b0)
            cache_slv_reg1 <= 1'b0;
        else if (slv_reg1 > 32'b0)
            cache_slv_reg1 <= 1'b1;
        else if (acexec[1])
            cache_slv_reg1 <= 1'b0;
    end

    always @ (posedge cache_slv_reg0, posedge cache_slv_reg1, posedge CCLK) begin
        if (cache_slv_reg0 || cache_slv_reg1)
            CEXEC <= 1'b1;
        else
            CEXEC <= 1'b0;
    end

endmodule
