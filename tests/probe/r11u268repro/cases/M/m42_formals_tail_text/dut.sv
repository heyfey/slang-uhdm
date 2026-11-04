// § macroStrBodyLen268
`define FT(x) `"x``-``tail`", x
module top;
  int a, b, zz;
  initial $display("%s %0d %0d", `FT(zz), a + b);
endmodule
