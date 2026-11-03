// § modImpCopyTdChainHomeTop473
// CONTROL the module reads the home package's own parameter
package a;
  typedef logic [3:0] t;
  parameter t PA = 3;
endpackage
module top(output logic [3:0] y);
  import a::*;
  assign y = PA;
endmodule
