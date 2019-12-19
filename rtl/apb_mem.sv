//////////////////////////////////////////////////////////////////////////////////
//
// Company        : Neural Semiconductor
// Author         : Amit Mazumder Shuvo
// Designation    : Senior Design Engineer
// Email          : amiteee78@gmail.com
// 
// Create Date    : 17/12/2019 11:08:30 AM
// Design Name    : apb_mem
// Module Name    : apb_mem
// Project Name   : APB2APB Bridge
// Tool Versions  : Vivado v2019.1.1 (64-bit)
// Description    : 
// 
// apb_mem module is a System Verilog Behavioral Model of a dual port SRAM (individual read & write channel).
// The size of the memory can be changed by modifying the 'MEM_SIZE' macro defined in 'apb_arch.svh' file.
// In the initial functional simulation, 1KB of SRAM is used for FULLWORD, HALFWORD & BYTE access.
// mem_be input port controls which memory bytes are allowed to access & which are not.
// 
// Revision       : 1.0 - Initially verified
// Comments       : Extensible Features need to be incorporated.
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`include "apb_arch.svh"

module apb_mem (memif.mem membus);

  genvar k,m;
  logic  [`MEM_WIDTH-1:0]  ram [`MEM_DEPTH-1:0] [0:`MEM_SIZE-1];

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **             Memory Initialization             **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  initial
  begin
    for (int i = 0; i < `MEM_DEPTH; i++) 
    begin
      for (int j = 0; j < `MEM_SIZE; j++) 
      begin
        ram[i][j] = '0; 
      end
    end
  end

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **               Memory Write Access             **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  generate
    for (k = 0; k < `MEM_DEPTH; k++)
    begin
      always_ff @(posedge membus.clk)
      begin
        if (membus.mem_wr)
        begin 
          if (membus.mem_be[k])
          begin
            ram[k][membus.mem_address] <= membus.mem_data_in[(`MEM_WIDTH*k)+`MEM_WIDTH-1:(`MEM_WIDTH*k)];
          end
        end
      end
    end 
  endgenerate

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **               Memory Read Access              **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/

  generate
    for (m = 0; m < `MEM_DEPTH; m++) 
    begin
      always_comb
      begin
        if (membus.mem_rd)
        begin
          membus.mem_data_out[(`MEM_WIDTH*m)+`MEM_WIDTH-1:(`MEM_WIDTH*m)] = ram[m][membus.mem_address];
        end
        else
        begin
          membus.mem_data_out[(`MEM_WIDTH*m)+`MEM_WIDTH-1:(`MEM_WIDTH*m)] = '0;
        end
      end
    end
  endgenerate

endmodule