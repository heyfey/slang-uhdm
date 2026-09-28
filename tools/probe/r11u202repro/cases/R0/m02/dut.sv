// § defPortPackedTsKeepsWholeSpan200
module sub #(parameter A = 2, B = 3)(input bit [A-1:0][B-1:0] x, output bit [A-1:0][B-1:0] y);
  assign y = x;
endmodule
module m02(input bit [3:0][2:0] x, output bit [3:0][2:0] y);
  sub #(4, 3) u(x, y);
endmodule
