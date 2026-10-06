// § macroStrBodyLen268
`define P `"plain text`"
module top;
  int a, b;
  initial $display("%s %0d", `P, a + b);
endmodule
