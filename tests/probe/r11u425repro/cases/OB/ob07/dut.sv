// § oneTickUpperBNormalized425 (control: lowercase spellings already lowercase)
module top(input a, output o, output p, output q);
  assign o = a & 1'b0;
  assign p = a | 1'bx;
  assign q = a ^ 1'bX;
endmodule
