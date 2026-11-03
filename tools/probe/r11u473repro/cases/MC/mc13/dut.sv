// § modImpCopyTdChainHomeTop473
// a module variable initialized by the imported parameter
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top;
  import b::*;
  logic [3:0] w = PB;
endmodule
