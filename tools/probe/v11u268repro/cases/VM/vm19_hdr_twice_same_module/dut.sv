// § macroStrBodyLenDupEvent268v
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module top; int a, b;
  initial begin
`include "body.svh"
`include "body.svh"
  end
endmodule
