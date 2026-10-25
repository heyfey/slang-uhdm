// § elabBasedLitLowerBase427
module sub #(parameter B = 4'B10x1, parameter C = 'B101, parameter H = 'HFF, parameter G = 8'HxF, parameter J = 4'BZ01?, parameter K = 'b1X)(input a, output o);
  assign o = a;
endmodule
module top(input a, output [1:0] o);
  sub u1(.a(a), .o(o[0]));
  sub u2(.a(a), .o(o[1]));
endmodule
