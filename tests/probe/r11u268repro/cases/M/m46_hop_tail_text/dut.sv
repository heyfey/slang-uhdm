// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define O5 `VS, 7
module top;
  int a, b;
  initial $display("%s %0d %0d", `O5, a + b);
endmodule
