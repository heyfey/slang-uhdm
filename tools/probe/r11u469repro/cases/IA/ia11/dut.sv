// § importCopyTsInstByRole469
// a byte and shortint typedef
package a;
  typedef byte b_t;
  typedef shortint s_t;
  parameter b_t PB = 8'sd5;
  parameter s_t PS = -16'sd3;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
