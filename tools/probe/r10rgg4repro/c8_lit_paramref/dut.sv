interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_c8_lit #(
  parameter int R = 4, parameter int Q = 2
)(
  input logic clk,
  ifc4.host  arr[6]
);
endmodule
module mid_c8_lit #(parameter int R = 4, parameter int Q = 2)(input logic clk, ifc4.host arr[6]);
  leaf_c8_lit #(.R(R), .Q(Q)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_c8_lit #(.R(6)) m (clk, arr);
endmodule
