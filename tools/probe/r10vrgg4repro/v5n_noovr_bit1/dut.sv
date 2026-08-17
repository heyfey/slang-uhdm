interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_v5n_noovr_bit1 #(
  parameter bit R = 1
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[1]();
  leaf_v5n_noovr_bit1 u (clk, arr);
endmodule
