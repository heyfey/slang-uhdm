interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_d7 #(parameter int R = 4)(input logic clk);
  localparam logic [R-1:0] M = '1;
endmodule
module mid_d7 #(parameter int R = 4)(input logic clk);
  leaf_d7 #(.R(R)) u (clk);
endmodule
module top;
  logic clk;
  mid_d7 #(.R(6)) m (clk);
endmodule
