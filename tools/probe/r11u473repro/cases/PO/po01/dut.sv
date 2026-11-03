// § modImpCopyTdChainHomeTop473
// CONTROL (no module import; the package-own face, not written): a package's own parameter of an imported typedef, no module reads it
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top;
endmodule
