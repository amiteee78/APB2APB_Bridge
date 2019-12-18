//////////////////////////////////////////////////////////////////////////////////
//
// Company        : Neural Semiconductor
// Author         : Amit Mazumder Shuvo
// Designation    : Senior Design Engineer
// Email          : amiteee78@gmail.com
// 
// Create Date    : 17/12/2019 11:08:30 AM
// Design Name    : apb_intf
// Module Name    : apbif, memif
// Project Name   : APB2APB Bridge
// Tool Versions  : Vivado v2019.1.1 (64-bit)
// Description    : 
// 
// Two individual interfaces (apbif, memif) are defined in this design.
// apbif interface provides necessary interface I/O, protocol signlas & modports for test bench, apb_bridge, apb_master, apb_slave & apb_mem modules.
// memif interface provides necessary interface I/O, signals & modports for test bench & apb_mem module.
// 
// Revision       : 1.0 - Initially verified
// Comments       : Extensible Features need to be incorporated.
// 
//////////////////////////////////////////////////////////////////////////////////

`include "apb_arch.svh"

interface apbif (
    input   logic                       clk,    // Clock
    input   logic                       rst_n,  // Asynchronous reset active low
    input   logic [1:0]                 dsel,   // selection among byte/half word/word transfer  
    input   logic                       trnsfr, // Continue transfer

    // Address & Data Channel (APB Master)
    input   logic                       wr,
    input   logic [`ADDR_WIDTH-1:0]     address,
    input   logic [`DATA_WIDTH-1:0]     data_in,
    output  logic [`DATA_WIDTH-1:0]     data_out,

    // Address & Data Channel (Memory)
    output  logic                       mem_wr,
    output  logic                       mem_rd,
    output  logic [`MEM_DEPTH-1:0]      mem_be,
    output  logic [`ADDR_WIDTH-1:0]     mem_address,
    output  logic [`DATA_WIDTH-1:0]     mem_data_in,
    input   logic [`DATA_WIDTH-1:0]     mem_data_out    
  );

  logic                     sel;
  logic                     enable;
  logic                     write;
  logic [`STRB_SIZE-1:0]    strb;
  logic [`ADDR_WIDTH-1:0]   addr;
  logic [`DATA_WIDTH-1:0]   wdata;
  logic                     ready;
  logic                     slverr;
  logic [`DATA_WIDTH-1:0]   rdata;

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **           APB Bridge Module Port              **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  modport bridge (
    input    clk,
    input    rst_n,
    input    dsel,
    input    trnsfr,

    // Address & Data Channel (CPU)
    input    wr,
    input    address,
    input    data_in,
    output   data_out,

    // Address & Data Channel (Memory)
    output   mem_wr,
    output   mem_rd,
    output   mem_be,
    output   mem_address,
    output   mem_data_in,
    input    mem_data_out  
  );

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **           APB Master Module Port              **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  modport master (
    input    clk,    
    input    rst_n,
    input    dsel,
    input    trnsfr,

    // Address & Data Channel (CPU)
    input    wr,
    input    address,
    input    data_in,
    output   data_out,

    // APB Interface
    output   sel,
    output   enable,
    output   write,
    output   strb,
    output   addr,
    output   wdata,

    input    ready,
    input    slverr,
    input    rdata  
  );

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **            APB Slave Module Port              **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  modport slave (
    input    clk,    
    input    rst_n,
    input    trnsfr,

    // Address & Data Channel (Memory)
    output   mem_wr,
    output   mem_rd,
    output   mem_be,
    output   mem_address,
    output   mem_data_in, 
    input    mem_data_out,

    // APB Interface
    input    sel,
    input    enable,
    input    write,
    input    strb,
    input    addr,
    input    wdata,

    output   ready,
    output   slverr,
    output   rdata  
  );

endinterface

interface memif (
    input   logic                       clk,

    // Memory Access
    input   logic                       mem_wr,
    input   logic                       mem_rd,
    input   logic [`MEM_DEPTH-1:0]      mem_be,
    input   logic [`ADDR_WIDTH-1:0]     mem_address,
    input   logic [`DATA_WIDTH-1:0]     mem_data_in,
    output  logic [`DATA_WIDTH-1:0]     mem_data_out
  );

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **              Memory Module Port               **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/
  modport mem (
    input  clk,

    // Memory Access
    input  mem_wr,
    input  mem_rd,
    input  mem_be,
    input  mem_address,
    input  mem_data_in,
    output mem_data_out
  );

endinterface