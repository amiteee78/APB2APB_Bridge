/*********************************************************/
/*  ***************************************************  */
/*  **                                               **  */
/*  **         Architecture Specifications           **  */
/*  **                                               **  */
/*  ***************************************************  */
/*********************************************************/

`ifndef BASE_ADDR
  `define BASE_ADDR 32'h0000_0100
`endif

`ifndef ADDR_WIDTH
  `define ADDR_WIDTH 32
`endif

`ifndef DATA_WIDTH
  `define DATA_WIDTH 32
`endif

`ifndef MEM_SIZE
  `define MEM_SIZE 256
`endif

`ifndef MEM_WIDTH
  `define MEM_WIDTH 8
`endif

`ifndef MEM_DEPTH
  `define MEM_DEPTH `DATA_WIDTH/`MEM_WIDTH
`endif

`ifndef STRB_SIZE
  `define STRB_SIZE 4
`endif

`ifndef MEM_BYTE
  `define MEM_BYTE `MEM_SIZE*`MEM_DEPTH // 1Kbyte Memory
`endif