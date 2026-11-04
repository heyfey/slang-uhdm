// § macroStrBodyLen268
`define F2(a,b) `"a``-``b`"
module top;
  int a, b;
  initial $display("%s %0d", `F2(pp,qq), a + b);
endmodule
