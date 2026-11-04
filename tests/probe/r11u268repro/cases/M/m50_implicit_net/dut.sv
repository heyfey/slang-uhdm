// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top;
  string s;
  assign w = (s == `VS) ^ 1'b1;
endmodule
