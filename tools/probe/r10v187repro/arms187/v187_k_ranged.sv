// v187 arm K -- RANGED (vector) typedefs beside scalar ones, including a
// vector typedef whose bound is one of the deferred parameters.
package pk187;
  typedef bit   [7:0] k_v_t;
  typedef logic [3:0] k_l_t;
  typedef int         k_i_t;
  typedef byte        k_by_t;
  parameter k_i_t  K_N = 4;
  typedef bit [K_N-1:0] k_p_t;
  parameter k_v_t  K_V = 8'hA5;
  parameter k_l_t  K_L = 4'h3;
  parameter k_p_t  K_P = 0;
  parameter k_i_t  K_I = 9;
  parameter k_by_t K_B = 2;
endpackage
module mk187 ();
  import pk187::*;
  localparam int MK = K_N + K_I + K_B;
  k_p_t sig;
endmodule
