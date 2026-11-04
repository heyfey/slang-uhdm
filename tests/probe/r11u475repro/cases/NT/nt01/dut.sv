// § elabRhsSharesDefParamChain475
// two levels down, a child reads PB in a continuous assignment, the middle module reads it too
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module leaf(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
module mid(output logic [3:0] y, output logic [3:0] z);
  import b::*;
  leaf l(y);
  assign z = PB;
endmodule
module top(output logic [3:0] y, output logic [3:0] z); mid m(y, z); endmodule
