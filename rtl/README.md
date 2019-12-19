# System Verilog APB2APB Bridge
---------------------------------------------------

GitHub repository: https://github.com/amiteee78/APB2APB_Bridge

## RTL Design

All the modules & interfaces are developed using System Verilog Language & System Verilog Advanced Features.

## apb_bridge.sv

- The purpose of this module is to provide **interconnection** between APB Master & APB Slave.
- A **master module** & a **slave module** are created with proper interfacing from apbif module.

-------------------------------------------------------------------------------

## apb_intf.sv

- Two individual interfaces (**apbif**, **memif**) are defined in this design.
- apbif interface provides necessary interface I/O, protocol signlas & modports for test bench, apb_bridge, apb_master, apb_slave & apb_mem modules.
- memif interface provides necessary interface I/O, signals & modports for test bench & apb_mem module.

-------------------------------------------------------------------------------

## apb_master.sv

- apb_master drives necessary signals from CPU end to run the slaves according to the **APB transaction protocol**.
- apb_master module is designed using a Finite State Machine having 3 always block...
  * A **sequential block** to define the state register.
  * A **combinational block** to define the next state logic.
  * A **combinational block** to define the output logic.
- The **FSM** of the master module controls the three operating states (**IDLE**, **SETUP** & **ACCESS**) of APB protocol.
- Binary encoding is used to define the transitions among three different states.
- A strobe encoder is utilized to enable memory bytes accrodingly during **FULLWORD**, **HALFWORD** or **BYTE** write transaction.
- The strobe encoding depends on **APB Address Bus (addr)** & **Data Selection Type (dsel)** during write transfer only. Any unaligned write transfer is restricted using some fixed strobes.

  **List of strobe signal value for some fixed write transfer.**

      FULLWORD          : STROBE = 1111
      LOWER HALFWORD    : STROBE = 0011
      UPPER HALFWORD    : STROBE = 1100
      FIRST BYTE        : STROBE = 0001
      SECOND BYTE       : STROBE = 0010
      THIRD BYTE        : STROBE = 0100
      FOURTH BYTE       : STROBE = 1000

-------------------------------------------------------------------------------

## apb_slave.sv

- apb_slave receives necessary signals from CPU end to access the memory according to the **APB transaction protocol**.
- Internal registers define necessary signals to complete sucessful read or write transfers.
- A strobe decoder is utilized to filter out read data from memory during **FULLWORD**, **HALFWORD** or **BYTE** read transaction.

  **List of decoded value for some fixed read transfer.**

      STROBE = 1111    : Decoded Value  = 0xFFFF_FFFF 
      STROBE = 0011    : Decoded Value  = 0x0000_FFFF     
      STROBE = 1100    : Decoded Value  = 0xFFFF_0000     
      STROBE = 0001    : Decoded Value  = 0x0000_00FF     
      STROBE = 0010    : Decoded Value  = 0x0000_FF00     
      STROBE = 0100    : Decoded Value  = 0x00FF_0000     
      STROBE = 1000    : Decoded Value  = 0xFF00_0000     
      STROBE = 0000    : Decoded Value  = 0x0000_0000

-------------------------------------------------------------------------------

## apb_mem.sv

- apb_mem module is a System Verilog Behavioral Model of a dual port SRAM (individual read & write channel).
- The size of the memory can be changed by modifying the 'MEM_SIZE' macro defined in 'apb_arch.svh' file.
- In the initial functional simulation, 1KB of SRAM is used for FULLWORD, HALFWORD & BYTE access.
- mem_be input port controls which memory bytes are allowed to access & which are not.