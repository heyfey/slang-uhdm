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
module lvl1_v4a #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_a #(.R(R)) u (clk, arr);
endmodule
module lvl2_v4a #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  lvl1_v4a #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  lvl2_v4a #(.R(6)) m (clk, arr);
endmodule
