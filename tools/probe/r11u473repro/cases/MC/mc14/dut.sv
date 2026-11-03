// § modImpCopyTdChainHomeTop473
// the imported parameter as an operation operand
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(input logic [3:0] i, output logic [3:0] y);
  import b::*;
  assign y = i + PB;
endmodule
