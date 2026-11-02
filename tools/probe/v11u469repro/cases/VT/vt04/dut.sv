// § importCopyTsInstByRole469
// a one-bit typedef and an int unsigned typedef
package a;
  typedef bit b1_t;
  typedef int unsigned u_t;
  parameter b1_t PB = 1'b1;
  parameter u_t PU = 32'd7;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
