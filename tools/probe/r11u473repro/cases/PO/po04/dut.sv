// § modImpCopyTdChainHomeTop473
// CONTROL (no module import; the package-own face, not written): CONTROL the type written qualified
package a;
  typedef logic [3:0] t;
endpackage
package b;
  parameter a::t PB = 5;
endpackage
module top;
endmodule
