// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
program pg;
  int a;
  initial $display("%s %0d", `VS, a + 2);
endprogram
module top; endmodule
