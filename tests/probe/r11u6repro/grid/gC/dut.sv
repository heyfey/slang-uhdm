// gC — ARITHMETIC-of-ref, no query call: the FOLD half alone.
package p;
  parameter int W = 20;
  typedef logic [W-1:0] vec_t;
  parameter vec_t V = 20'hABCDE;
endpackage
module top;
  import p::*;
  logic [W-1:0] x;
  assign x = V;
endmodule
