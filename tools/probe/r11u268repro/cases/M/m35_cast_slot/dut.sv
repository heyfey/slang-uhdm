// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top;
  int n; string s;
  initial begin s = `VS; n = s.len() + $bits(`VS); end
endmodule
