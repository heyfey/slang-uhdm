interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_d3 #(parameter int R = 4)(input logic clk, ifc4.host s);
  logic [R-1:0] v;
endmodule
module mid_d3 #(parameter int R = 4)(input logic clk, ifc4.host s);
  leaf_d3 #(.R(R)) u (clk, s);
endmodule
module top;
  logic clk;
  ifc4 s();
  mid_d3 #(.R(6)) m (clk, s);
endmodule
