// § oneTickUpperBNormalized425
module top(input a, output o, output p, output q);
  assign o = a & 1'B0;
  assign p = a | 1'B1;
  assign q = a ^ 1'Bx;
endmodule
