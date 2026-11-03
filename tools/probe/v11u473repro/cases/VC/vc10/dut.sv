// § modImpCopyTdChainHomeTop473
// qualified read b::PB without import
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  assign y = b::PB;
endmodule
