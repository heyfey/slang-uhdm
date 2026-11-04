// § modImpCopyTdChainHomeTop473
// an interface imports b
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
interface ifc;
  import b::*;
  logic [3:0] v;
  assign v = PB;
endinterface
module top;
  ifc u();
endmodule
