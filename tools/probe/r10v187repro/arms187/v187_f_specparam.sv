// v187 arm F -- specparam / module localparam / a module's own scalar typedef
// beside a package one, all in one compile.
package pf187;
  typedef int f_i_t;
  parameter f_i_t F_P = 1;
endpackage
module mf187 ();
  import pf187::*;
  specparam SP187 = 3;
  typedef int mf_i_t;
  parameter  mf_i_t MF_P = 2;
  localparam mf_i_t MF_L = 4;
  localparam int    MF_U = F_P;
endmodule
module mftop187 ();
  mf187 u0 ();
endmodule
