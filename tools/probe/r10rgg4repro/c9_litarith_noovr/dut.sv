interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_c9_litarith #(
  parameter int R = 4, parameter int Q = 2
)(
  input logic clk,
  ifc4.host  arr[3*2]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_c9_litarith u (clk, arr);
endmodule
