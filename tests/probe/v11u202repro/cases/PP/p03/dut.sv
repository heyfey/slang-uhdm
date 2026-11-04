// § defPortPackedTsKeepsWholeSpan200
module sub #(parameter N = 2) (input signed [N-1:0] [3:0] a, output logic signed [N-1:0][3:0] d);
  assign d = a;
endmodule
module p03 (input signed [2:0][3:0] a, output signed [2:0][3:0] d);
  sub #(3) u (.a(a), .d(d));
endmodule
