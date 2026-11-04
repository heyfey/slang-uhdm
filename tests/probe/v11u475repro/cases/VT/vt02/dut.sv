// § elabRhsSharesDefParamChain475
// one child instanced twice under two different parents
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module sub(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
module m1(output logic [3:0] y);
  sub s(y);
endmodule
module m2(output logic [3:0] y);
  sub s(y);
endmodule
module top(output logic [3:0] y1, y2);
  m1 a1(y1);
  m2 a2(y2);
endmodule
