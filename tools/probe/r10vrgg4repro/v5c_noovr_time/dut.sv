interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_v5c_noovr_time #(
  parameter time R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[4]();
  leaf_v5c_noovr_time u (clk, arr);
endmodule
