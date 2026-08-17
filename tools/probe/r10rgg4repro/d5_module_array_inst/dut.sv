interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module tiny_d5(input logic clk); endmodule
module leaf_d5 #(parameter int R = 4)(input logic clk);
  tiny_d5 u[R] (clk);
endmodule
module mid_d5 #(parameter int R = 4)(input logic clk);
  leaf_d5 #(.R(R)) u (clk);
endmodule
module top;
  logic clk;
  mid_d5 #(.R(6)) m (clk);
endmodule
