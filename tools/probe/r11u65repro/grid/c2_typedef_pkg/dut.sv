// ROAD C control: the SAME typedef shapes declared in a PACKAGE, whose bound
// reads a package parameter (a package is compiled twice: Reduce::Yes then No).
package pk;
  parameter int unsigned DATA_SIZE = 64;
  parameter int unsigned DEPTH     = 4;
  parameter int unsigned NDATA     = 2;
  typedef logic [NDATA-1:0][DATA_SIZE-1:0] mem_t [DEPTH];
  typedef logic [NDATA-1:0]                pk1_t;
endpackage
module dut (output logic [1:0] o);
  pk::mem_t mem;
  pk::pk1_t p1;
  assign o = p1 | mem[0][0][1:0];
endmodule
