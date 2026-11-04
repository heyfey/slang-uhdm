// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top; string s; int x;
  initial x = (`VS == s) ? 1 : 0;
endmodule
