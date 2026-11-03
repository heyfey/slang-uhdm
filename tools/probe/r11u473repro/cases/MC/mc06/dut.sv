// § modImpCopyTdChainHomeTop473
// the module imports both packages
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import a::*;
  import b::*;
  assign y = PA ^ PB;
endmodule
