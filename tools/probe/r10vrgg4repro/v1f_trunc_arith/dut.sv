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
module top;
  logic clk;
  ifc4 arr[2]();
  leaf_v1d #(.R(3*2)) u (clk, arr);
endmodule
