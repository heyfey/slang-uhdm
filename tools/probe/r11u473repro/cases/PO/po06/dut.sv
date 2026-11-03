// § modImpCopyTdChainHomeTop473
// CONTROL (no module import; the package-own face, not written): three packages: c imports b's parameter's typedef from a
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
package c;
  import a::*;
  parameter t PC = 6;
endpackage
module top;
endmodule
