// § macroStrBodyLen268
`define F(x) `"x``-``tail`"
module top;
  int a, b;
  initial $display("%s %0d", `F(
     zz), a + b);
endmodule
