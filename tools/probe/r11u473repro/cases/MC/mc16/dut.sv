// § modImpCopyTdChainHomeTop473
// a port actual and an override read the imported parameter
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module sub #(parameter logic [3:0] Q = 0) (input logic [3:0] i, output logic [3:0] o);
  assign o = i ^ Q;
endmodule
module top(output logic [3:0] y);
  import b::*;
  sub #(.Q(PB)) u(.i(PB), .o(y));
endmodule
