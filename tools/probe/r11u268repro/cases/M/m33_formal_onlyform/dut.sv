// § macroStrBodyLen268
`define SF(x) `"x`"
module top;
  int a, b;
  initial $display("%s %0d", `SF(abc), a + b);
endmodule
