// § logEquivIsEqOp401
module top;
  logic a, b, c, y;
  assign y = (a <-> b) <-> c;
  initial if (a <-> !b) y = 1;
endmodule
