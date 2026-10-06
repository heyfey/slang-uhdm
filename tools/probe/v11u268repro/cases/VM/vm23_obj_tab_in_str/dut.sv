// § macroStrBodyLen268
`define TB `"a		b`"
module top; int a;
  initial $display("%s %0d", `TB, a + 1);
endmodule
