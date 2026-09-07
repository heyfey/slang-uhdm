// v187 arm J -- TYPEDEF'D PARAMETERS IN CLONES: a parameterized module
// instantiated three ways and a parameterized class specialized twice, all
// against a package scalar typedef.
package pj187;
  typedef int  j_i_t;
  typedef byte j_by_t;
  parameter j_i_t J_D = 1;
endpackage
module mj187 #(parameter pj187::j_i_t MJ_P = 1, parameter int MJ_Q = 2) ();
  import pj187::*;
  localparam j_i_t  MJ_L = MJ_P;
  localparam j_by_t MJ_B = 3;
endmodule
package pjc187;
  typedef int c_i_t;
  class CJ187 #(parameter c_i_t CW = 3);
    localparam c_i_t CL = CW;
  endclass
  parameter c_i_t PJC = 8;
endpackage
module mjtop187 ();
  import pj187::*;
  import pjc187::*;
  mj187 #(.MJ_P(5)) u0 ();
  mj187 #(.MJ_P(6)) u1 ();
  mj187             u2 ();
  CJ187#(4) c4;
  CJ187#(7) c7;
  localparam j_i_t T_L = J_D + PJC;
endmodule
