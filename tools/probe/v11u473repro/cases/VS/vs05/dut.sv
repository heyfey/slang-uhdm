// § modImpCopyTdChainHomeTop473
// CONTROL home parameter PA read by a module in a nested instance
package a;
  typedef logic [3:0] t;
  parameter t PA = 2;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module sub(output logic [3:0] y);
  import a::*;
  assign y = PA;
endmodule
module top(output logic [3:0] y);
  sub u(y);
endmodule
