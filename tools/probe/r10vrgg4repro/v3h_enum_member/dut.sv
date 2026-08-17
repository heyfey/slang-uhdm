interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
package pk_v3h;
  typedef enum int { E_A = 3, E_B = 6 } e_v;
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
  leaf_a #(.R(pk_v3h::E_B)) u (clk, arr);
endmodule
