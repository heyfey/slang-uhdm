interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_c3_p2 #(
  parameter int R = 4, parameter int Q = 2
)(
  input logic clk,
  ifc4.host  arr[R*2]
);
endmodule
module top;
  logic clk;
  ifc4 arr[8]();
  leaf_c3_p2 u (clk, arr);
endmodule
