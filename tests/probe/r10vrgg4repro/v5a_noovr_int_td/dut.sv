interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
typedef int myint_v;
module leaf_v5a_noovr_int_td #(
  parameter myint_v R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[4]();
  leaf_v5a_noovr_int_td u (clk, arr);
endmodule
