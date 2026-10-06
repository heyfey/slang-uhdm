// § macroStrBodyLenDupEvent268v
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
package p1;
`include "cls.svh"
endpackage
package p2;
`include "cls.svh"
endpackage
module top; p1::c x; p2::c y; string s;
  initial begin x = new; y = new; s = {x.h(1), y.h(2)}; end
endmodule
