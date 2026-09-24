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
module mid_a7 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_a #(R) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_a7 #(6) m (clk, arr);
endmodule
