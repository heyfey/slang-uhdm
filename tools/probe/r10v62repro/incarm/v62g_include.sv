// v62g — THE SAME typedef TEXT included into TWO DIFFERENT modules.  If slang
// hands both expansions the SAME SyntaxNode, § defBodyTypedefSiteShare62 keys
// two DIFFERENT DesignComponents' typedefs to ONE object -- which Surelog
// never does (its DataTypeMap is per DesignComponent).  Both modules are also
// multiply specialized so the site map is definitely consulted.
module ma62 #(parameter int W = 4) (input logic clk, output logic [1:0] z);
`include "shared_td62.svh"
  sh_t v;
  assign z = (v.op == SB) ? v.sz : 2'b00;
endmodule

module mb62 #(parameter int W = 4) (input logic clk, output logic [1:0] z);
`include "shared_td62.svh"
  sh_t v;
  assign z = (v.op == SC) ? v.sz : 2'b11;
endmodule

module top62g (input logic clk, output logic [7:0] o);
  logic [1:0] a1,a2,b1,b2;
  ma62 #(.W(4)) ua1 (.clk(clk), .z(a1));
  ma62 #(.W(8)) ua2 (.clk(clk), .z(a2));
  mb62 #(.W(4)) ub1 (.clk(clk), .z(b1));
  mb62 #(.W(8)) ub2 (.clk(clk), .z(b2));
  assign o = {a1,a2,b1,b2};
endmodule
