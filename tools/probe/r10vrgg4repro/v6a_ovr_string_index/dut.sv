interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
package pk_v6a;
  parameter int TAB [0:3] = '{1,2,6,4};
endpackage
module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  leaf_a #(.R(pk_v6a::TAB[2])) u (clk, arr);
endmodule
