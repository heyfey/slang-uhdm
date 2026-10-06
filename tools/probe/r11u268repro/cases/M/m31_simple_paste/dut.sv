// § macroStrBodyLen268
`define SP `"a``-``b`"
module top;
  int a, b;
  initial $display("%s %0d", `SP, a + b);
endmodule
