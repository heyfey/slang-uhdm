// § modImpCopyTdChainHomeTop473
// CONTROL a typedef of a typedef in the home
package a;
  typedef logic [3:0] t0;
  typedef t0 t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
