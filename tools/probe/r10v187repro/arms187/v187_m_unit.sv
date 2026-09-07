// v187 arm M -- $unit-scope typedef (residue R3) beside a package one.
typedef int u_i_t;
parameter u_i_t U_P = 1;
package pu187;
  typedef int p_i_t;
  parameter p_i_t U_Q = 2;
endpackage
module mu187 ();
  import pu187::*;
  localparam int MU = U_Q;
endmodule
