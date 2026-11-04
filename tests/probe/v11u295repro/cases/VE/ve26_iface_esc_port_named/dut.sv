// § escNameSpanSites295
interface ifc(input logic \c.k );
  logic d;
  assign d = \c.k ;
endinterface
module top(input logic clk, output logic o);
  ifc i (.\c.k (clk));
  assign o = i.d;
endmodule
