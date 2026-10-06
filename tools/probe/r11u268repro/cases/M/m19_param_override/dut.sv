// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module sub #(parameter string P = "d") (); endmodule
module top;
  sub #(.P(`VS)) u1 (); sub #(`VS) u2 ();
endmodule
