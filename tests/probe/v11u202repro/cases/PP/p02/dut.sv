// § defPortPackedTsKeepsWholeSpan200
module sub #(parameter N = 2) (input wire [N-1:0] [3:0] a, output wire [N-1:0][3:0] d);
  assign d = a;
endmodule
module p02 (input wire [2:0][3:0] a, output wire [2:0][3:0] d);
  sub #(3) u (.a(a), .d(d));
endmodule
