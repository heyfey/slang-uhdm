// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top;
  string s; bit c; int a;
  initial s = c ? `VS : "x"; initial a = 1;
endmodule
