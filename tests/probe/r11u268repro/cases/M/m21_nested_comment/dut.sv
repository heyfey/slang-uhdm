// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define O3 `VS   // the chain with a comment
module top;
  int a, b;
  initial $display("%s %0d", `O3, a + b);
endmodule
