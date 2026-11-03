// § modImpCopyTdChainHomeTop473
// child parameter default from PB, overridden in one instance
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module sub #(parameter int P = b::PB) (output logic [3:0] y);
  assign y = P;
endmodule
module top(output logic [3:0] y1, y2);
  import b::*;
  sub u1(y1);
  sub #(.P(PB + 1)) u2(y2);
endmodule
