interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
package pk_v3i;
  typedef enum int { E_A = 3, E_B = 6 } e_v;
endpackage
module leaf_a #(
  parameter int R = 4
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module mid_v3i #(parameter pk_v3i::e_v P = pk_v3i::E_B)
               (input logic clk, ifc4.host arr[6]);
  leaf_a #(.R(P)) u (clk, arr);
endmodule
module top;
  logic clk;
  ifc4 arr[6]();
  mid_v3i m (clk, arr);
endmodule
