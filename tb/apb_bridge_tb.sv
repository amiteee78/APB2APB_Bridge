//////////////////////////////////////////////////////////////////////////////////
//
// Company        : Neural Semiconductor
// Author         : Amit Mazumder Shuvo
// Designation    : Senior Design Engineer
// Email          : amiteee78@gmail.com
// 
// Create Date    : 17/12/2019 11:08:30 AM
// Design Name    : apb_bridge_tb
// Module Name    : apb_bridge_tb
// Project Name   : APB2APB Bridge
// Tool Versions  : Vivado v2019.1.1 (64-bit)
// Description    : 
// 
// apb_bridge_tb is the test bench for verifying the APB2APB Bridge design developed in the flat approach. 
// This test bench top module instantiates apb_bridge & apb_mem modules as well as interconnects them for functional simulation.
// Five tasks (asynch_reset, single_write, single_read, burst_write and burst_read) are defined so far to test the desired functionalities of APB protocol.
// 10 ns (100 MHz Frequency) of clock period is set for simulation purpose.
// A memory file (ram.hex) is created to observe the desired change of the memory for free tool simulation.
// 'apb_bridge_tb.vcd' file is dumped to observe the waves.
// 
// Revision       : 1.0 - Initially verified
// Comments       : Extensible Features need to be incorporated.
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
`include "apb_arch.svh"

typedef enum bit [1:0] {FULLWORD, HALFWORD, BYTE} dsel_type; 

module apb_bridge_tb ();

  bit                         clk;   
  bit                         rst_n; 
  dsel_type                   dsel;  
  bit                         trnsfr;
  // Address & Data Channel (APB Master)
  bit                         wr;
  bit   [`ADDR_WIDTH-1:0]     address;
  bit   [`DATA_WIDTH-1:0]     data_in;
  logic [`DATA_WIDTH-1:0]     data_out;
  // Address & Data Channel (Memory)
  logic                       mem_wr;
  logic                       mem_rd;
  logic [`MEM_DEPTH-1:0]      mem_be;
  logic [`ADDR_WIDTH-1:0]     mem_address;
  logic [`DATA_WIDTH-1:0]     mem_data_in;
  logic [`DATA_WIDTH-1:0]     mem_data_out;

  logic [`DATA_WIDTH-1:0]     write_data_in;
  logic [`ADDR_WIDTH-1:0]     write_addr_in;
  logic [`DATA_WIDTH-1:0]     read_data_out;
  logic [`ADDR_WIDTH-1:0]     read_addr_in;

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **              DUT Instantiation                **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/ 
  apbif test_bus(.*); // APB Interface Object Creation
  apb_bridge apb2apb (.ibus(test_bus)); // DUT Connection with Testbench

  memif mem_bus(.*);  // Memory Interface Object Creation
  apb_mem memory (.membus(mem_bus)); // Memory Model Connection with Testbench

  /*********************************************************/
  /*  ***************************************************  */
  /*  **                                               **  */
  /*  **               Clock Generation                **  */
  /*  **                                               **  */
  /*  ***************************************************  */
  /*********************************************************/ 
  initial
  begin
    forever
    begin
      #5 clk = ~clk;
    end
  end

  initial
  begin
    $dumpfile("apb_bridge_tb.vcd");
    $dumpvars(0);
  end

  initial
  begin
    async_reset();

    for (int i = 0; i < 10; i++) 
    begin
      single_write(`ADDR_WIDTH'h0000_00F0 + i, FULLWORD, `DATA_WIDTH'h000A_3210 + i);
    end

    for (int i = 0; i < 10; i++) 
    begin
      single_read(`ADDR_WIDTH'h0000_00F0 + i, FULLWORD);
    end

    repeat(5) @(posedge clk);

    for (int i = 0; i < 10; i++) 
    begin
      single_write(`ADDR_WIDTH'h0000_0012 + i, HALFWORD, `DATA_WIDTH'h510F_CB29 + i);
    end

    for (int i = 0; i < 10; i++) 
    begin
      single_read(`ADDR_WIDTH'h0000_0012 + i, HALFWORD);
    end

    repeat(5) @(posedge clk);

    for (int i = 0; i < 10; i++) 
    begin
      single_write(`ADDR_WIDTH'h0000_003D + i, BYTE, `DATA_WIDTH'h0102_1034 + i);
    end

    for (int i = 0; i < 10; i++) 
    begin
      single_read(`ADDR_WIDTH'h0000_003D + i, BYTE);
    end

    repeat(5) @(posedge clk);

    // Slave Error Test
    /*-------------------------------------------------------------------------------------*/
    for (int i = 0; i < 2; i++) 
    begin
      single_write(`ADDR_WIDTH'h0000_0100 + i, FULLWORD, `DATA_WIDTH'h0102_1034 + i);
      single_read(`ADDR_WIDTH'h0000_0100 + i, FULLWORD);
    end

    for (int i = 0; i < 2; i++) 
    begin
      single_write(`ADDR_WIDTH'h0000_0200 + i, HALFWORD, `DATA_WIDTH'h0102_1034 + i);
      single_read(`ADDR_WIDTH'h0000_0200 + i, HALFWORD);
    end

    for (int i = 0; i < 2; i++) 
    begin
      single_write(`ADDR_WIDTH'h0000_0400 + i, BYTE, `DATA_WIDTH'h0102_1034 + i);
      single_read(`ADDR_WIDTH'h0000_0400 + i, BYTE);
    end

    repeat(5) @(posedge clk);

    burst_write(`ADDR_WIDTH'h0000_0200, FULLWORD, `DATA_WIDTH'hDEAD_BEEF, 8);
    burst_read(`ADDR_WIDTH'h0000_0530, FULLWORD, 8);

    repeat(5) @(posedge clk);
    /*-------------------------------------------------------------------------------------*/

    burst_write(`ADDR_WIDTH'h0000_00B0, FULLWORD, `DATA_WIDTH'hC0D9_42F0, 8);
    burst_read(`ADDR_WIDTH'h0000_00B0, FULLWORD, 8);

    repeat(5) @(posedge clk);

    burst_write(`ADDR_WIDTH'h0000_0050, HALFWORD, `DATA_WIDTH'h3187_EFC6, 8);
    burst_read(`ADDR_WIDTH'h0000_0050, HALFWORD, 8);

    repeat(5) @(posedge clk);

    burst_write(`ADDR_WIDTH'h0000_02F0, BYTE, `DATA_WIDTH'h5B0D_0FEF, 8);
    burst_read(`ADDR_WIDTH'h0000_02F0, BYTE, 8);

    repeat(5) @(posedge clk);

    burst_write(`ADDR_WIDTH'h0000_0090, FULLWORD, `DATA_WIDTH'hFBED_4C97, 8);
    burst_read(`ADDR_WIDTH'h0000_0240, BYTE, 32);

    repeat(5) @(posedge clk);

    burst_write(`ADDR_WIDTH'h0000_0070, HALFWORD, `DATA_WIDTH'hA39C_B7E1, 16);
    burst_read(`ADDR_WIDTH'h0000_0038, FULLWORD, 8);

    #20 $finish(1);
  end

  final
  begin
    $writememh("ram.hex",memory.ram);
    $display("Simulation Finished");
  end

  task async_reset();
    repeat(5) @(posedge clk);
    rst_n   <= '1;    
  endtask : async_reset

  task single_write(input bit [`ADDR_WIDTH-1:0] address_sw, input dsel_type dsel_sw, input bit [`DATA_WIDTH-1:0] data_sw);
    $display("\n----------------------------------------------------------------------------------------------------------");
    $display("-----------------------------------------------------------------------------------------------------------");

    fork
      begin
        @(posedge clk);
        trnsfr  <= '1;
        wr      <= '1;
        dsel    <= dsel_sw;
        address <= address_sw;
        data_in <= data_sw;
        @(posedge clk);
        trnsfr  <= '0;
        wr      <= '0;
        repeat(3) @(posedge clk);       
      end
      begin
        wait(apb2apb.pbus.ready);
        if (mem_wr)
        begin
          #5;
          write_addr_in = mem_bus.mem_address;
          write_data_in = mem_bus.mem_data_in;          
        end
        wait(~apb2apb.pbus.ready);
      end
      begin
        wait(apb2apb.pbus.ready);
        wait(~apb2apb.pbus.ready);
        if (mem_wr)
        begin
          $display("\nMemory Write Address:: %h \t Memory Write Data:: %h \t @time %0t ns \t (%s write)", write_addr_in, write_data_in, $realtime()-10, dsel.name());
        end
        else
        begin
          $display("\nError response for %s write transaction. Memory address %h is inaccessible \t @time %0t ns", dsel.name(), address, $realtime()-10);
        end
      end
    join

    $display("\n----------------------------------------------------------------------------------------------------------");
    $display("-----------------------------------------------------------------------------------------------------------");
  endtask : single_write

  task single_read(input bit [`ADDR_WIDTH-1:0] address_sr, input dsel_type dsel_sr);
    $display("\n----------------------------------------------------------------------------------------------------------");
    $display("-----------------------------------------------------------------------------------------------------------");

    fork
      begin
        @(posedge clk);
        trnsfr  <= '1;
        wr      <= '0;
        dsel    <= dsel_sr;
        address <= address_sr;
        @(posedge clk);
        trnsfr  <= '0;
        repeat(3) @(posedge clk);       
      end
      begin
        wait(apb2apb.pbus.ready);
        if (mem_rd)
        begin
          #5;
          read_addr_in  = mem_bus.mem_address;
          read_data_out = data_out;      
        end
        wait(~apb2apb.pbus.ready);
      end
      begin
        wait(apb2apb.pbus.ready);
        wait(~apb2apb.pbus.ready)
        if (mem_rd)
        begin
          $display("\nMemory Read Address :: %h \t Memory Read Data :: %h \t @time %0t ns \t (%s read)", read_addr_in, read_data_out, $realtime()-10, dsel.name());
        end
        else
        begin
          $display("\nError response for %s read transaction. Memory address %h is inaccessible \t @time %0t ns", dsel.name(), address, $realtime()-10);
        end
      end
    join

    $display("\n----------------------------------------------------------------------------------------------------------");
    $display("----------------------------------------------------------------------------------------------------------\n");  
  endtask : single_read

  task burst_write(input bit [`ADDR_WIDTH-1:0] address_bw, input dsel_type dsel_bw, input bit [`DATA_WIDTH-1:0] data_bw, input int count);
    $display("\n----------------------------------------------------------------------------------------------------------");
    $display("-----------------------------------------------------------------------------------------------------------");

    fork
      begin
        @(posedge clk);
        trnsfr  <= '1;
        wr      <= '1;
        dsel    <= dsel_bw;
        for (int i = 0; i < count; i++) 
        begin
          address <= address_bw + i;
          data_in <= data_bw + i;
          repeat(3) @(posedge clk);
        end
        trnsfr  <= '0;        
      end
      begin
        for (int i = 0; i < count; i++) 
        begin
          wait(apb2apb.pbus.ready);
          if (mem_wr)
          begin
            #5;
            write_addr_in = mem_bus.mem_address;
            write_data_in = mem_bus.mem_data_in;          
          end
          wait(~apb2apb.pbus.ready);
        end
      end
      begin   
        for (int i = 0; i < count; i++)
        begin
          wait(apb2apb.pbus.ready);
          wait(~apb2apb.pbus.ready);
          if (mem_wr)
          begin
            $display("\nMemory Write Address:: %h \t Memory Write Data:: %h \t @time %0t ns \t (%s write)", write_addr_in, write_data_in, $realtime()-10, dsel.name());          
          end
          else
          begin
            $display("\nError response for %s write transaction. Memory address %h is inaccessible \t @time %0t ns", dsel.name(), address, $realtime()-10);
          end
        end
      end
    join

    $display("\n----------------------------------------------------------------------------------------------------------");
    $display("-----------------------------------------------------------------------------------------------------------");   
  endtask : burst_write

  task burst_read(input bit [`ADDR_WIDTH-1:0] address_sr, input dsel_type dsel_br, input int count);
    $display("\n----------------------------------------------------------------------------------------------------------");
    $display("-----------------------------------------------------------------------------------------------------------");

    fork
      begin
        @(posedge clk);
        trnsfr  <= '1;
        wr      <= '0;
        dsel    <= dsel_br;
        for (int i = 0; i < count; i++) 
        begin
          address <= address_sr + i;
          repeat(3) @(posedge clk);
        end
        trnsfr  <= '0;        
      end
      begin
        for (int i = 0; i < count; i++) 
        begin
          wait(apb2apb.pbus.ready);
          if (mem_rd)
          begin
            #5;
            read_addr_in  = mem_bus.mem_address;
            read_data_out = data_out;          
          end
          wait(~apb2apb.pbus.ready);
        end
      end
      begin   
        for (int i = 0; i < count; i++)
        begin
          wait(apb2apb.pbus.ready);
          wait(~apb2apb.pbus.ready);
          if (mem_rd)
          begin
            $display("\nMemory Read Address :: %h \t Memory Read Data :: %h \t @time %0t ns \t (%s read)", read_addr_in, read_data_out, $realtime()-10, dsel.name());          
          end
          else
          begin
            $display("\nError response for %s read transaction. Memory address %h is inaccessible \t @time %0t ns", dsel.name(), address, $realtime()-10);
          end
        end
      end
    join

    $display("\n----------------------------------------------------------------------------------------------------------");
    $display("----------------------------------------------------------------------------------------------------------\n");       
  endtask : burst_read

endmodule