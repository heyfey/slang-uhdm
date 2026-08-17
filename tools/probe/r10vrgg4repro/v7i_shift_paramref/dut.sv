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
module mid_v7i_shift_paramref #(parameter int P = 3)(input logic clk, ifc4.host arr[6]);
  leaf_a #(.R(P<<1)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v7i_shift_paramref  m (clk, arr);
endmodule
