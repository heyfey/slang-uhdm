interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_v1d #(
  parameter bit [1:0] R = 2
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v1d #(parameter bit [2:0] P = 6)(input logic clk, ifc4.host arr[2]);
  leaf_v1d #(.R(P)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[2]();
  mid_v1d m (clk, arr);
endmodule
