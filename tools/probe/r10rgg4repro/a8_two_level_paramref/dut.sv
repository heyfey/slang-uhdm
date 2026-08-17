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
module mid_a8 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  leaf_a #(.R(R)) u (clk, arr);
endmodule
module out_a8 #(parameter int R = 4)(input logic clk, ifc4.host arr[R]);
  mid_a8 #(.R(R)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  out_a8 #(.R(6)) m (clk, arr);
endmodule
