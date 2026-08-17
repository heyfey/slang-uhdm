interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
package pk_v6b;
  typedef struct packed { int a; int b; } s_v;
  parameter s_v S = '{a:3, b:6};
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
  leaf_a #(.R(pk_v6b::S.b)) u (clk, arr);
endmodule
