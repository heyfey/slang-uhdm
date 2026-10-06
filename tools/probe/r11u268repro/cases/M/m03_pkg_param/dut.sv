// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
package p;
  parameter string q = `VS;
  parameter int k = 4;
endpackage
module top; import p::*; endmodule
