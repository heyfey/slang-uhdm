// § elabBasedLitLowerBase427
module top #(parameter A = 4'B1010, parameter B = 4'B10x1, parameter C = 'B101, parameter D = 4'SB1010, parameter E = 4'sb1010, parameter F = 4'Sb10x1, parameter G = 8'HxF, parameter H = 'HFF, parameter I = 8'SHFF, parameter J = 4'BZ01?, parameter K = 'B1x, parameter L = 4'b10X1)(input a, output [7:0] o);
  assign o = {8{a}};
endmodule
