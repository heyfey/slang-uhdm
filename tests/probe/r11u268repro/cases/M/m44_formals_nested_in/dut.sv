// § macroStrBodyLen268
`define NM SVAUNIT
`define FN(x) `"`NM``-``x`"
module top;
  int a, b;
  initial $display("%s %0d", `FN(7), a + b);
endmodule
