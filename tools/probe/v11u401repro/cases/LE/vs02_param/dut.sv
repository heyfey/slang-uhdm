// § logEquivIsEqOp401
module top;
  parameter P = (1'b1 <-> 1'b0);
  localparam Q = P <-> 1'b0;
  logic y;
  assign y = Q;
endmodule
