// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define VC `"`NM``-```MJ`"   // trailing comment
module top;
  int a, b;
  initial $display("%s %0d", `VC, a + b);
endmodule
