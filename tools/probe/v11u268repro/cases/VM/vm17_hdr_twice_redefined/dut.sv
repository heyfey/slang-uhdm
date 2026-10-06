// § macroStrBodyLenDupEvent268v
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module m1; int a, b;
`include "body.svh"
endmodule
`undef VS
`define VS `"ab`"
module m2; int a, b;
`include "body.svh"
endmodule
module top; m1 u1(); m2 u2(); endmodule
