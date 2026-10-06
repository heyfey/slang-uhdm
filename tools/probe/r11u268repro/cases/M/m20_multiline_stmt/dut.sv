// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top;
  int a, b;
  initial $display("%s %0d", `VS, a +
     b);
endmodule
