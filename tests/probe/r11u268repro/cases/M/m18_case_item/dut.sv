// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top;
  string s; int r;
  always_comb case (s) `VS: r = 1; default: r = 0; endcase
endmodule
