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
module mid_v4e #(parameter int R = 4)(input logic clk, ifc4.host arr[6]);
  localparam int LR = R;
  leaf_a #(.R(LR)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v4e #(.R(6)) m (clk, arr);
endmodule
