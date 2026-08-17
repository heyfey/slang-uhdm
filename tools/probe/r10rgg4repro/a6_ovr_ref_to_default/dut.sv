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
module mid_a6 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_a #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[4]();
  mid_a6 m (clk, arr);
endmodule
