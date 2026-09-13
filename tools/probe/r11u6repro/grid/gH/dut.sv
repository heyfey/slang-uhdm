// gH — the query argument is an OPERATOR tree ($clog2(W+1)), not a name:
// § sysCallArgOperatorTree owns it and neither view rule applies.
package p;
  parameter int W = 31;
  typedef logic [$clog2(W+1)-1:0] vec_t;
  parameter vec_t V = 5'h1F;
endpackage
module top;
  import p::*;
  logic [4:0] x;
  assign x = V;
endmodule
