//////////////////////////////////////////////////////////////////////////////////
//
// Company        : Neural Semiconductor
// Author         : Amit Mazumder Shuvo
// Designation    : Senior Design Engineer
// Email          : amiteee78@gmail.com
// 
// Create Date    : 17/12/2019 11:08:30 AM
// Design Name    : apb_slave
// Module Name    : apb_slave
// Project Name   : APB2APB Bridge
// Tool Versions  : Vivado v2019.1.1 (64-bit)
// Description    : 
// 
// apb_slave receives necessary signals from CPU end to access the memory according to the APB transaction protocol.
// Internal registers define necessary signals to complete sucessful read or write transfers.
// A strobe decoder is utilized to filter out read data from memory during FULLWORD, HALFWORD or BYTE read transaction.
// 
// Revision       : 1.0 - Initially verified
// Comments       : Extensible Features need to be incorporated.
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`include "apb_arch.svh"

module apb_slave (apbif.slave sbus);

  logic                     ready_reg;
  logic                     slverr_reg;
  logic [`DATA_WIDTH-1:0]   rdata_reg;
  logic [`DATA_WIDTH-1:0]   rdata_filt_reg;

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **         Internal Register Definition          **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  always_ff @(posedge sbus.clk or negedge sbus.rst_n) 
  begin
    if (~sbus.rst_n)
    begin
      ready_reg        <= '0;
      slverr_reg       <= '0;
      rdata_reg        <= '0;

      sbus.mem_wr      <= '0;
      sbus.mem_rd      <= '0;
      sbus.mem_be      <= '0;
      sbus.mem_address <= '0;
      sbus.mem_data_in <= '0;      
    end
    else if ((sbus.addr >= `MEM_SIZE) & sbus.sel)
    begin
      if (sbus.enable)
      begin
        ready_reg        <= '1;
        slverr_reg       <= '1;
        rdata_reg        <= '0;        
      end
      else
      begin
        ready_reg        <= '0;
        slverr_reg       <= '0;
        rdata_reg        <= '0;           
      end

      sbus.mem_wr      <= '0;
      sbus.mem_rd      <= '0;
      sbus.mem_be      <= '0;
      sbus.mem_address <= '0;
      sbus.mem_data_in <= '0;
    end
    else if (sbus.write & sbus.sel)
    begin
      if (sbus.enable)
      begin
        ready_reg        <= '1;
        slverr_reg       <= '0;
        rdata_reg        <= '0;        
      end
      else
      begin
        ready_reg        <= '0;
        slverr_reg       <= '0;
        rdata_reg        <= '0;           
      end

      sbus.mem_wr      <= '1;
      sbus.mem_rd      <= '0;
      sbus.mem_be      <= sbus.strb;
      sbus.mem_address <= sbus.addr;
      sbus.mem_data_in <= sbus.wdata;
    end
    else if (~sbus.write & sbus.sel)
    begin
      if (sbus.enable)
      begin
        ready_reg        <= '1;
        slverr_reg       <= '0;
        rdata_reg        <= sbus.mem_data_out & rdata_filt_reg;        
      end
      else
      begin
        ready_reg        <= '0;
        slverr_reg       <= '0;
        rdata_reg        <= '0;           
      end

      sbus.mem_wr      <= '0;
      sbus.mem_rd      <= '1;
      sbus.mem_be      <= '0;
      sbus.mem_address <= sbus.addr;
      sbus.mem_data_in <= '0;
    end
    else
    begin
      ready_reg        <= '0;
      slverr_reg       <= '0;
      rdata_reg        <= '0;

      sbus.mem_wr      <= '0;
      sbus.mem_rd      <= '0;
      sbus.mem_be      <= '0;
      sbus.mem_address <= '0;
      sbus.mem_data_in <= '0;
    end
  end

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **            Output Logic Definition            **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  always_comb 
  begin
    if (sbus.sel & sbus.enable & ready_reg)
    begin
      sbus.ready  = '1;
    end
    else
    begin
      sbus.ready  = '0;
    end

    if (sbus.sel & sbus.enable & slverr_reg)
    begin
      sbus.slverr = '1;
    end
    else
    begin
      sbus.slverr = '0;
    end

    if (sbus.sel & sbus.enable)
    begin
      sbus.rdata  = rdata_reg;
    end
    else
    begin
      sbus.rdata  = '0;
    end
  end

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **           STROBE DECODER FOR RDATA            **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  always_comb
  begin
    unique case (sbus.strb)
      `STRB_SIZE'hF : rdata_filt_reg  <= `DATA_WIDTH'hFFFF_FFFF;
      `STRB_SIZE'h3 : rdata_filt_reg  <= `DATA_WIDTH'h0000_FFFF;
      `STRB_SIZE'hC : rdata_filt_reg  <= `DATA_WIDTH'hFFFF_0000;
      `STRB_SIZE'h1 : rdata_filt_reg  <= `DATA_WIDTH'h0000_00FF;
      `STRB_SIZE'h2 : rdata_filt_reg  <= `DATA_WIDTH'h0000_FF00;
      `STRB_SIZE'h4 : rdata_filt_reg  <= `DATA_WIDTH'h00FF_0000;
      `STRB_SIZE'h8 : rdata_filt_reg  <= `DATA_WIDTH'hFF00_0000;
      `STRB_SIZE'h0 : rdata_filt_reg  <= `DATA_WIDTH'h0000_0000;
      default       : rdata_filt_reg  <= `DATA_WIDTH'h0000_0000;
    endcase        
  end

endmodule