// v187 arm E -- the deferred parameter used as a RANGE BOUND of a later
// typedef, an enum base, a class-scope localparam, and aggregate siblings.
package pn187;
  typedef int  n_i_t;
  typedef byte n_by_t;
  parameter n_i_t N_W = 8;
  typedef logic [N_W-1:0] n_v_t;
  parameter n_v_t N_V = 0;
  typedef enum bit [1:0] { NE0, NE1 } n_e_t;
  parameter n_e_t N_E = NE0;
  typedef struct packed { bit [3:0] x; bit [3:0] y; } n_s_t;
  parameter n_s_t N_S = 8'h21;
  parameter n_by_t N_B = 3;
  class NC187;
    localparam n_i_t NC_L = 5;
  endclass
endpackage
module mn187 ();
  import pn187::*;
  localparam int MN = N_W + N_B;
  n_v_t sig;
endmodule
