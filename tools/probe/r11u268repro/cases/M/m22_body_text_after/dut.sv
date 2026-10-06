// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define V3 `"`NM``-```MJ`", "z"
module top;
  int a, b;
  initial $display("%s %s %0d", `V3, a + b);
endmodule
