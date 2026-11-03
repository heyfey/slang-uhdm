// § modImpCopyTdChainHomeTop473
// interface variable initializer reads PB, instantiated
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
interface ifc;
  import b::*;
  logic [3:0] v = PB;
endinterface
module top(output logic [3:0] y);
  ifc u();
  assign y = u.v;
endmodule
