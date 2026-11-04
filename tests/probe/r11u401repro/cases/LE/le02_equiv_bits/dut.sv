// § logEquivIsEqOp401
module top(input logic a, b, output logic y);
  assign y = (a <-> b) || !a;
endmodule
