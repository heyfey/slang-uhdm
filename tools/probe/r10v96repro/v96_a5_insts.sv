// r10v96 arm 5 — THREE INSTANCES of the same cast-bearing module (the ELAB
// re-emit road: pendingCastTs drains once per elaborated instance).
module v96leaf #(parameter int W = 8) (input logic [15:0] q, output real o);
  localparam int LK = integer'(W);
  real t;
  always_comb begin
    t = real'(q) + shortreal'(q[7:0]);
  end
  assign o = t + real'(LK);
  initial $display("%0d %0d", longint'(q), time'(q));
endmodule

module v96top;
  logic [15:0] q;
  real a, b, c;
  v96leaf #(.W(4)) i0 (.q(q), .o(a));
  v96leaf #(.W(8)) i1 (.q(q), .o(b));
  v96leaf #(.W(16)) i2 (.q(q), .o(c));
endmodule
