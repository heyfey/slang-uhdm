interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_c1_p #(
  parameter int R = 4, parameter int Q = 2
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_c1_p #(parameter int R = 4, parameter int Q = 2)(input logic clk, ifc4.host arr[R]);
  leaf_c1_p #(.R(R), .Q(Q)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_c1_p #(.R(6)) m (clk, arr);
endmodule
