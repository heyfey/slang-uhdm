// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define O1 `VS
`define O2 `O1
module top;
  int a, b;
  initial $display("%s %s %0d", `O1, `O2, a + b);
endmodule
