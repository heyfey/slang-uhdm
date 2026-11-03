// § modImpCopyTdChainHomeTop473
// CONTROL (no module import; the package-own face, not written): a parameter reading an imported parameter
package a;
  typedef logic [5:0] t;
  parameter t PA = 6'd2;
endpackage
package b;
  import a::*;
  parameter t PB = PA + 6'd1;
endpackage
module top;
endmodule
