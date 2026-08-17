interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_c6_paren #(
  parameter int R = 4, parameter int Q = 2
)(
  input logic clk,
  ifc4.host  arr[(R)]
);
endmodule
module top;
  logic clk;
  ifc4 arr[4]();
  leaf_c6_paren u (clk, arr);
endmodule
