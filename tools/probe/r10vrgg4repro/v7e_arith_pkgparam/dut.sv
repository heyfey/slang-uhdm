interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
package pk_v7e;
  parameter int PR = 4;
endpackage
module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v7e_arith_pkgparam #(parameter int Z = 0)(input logic clk, ifc4.host arr[6]);
  leaf_a #(.R(pk_v7e::PR+2)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v7e_arith_pkgparam  m (clk, arr);
endmodule
