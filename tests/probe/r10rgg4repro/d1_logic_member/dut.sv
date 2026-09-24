interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_d1 #(parameter int R = 4)(input logic clk);
  logic [R-1:0] v;
  logic         w [R];
  assign v = '0;
endmodule
module mid_d1 #(parameter int R = 4)(input logic clk);
  leaf_d1 #(.R(R)) u (clk);
endmodule
module top;
  logic clk;
  mid_d1 #(.R(6)) m (clk);
endmodule
