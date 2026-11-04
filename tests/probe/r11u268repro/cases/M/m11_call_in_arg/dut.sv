// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define W(a) a
module top;
  int a, b;
  initial $display("%s %0d", `W(`VS), a + b);
endmodule
