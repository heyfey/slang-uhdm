// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top; int a;
  initial $display("%0d %s %0d", `__LINE__, `VS, a + 1);
endmodule
