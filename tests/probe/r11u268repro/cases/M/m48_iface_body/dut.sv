// § macroStrBodyLen268
`define NM SVAUNIT
`define MJ 3
`define MN 2
`define VS `"`NM``-```MJ``.```MN`"
interface ifc;
  logic [7:0] x;
  initial $display("%s %0d", `VS, x + 1);
endinterface
module top; ifc i (); endmodule
