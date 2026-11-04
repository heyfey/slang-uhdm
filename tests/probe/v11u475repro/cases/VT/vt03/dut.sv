// § elabRhsSharesDefParamChain475
// an interface instance inside a child reading PB
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
interface ifc;
  import b::*;
  logic [3:0] y;
  assign y = PB;
endinterface
module sub;
  ifc i();
endmodule
module top;
  sub u();
endmodule
