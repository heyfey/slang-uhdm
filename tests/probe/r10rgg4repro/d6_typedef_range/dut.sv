interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_d6 #(parameter int R = 4)(input logic clk);
  typedef logic [R-1:0] w_t;
  w_t v;
endmodule
module mid_d6 #(parameter int R = 4)(input logic clk);
  leaf_d6 #(.R(R)) u (clk);
endmodule
module top;
  logic clk;
  mid_d6 #(.R(6)) m (clk);
endmodule
