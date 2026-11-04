// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define SQ(x) `"x`"
module top;
  int a, b;
  initial $display("%s %s %0d", `SQ(abc), `VS, a + b);
endmodule
