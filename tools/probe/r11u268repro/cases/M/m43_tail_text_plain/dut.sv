// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define VY `"`NM``-```MJ`", 5
module top;
  int a, b;
  initial $display("%s %0d %0d", `VY, a + b);
endmodule
