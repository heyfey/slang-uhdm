interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_b7_shortint #(
  parameter shortint R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_b7_shortint #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_b7_shortint #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_b7_shortint #(.R(6)) m (clk, arr);
endmodule
