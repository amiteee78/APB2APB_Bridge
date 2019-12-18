//////////////////////////////////////////////////////////////////////////////////
//
// Company        : Neural Semiconductor
// Author         : Amit Mazumder Shuvo
// Designation    : Senior Design Engineer
// Email          : amiteee78@gmail.com
// 
// Create Date    : 17/12/2019 11:08:30 AM
// Design Name    : apb_master
// Module Name    : apb_master
// Project Name   : APB2APB Bridge
// Tool Versions  : Vivado v2019.1.1 (64-bit)
// Description    : 
// 
// apb_master drives necessary signals from CPU end to run the slaves according to the APB transaction protocol.
// apb_master module is designed using a Finite State Machine having 3 always block...
//   1. A sequential block to define the state register.
//   2. A combinational block to define the next state logic.
//   3. A combinational block to define the output logic.
// The FSM of the master module controls the three operating states (IDLE, SETUP & ACCESS) of APB protocol.
// Binary encoding is used to define the transitions among three different states.
// A strobe encoder is utilized to enable memory bytes accrodingly during FULLWORD, HALFWORD or BYTE write transaction.
// 
// Revision       : 1.0 - Initially verified
// Comments       : Extensible Features need to be incorporated.
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`include "apb_arch.svh"

module apb_master (apbif.master mbus);

  enum logic [1:0] {IDLE, SETUP, ACCESS} m_state, m_nxt_state;

  logic      [1:0]              strb_reg;
  logic                         wr_reg;
  logic      [`ADDR_WIDTH-1:0]  address_reg;
  logic      [`DATA_WIDTH-1:0]  data_in_reg;

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **           Input Register Definition           **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  always_ff @(posedge mbus.clk or negedge mbus.rst_n) 
  begin
    if(~mbus.rst_n) 
    begin
      strb_reg    <= '0;
      wr_reg      <= '0;
      address_reg <= '0;
      data_in_reg <= '0;
    end 
    else if (mbus.trnsfr)
    begin
      strb_reg    <= {mbus.address,2'b00} >> mbus.dsel;
      wr_reg      <= mbus.wr;
      address_reg <= mbus.address >> mbus.dsel;
      data_in_reg <= mbus.data_in;
    end
    else
    begin
      strb_reg    <= strb_reg;
      wr_reg      <= wr_reg;    
      address_reg <= address_reg;
      data_in_reg <= data_in_reg;  
    end
  end

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **           State Register Definition           **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  always_ff @(posedge mbus.clk or negedge mbus.rst_n) 
  begin
    if(~mbus.rst_n) 
    begin
      m_state <= IDLE;
    end 
    else 
    begin
      m_state <= m_nxt_state;
    end
  end

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **          Next State Logic Definition          **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  always_comb 
  begin

    unique case (m_state)
      IDLE :
      begin
        if (mbus.trnsfr)
        begin
          m_nxt_state = SETUP;
        end
        else
        begin
          m_nxt_state = IDLE;
        end
      end

      SETUP :
      begin
        m_nxt_state = ACCESS;
      end

      ACCESS :
      begin
        if (mbus.ready)
        begin
          if (mbus.trnsfr)
          begin
            m_nxt_state = SETUP;
          end
          else
          begin
            m_nxt_state = IDLE;
          end
        end
        else
        begin
          m_nxt_state = ACCESS;
        end
      end

      default :
      begin
        m_nxt_state = IDLE;
      end
    endcase

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
    
    unique case (m_state)
      IDLE :
      begin
        mbus.sel      = '0;
        mbus.enable   = '0;
        mbus.write    = '0;
        mbus.strb     = '0;
        mbus.addr     = '0;
        mbus.wdata    = '0;

        mbus.data_out = '0;
      end

      SETUP :
      begin
        mbus.sel      = '1;
        mbus.enable   = '0;
        mbus.addr     = address_reg;
        mbus.strb     = '0;
        mbus.data_out = '0;
        
        if (wr_reg)
        begin
          mbus.write = '1;                                  //write transfer enable 1 cycle ahead
          mbus.wdata = data_in_reg << {strb_reg,3'b000};    //write data channel alignment
        end
        else
        begin
          mbus.write = '0;                                  //read transfer enable 1 cycle ahead
          mbus.wdata = '0;                                  //write data channel off
        end
      end

      ACCESS :
      begin
        mbus.sel    = '1;
        mbus.enable = '1;
        mbus.addr   = address_reg;

        // STROBE ENCODER
        unique case ({mbus.dsel, strb_reg})
          `STRB_SIZE'h0 : mbus.strb = `STRB_SIZE'hF;
          `STRB_SIZE'h4 : mbus.strb = `STRB_SIZE'h3;
          `STRB_SIZE'h6 : mbus.strb = `STRB_SIZE'hC;
          `STRB_SIZE'h8 : mbus.strb = `STRB_SIZE'h1;
          `STRB_SIZE'h9 : mbus.strb = `STRB_SIZE'h2;
          `STRB_SIZE'hA : mbus.strb = `STRB_SIZE'h4;
          `STRB_SIZE'hB : mbus.strb = `STRB_SIZE'h8;
          default       : mbus.strb = `STRB_SIZE'h0;
        endcase
        
        if (wr_reg)
        begin
          mbus.write = '1;                                            //write transfer enable
          mbus.wdata = data_in_reg << {strb_reg,3'b000};              //write data channel alignment
        end
        else
        begin
          mbus.write = '0;                                            //read transfer enable
          mbus.wdata = '0;                                            //write data channel off
        end

        if (mbus.ready)
        begin
          mbus.data_out = mbus.rdata >> {strb_reg,3'b000};
        end
        else
        begin
          mbus.data_out = '0;
        end
      end

      default :
      begin
        mbus.sel      = '0;
        mbus.enable   = '0;
        mbus.write    = '0;
        mbus.strb     = '0;
        mbus.addr     = '0;
        mbus.wdata    = '0;

        mbus.data_out = '0;
      end
    endcase

  end

endmodule