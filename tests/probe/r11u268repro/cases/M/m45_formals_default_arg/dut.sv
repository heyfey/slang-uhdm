// § macroStrBodyLen268
`define FD(x=dd) `"x``-``tail`"
module top;
  int a, b;
  initial $display("%s %0d", `FD(), a + b);
endmodule
