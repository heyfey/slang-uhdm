interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
package pk_v5;
  typedef enum int { E_A = 3, E_B = 6 } e_v;
endpackage
module leaf_v5d_noovr_enumparam #(
  parameter pk_v5::e_v R = pk_v5::E_A
)(
  input logic clk,
  ifc4.host  arr[R]
);
endmodule
module top;
  logic clk;
  ifc4 arr[3]();
  leaf_v5d_noovr_enumparam u (clk, arr);
endmodule
