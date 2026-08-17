interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_c4_clog2 #(
  parameter int R = 4, parameter int Q = 2
)(
  input logic clk,
  ifc4.host  arr[$clog2(R)]
);
endmodule
module mid_c4_clog2 #(parameter int R = 4, parameter int Q = 2)(input logic clk, ifc4.host arr[$clog2(R)]);
  leaf_c4_clog2 #(.R(R), .Q(Q)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[3]();
  mid_c4_clog2 #(.R(6)) m (clk, arr);
endmodule
