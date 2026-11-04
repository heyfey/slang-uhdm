// § elabRhsSharesDefParamChain475
// an interface instance importing b, read by a module
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
module top(output logic [3:0] y);
  ifc i();
  assign y = i.v;
endmodule
