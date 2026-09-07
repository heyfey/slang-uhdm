// v187 arm G -- a package parameter whose declared type is a TYPE PARAMETER
// (a TypeAlias homed in the package that is NOT a typedef declaration).
package pg187;
  typedef int g_i_t;
  parameter type G_T = g_i_t;
  parameter type G_U = int;
  parameter G_T G_P = 1;
  parameter G_U G_Q = 2;
  parameter g_i_t G_R = 3;
  localparam type G_LT = byte;
  localparam G_LT G_LP = 4;
endpackage
module mg187 ();
  import pg187::*;
  localparam int MG = G_P + G_Q + G_R + G_LP;
endmodule
