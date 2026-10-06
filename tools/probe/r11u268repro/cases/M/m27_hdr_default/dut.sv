// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
module sub #(parameter string P = `VS, parameter int K = 3) (); endmodule
module top; sub u (); endmodule
