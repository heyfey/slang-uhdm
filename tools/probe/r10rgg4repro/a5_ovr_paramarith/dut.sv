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
module mid_a5 #(parameter int R = 4)(input logic clk, ifc4.host arr[R-1]);
  leaf_a #(.R(R-1)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_a5 #(.R(7)) m (clk, arr);
endmodule
