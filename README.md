# System Verilog APB2APB Bridge
---------------------------------------------------

GitHub repository: https://github.com/amiteee78/APB2APB_Bridge

## Introduction

Being a part of Advanced Microcontroller Bus Architecture (AMBA) family, the Advanced Peripheral Bus (APB) provides a low-cost interface optimized for minimal power consumption & reduced interface complexity. A well-defined interface between master & slave device is exploited to control both the read and write access of a SRAM (1KB). The architecture includes both flat testbech and RTL developed in System Verilog language Completely.

- Vivado Simulator tool provides free tool support for the beginners.

- Cadence Incisive Enterprise Simulator tool provides support for advanced learners.

## Table of Contents

<!--ts-->
   * [Features](#Features)
   * [Directory Structure](#Directory-Structure)
   * [Source Files](#Source-Files)
   * [Architecture Specification](#Architecture-Specification)
   * [Interfaces](#Interfaces)
   * [Block Diagram](#Block-Diagram)
   * [Operating States](#Operating-States)
   * [Functional Verification](#Functional-Verification)
      * [Testbench Files](#Testbench-Files)
      * [Vivado Simulation](#Vivado-Simulation)
      * [Cadence Simulation](#Cadence-Simulation)
<!--te-->

## Features

- **AMBA4** protocol supported.
- System Verilog Inteface implemeted.
- Memory access control with external **transfer** signal.
- Self-controlled binary data (**fullword**, **halfword** or **byte**) read & write access.
- Both single-mode & burst-mode memory access.
- configurable memory size according to the width of **address bus** (32 bit).

## Directory Structure

    apb2apb_bridge/arch_specs  : Architecture specification directory.
    apb2apb_bridge/docs        : Documents directory.
    apb2apb_bridge/rtl         : Register Transfer Level source code directory.
    apb2apb_bridge/run_cad     : Cadence simulation directory.
    apb2apb_bridge/run_viv     : Vivado simulation directory.
    apb2apb_bridge/tb          : Flat Testbench directory.

## Source Files

    rtl/apb_bridge.sv          : APB Bridge Top.
    rtl/apbintf.sv             : APB & Memory Interfaces.
    rtl/apb_master.sv          : APB Master.
    rtl/apb_mem.sv             : Single Port SRAM.
    rtl/apb_slave.sv           : APB APB bridge.

## Architecture Specification

This file provides all the specification needed to define the architecture.

`apb2apb_bridge/arch_specs/apb_arch.svh`

| Specification | Value  |
|:------------ |:------------ |
| APB address bus width | 32 bit  |
| APB data bus width  | 32 bit  |
| Memory size | 256 fullword  |
| Memory width | 8 bit  |
| Memory depth  | 4 byte |
| Strobe size  | 4 bit |
| Memory byte  | 1024 byte |

## Interfaces

All the interfaces connecting the test bench, APB master, APB slave and SRAM modules are defined in this file.

`apb2apb_bridge/rtl/apbif.sv`

**List of interface signals between test bench & APB bridge (apbif)**

| Signal  | Source  | Description  |
| :------------ | :------------ | :------------ |
| **clk**  | Clock Source  | Clock. The rising edge of **clk** times all access to the memory.  |
| **rst_n**  | System bus equivalent  | Reset. The system reset signal is active LOW. This signal is normally connected directly to the system bus reset signal.  |
| **dsel**  | APB bridge interface | Data selection. This signal indicates binary data type among **FULLWORD**, **HALFWORD** and **BYTE** for write or read transaction.  |
| **trnsfr**  | APB bridge interface | Transfer activation signal. This signal initiates read or write transfer.  |
| **wr**  | APB bridge interface | Write/Read selection. This signal illustrates write transfer to be initiated when HIGH and read transfer when LOW.  |
| **address**  | APB bridge interface  | Transfer address. This is the address bus which can be upto 32 bits wide and is driven by CPU interface.  |
| **data_in**  | APB bridge interface  | Transfer write data input. This is the write data bus driven by CPU interface during write transfer when **wr** is HIGH. This bus can be upto 32 bits wide.  |
| **data_out**  | APB bridge interface | Transfer read data output. This is the read data bus driven by SRAM device during read transfer when **wr** is LOW. This bus can be upto 32 bits wide.  |

**List of interface signals between APB master & APB slave modules (apbif)**

| Signal | Source  | Description  |
| :------------ | :------------ | :------------ |
| **clk**  | Clock Source  | Clock. The rising edge of **clk** times all transfers on the APB.  |
| **rst_n**  | System bus equivalent  | Reset. The APB reset signal is active LOW. This signal is normally connected directly to the system bus reset signal.  |
| **addr**  | APB master  | Address. This is the APB address bus. It can be up to 32 bits wide and is driven by the peripheral bus master unit.  |
| **sel**  | APB master  | Select. The APB master unit generates this signal to each peripheral bus slave. It indicates that the slave device is selected and that a data transfer is required. There is a **sel** signal for each slave.  |
| **enable**  | APB master  | Enable. This signal indicates the second and subsequent cycles of an APB transfer.  |
| **write**  | APB master  | Direction. This signal indicates an APB write access when HIGH and an APB read access when LOW.  |
| **wdata**  | APB master  | Write data. This bus is driven by the peripheral bus master unit during write cycles when **write** is HIGH. This bus can be up to 32 bits wide.  |
| **strb**  | APB master  | Write strobes. This signal indicates which byte lanes to update during a write transfer. There is one write strobe for each eight bits of the write data bus. Therefore, **strb[n]** corresponds to **wdata[(8n + 7):(8n)]**. Write strobes must not be active during a read transfer.  |
| **ready**  | APB slave  | Ready. The slave uses this signal to extend an APB transfer.  |
| **rdata**  | APB slave  | Read Data. The selected slave drives this bus during read cycles when **write** is LOW. This bus can be up to 32-bits wide.  |
| **slverr**  | APB slave  | This signal indicates a transfer failure. APB peripherals are not required to support the **slverr** pin. This is true for both existing and new APB peripheral designs. Where a peripheral does not include this pin then the appropriate input to the APB master is tied LOW.  |

**List of interface signals between APB bridge & SRAM modules (memif)**

| Signal  | Source  | Description  |
| :------------ | :------------ | :------------ |
| **clk**  | Clock Source  | Clock. The rising edge of **clk** times all access to the memory.  |
| **mem_wr**  | APB bridge interface  | Memory write enable signal. This signal indicates a memory write access when HIGH.  |
| **mem_rd**  | APB bridge interface  | Memory read enable signal. This signal indicates a memory read access when HIGH.  |
| **mem_be**  | APB bridge interface  | Memory byte enable signal. This signal is directly mapped from strb indicating which byte lanes to update during memory write access.  |
| **mem_address**  | APB bridge interface  | Memory address. This is the memory address bus. It can be upto 32 bits wide and is driven by bridge interface.  |
| **mem_data_in**  | APB bridge interface  | Memory write data input. This bus is driven by bridge interface during write access when **mem_wr** is HIGH. This bus can be upto 32 bits wide.  |
| **mem_data_out**  | SRAM interface | Memory read data output. This  bus is driven by SRAM device during read access when mem_rd is HIGH. This bus can be upto 32 bits wide.  |

## Block Diagram

<img src="https://github.com/amiteee78/RTL_design/blob/76e99cc94771de8f5a42a7cdc0ba7e900485fe4b/apb2apb_bridge/docs/apb_interface.png" width="700px">

-------------------------------------------------------------------------------

## Operating States

* **IDLE**: This is the default state of the APB.
* **SETUP**: When a transfer is required the bus moves into the SETUP state, where the appropriate select signal, **sel**, is asserted. The bus only remains in the SETUP state for one clock cycle and always moves to the ACCESS state on the next rising edge of the clock.
* **ACCESS**: The enable signal, **enable**, is asserted in the ACCESS state. The address, write, select, and write data signals must remain stable during the transition from the SETUP to ACCESS state. Exit from the ACCESS state is controlled by the **ready** signal from the slave:

    * If **ready** is held LOW by the slave then the peripheral bus remains in the ACCESS state.
    * If **ready** is driven HIGH by the slave then the ACCESS state is exited and the bus returns to the IDLE state if no more transfers are required. Alternatively, the bus moves directly to the SETUP state if another transfer follows.

<img src="https://github.com/amiteee78/RTL_design/blob/5f0e44b7fd6a5500b9f341255827e54cf1384efe/apb2apb_bridge/docs/APB_FSM.png" width="450px">

## Functional Verification

The design is verified using a System Verilog flat testbench. The test cases checked so far are as follows..........

1. Asynchronous Reset Assertion.
2. Serial single write for fullword & then serial single read for fullword from the same addresses.
3. Serial single write for halfword & then serial single read for halfword from the same addresses.
4. Serial single write for byte & then serial single read for byte from the same addresses.
5. Burst write for fullword & then burst read for fullword from the same addresses.
6. Burst write for halfword & then burst read for halfword from the same addresses. 
7. Burst write for byte & then burst read for byte from the same addresses.
8. Burst write for fullword & then burst read for byte from the same addresses.
9. Burst read for fullword & then burst write for byte from the same addresses.

### Testbench Files

The test bench file includes all the test cases mentioned above.

`tb/apb_bridge_tb.sv`

### Vivado Simulation

The automated simulation file is developed using shell scripting.

`run_viv/run_viv.sh`

This file includes all the necessary commands to invoke vivado RTL simulator tools in the background without prompting the GUI. In addition, the memory file (**ram.hex**) dumped from the test bench is in a jumbled form to observe. To rearrange it, a python file is exploited and sourced at the end of the simulation script. The output from the python source file is **ram_format.hex** which provides the memory contents in a more organized form.

To simulate the design with developed test cases, first the "**run_viv**" directory should be accessed & then the following command should be executed.

`./run_viv.sh <name of your testbench top module>`

For example, in this case the command must be ....

`./run_viv.sh apb_bridge_tb`

Finally the dumped **apb_bridge_tb.vcd** file can be observed to verify the design functionalities.

### Cadence Simulation

The automated simulation file is developed using shell scripting.

`run_cad/run_apb.sh`

This file includes all the necessary commands to set up simulation environment. Generation of the directories, coverage analysis file, tcl file for shm database & Continuing the simulation procedure is controlled by this script.

To simulate the design with developed test cases, first the "**run_cad**" directory should be accessed & then the following command should be executed in the Cshell.

`./run_apb.sh <name of your testbench top module> <name of your DUT top module>`

For example, in this case the command must be ....

`./run_apb.sh apb_bridge_tb apb_bridge`

Finally the dumped **.trn** or **.vcd** file can be observed to verify the design functionalities.