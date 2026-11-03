// § modImpCopyTdChainHomeTop473
// an explicit import of the parameter into the module
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::PB;
  assign y = PB;
endmodule
