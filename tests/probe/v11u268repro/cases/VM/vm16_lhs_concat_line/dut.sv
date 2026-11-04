// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top; string s; int a, b;
  initial begin s = `VS; a = b + 1; end
endmodule
