// § modImpCopyTdChainHomeTop473
// typedef range from a parameter of a
package a;
  parameter int W = 6;
  typedef logic [W-1:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 9;
endpackage
module top(output logic [5:0] y);
  import b::*;
  assign y = PB;
endmodule
