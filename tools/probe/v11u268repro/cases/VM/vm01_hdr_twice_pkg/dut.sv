// § macroStrBodyLenDupEvent268v
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
package p1;
`include "body.svh"
endpackage
package p2;
`include "body.svh"
endpackage
module top(output string o1, o2);
  assign o1 = p1::f(1);
  assign o2 = p2::f(2);
endmodule
