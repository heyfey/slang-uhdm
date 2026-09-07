// v187 arm B -- SEVERAL param_assignments on ONE declaration (Surelog mints a
// clone per Param_assignment), and a declaration list mixing kinds.
package pm187;
  typedef int  m_i_t;
  typedef byte m_by_t;
  typedef bit  m_b1_t;
  parameter  m_i_t  M_A = 1, M_B = 2, M_C = 3;
  localparam m_by_t M_D = 4, M_E = 5;
  parameter  m_b1_t M_F = 1'b0, M_G = 1'b1;
  parameter  m_i_t  M_H = 7;
endpackage
module mm187 ();
  import pm187::*;
  localparam int MM = M_A + M_B + M_C + M_D + M_E + M_H;
endmodule
