interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module sub_w2 (input logic clk); endmodule
module leaf_w2 #(parameter int R = 4)(input logic clk);
  sub_w2 u_arr [R] (clk);
  ifc4   i_arr [R] ();
endmodule
module top;
  logic clk;
  leaf_w2 #(.R(6)) u (clk);
endmodule
