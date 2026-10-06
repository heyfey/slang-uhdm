// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define VZ `"`NM``-```MJ`", a + 1
module top;
  int a, b;
  initial $display("%s %0d %0d", `VZ, a + b);
endmodule
