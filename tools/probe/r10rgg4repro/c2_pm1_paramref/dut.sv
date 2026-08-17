interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_c2_pm1 #(
  parameter int R = 4, parameter int Q = 2
)(
  input logic clk,
  ifc4.host  arr[R-1]
);
endmodule
module mid_c2_pm1 #(parameter int R = 4, parameter int Q = 2)(input logic clk, ifc4.host arr[R-1]);
  leaf_c2_pm1 #(.R(R), .Q(Q)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[5]();
  mid_c2_pm1 #(.R(6)) m (clk, arr);
endmodule
