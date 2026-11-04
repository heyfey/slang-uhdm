// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
`define TK
`ifdef TK
  `define BR `"`NM``-```MJ``+``yes`"
`else
  `define BR `"`NM``-```MJ``+``no`"
`endif
module top;
  int a, b;
  initial $display("%s %0d", `BR, a + b);
endmodule
