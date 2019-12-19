//////////////////////////////////////////////////////////////////////////////////
//
// Company        : Neural Semiconductor
// Author         : Amit Mazumder Shuvo
// Designation    : Senior Design Engineer
// Email          : amiteee78@gmail.com
// 
// Create Date    : 17/12/2019 11:08:30 AM
// Design Name    : apb_bridge
// Module Name    : apb_bridge
// Project Name   : APB2APB Bridge
// Tool Versions  : Vivado v2019.1.1 (64-bit)
// Description    :
// 
//                  The purpose of this module is to provide interconnection between APB Master & APB Slave.
//                  A master module & a slave module are created with proper interfacing from apbif module.
//
// Revision       : 1.0 - Initially verified
// Comments       : Extensible Features need to be incorporated.
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`include "apb_arch.svh"

module apb_bridge (apbif.bridge ibus);

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **           Interface object creation           **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  apbif pbus (
    ibus.clk,
    ibus.rst_n,
    ibus.dsel,
    ibus.trnsfr,

    ibus.wr,
    ibus.address,
    ibus.data_in,
    ibus.data_out,

    ibus.mem_wr,
    ibus.mem_rd,
    ibus.mem_be,
    ibus.mem_address,
    ibus.mem_data_in,
    ibus.mem_data_out
  );

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **         Master & Slave Instantiation          **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/

  apb_master pmaster (.mbus(pbus));
  apb_slave  pslave  (.sbus(pbus));
  
endmodule