// § elabRhsSharesDefParamChain475
// two imported typedef-typed parameters from two packages in a child
package a;
  typedef logic [3:0] t;
  typedef logic [5:0] u;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
package c;
  import a::*;
  parameter u PC = 9;
endpackage
module sub(output logic [3:0] y, output logic [5:0] z);
  import b::*;
  import c::*;
  assign y = PB;
  assign z = PC;
endmodule
module top(output logic [3:0] y, output logic [5:0] z);
  sub u(y, z);
endmodule
