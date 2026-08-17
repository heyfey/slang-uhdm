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
module mid_v7c_arith_localparam #(parameter int Z = 0)(input logic clk, ifc4.host arr[6]);
  localparam int LP = 4;
  leaf_a #(.R(LP+2)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v7c_arith_localparam  m (clk, arr);
endmodule
