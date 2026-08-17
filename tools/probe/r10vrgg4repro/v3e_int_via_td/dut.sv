interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
typedef int myint_v;
module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v3e_int_via_td #(parameter myint_v P = 6)(input logic clk, ifc4.host arr[6]);
  leaf_a #(.R(P)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v3e_int_via_td m (clk, arr);
endmodule
