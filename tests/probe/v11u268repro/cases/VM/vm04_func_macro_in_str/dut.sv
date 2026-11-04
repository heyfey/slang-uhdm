// § macroStrBodyLen268
`define F(x) x``_y
`define VS `"`F(abc)-1.2`"
module top; int a;
  initial $display("%s %0d", `VS, a + 1);
endmodule
