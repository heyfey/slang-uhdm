// § modImpCopyTdChainHomeTop473
// ternary operand and concatenation
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(input logic s, output logic [7:0] y);
  import b::*;
  assign y = s ? {PB, PB} : 8'd0;
endmodule
