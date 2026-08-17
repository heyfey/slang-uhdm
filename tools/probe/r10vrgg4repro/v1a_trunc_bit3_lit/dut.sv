interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_v1a #(
  parameter bit [2:0] R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[4]();
  leaf_v1a #(.R(12)) u (clk, arr);
endmodule
