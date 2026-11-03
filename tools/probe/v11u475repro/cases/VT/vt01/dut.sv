// § elabRhsSharesDefParamChain475
// two different child modules reading PB, and the top too
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module s1(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
module s2(output logic [3:0] y);
  import b::*;
  assign y = PB + 1;
endmodule
module top(output logic [3:0] y1, y2, y3);
  import b::*;
  s1 u1(y1);
  s2 u2(y2);
  assign y3 = PB;
endmodule
