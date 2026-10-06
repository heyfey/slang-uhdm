// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top;
`include "body.svh"
  string s;
  initial s = h(1, 2);
endmodule
