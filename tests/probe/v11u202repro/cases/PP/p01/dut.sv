// § portPackedBareImplicitTruncates202v
module sub #(parameter N = 2, parameter W = 4) (input [N-1:0] [W-1:0] a, output [N-1:0][W-1:0] d);
  assign d = a;
endmodule
module p01 (input [2:0][4:0] a, output [2:0][4:0] d);
  sub #(.N(3), .W(5)) u (.a(a), .d(d));
endmodule
