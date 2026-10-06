// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define VL `"`NM``-```MJ \
  tail`"
module top;
  int a, b;
  initial $display("%s %0d", `VL, a + b);
endmodule
