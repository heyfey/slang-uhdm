module child #(parameter N = 2) (input wire [N-1:0] a, output wire [N-1:0] b);
  wire [N-1:0] t;
  assign t = a;
  assign b = t;
endmodule

module \a.b.C #(parameter W = 5) (input wire [W-1:0] x, output wire [W-1:0] y);
  child #(.N(W)) c1 (.a(x), .b(y));
endmodule
