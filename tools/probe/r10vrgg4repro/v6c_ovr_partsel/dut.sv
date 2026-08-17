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
module mid_v6c #(parameter bit [15:0] P = 16'h0006)
               (input logic clk, ifc4.host arr[6]);
  leaf_a #(.R(P[7:0])) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v6c m (clk, arr);
endmodule
