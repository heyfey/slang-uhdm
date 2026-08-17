interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v7d_arith_pure_lit #(parameter int Z = 0)(input logic clk, ifc4.host arr[6]);
  leaf_a #(.R(4+2)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v7d_arith_pure_lit  m (clk, arr);
endmodule
