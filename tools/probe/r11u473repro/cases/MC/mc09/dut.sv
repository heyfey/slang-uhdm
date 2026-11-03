// § modImpCopyTdChainHomeTop473
// CONTROL the package writes the type qualified (a::t)
package a;
  typedef logic [3:0] t;
endpackage
package b;
  parameter a::t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
