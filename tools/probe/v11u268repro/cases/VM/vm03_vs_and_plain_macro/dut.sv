// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define W 42
module top; int a;
  initial $display("%s %0d %0d", `VS, `W, a + 1);
endmodule
