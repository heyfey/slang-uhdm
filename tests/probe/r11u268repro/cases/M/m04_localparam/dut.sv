// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top;
  localparam string q = `VS; localparam int k = 5;
  string s;
  initial s = q;
endmodule
