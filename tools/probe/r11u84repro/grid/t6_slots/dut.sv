// r11u84 t6 - WHERE DOES A CLONE LAND IN THE TWO VECTORS?  pass-79 modelled
// "at the import statement's slot in the one source-ordered walk", measured on
// packages whose import is the FIRST thing in the body (uvm_pkg, adpcm_pkg),
// where that is indistinguishable from "all imports FIRST".  t3's `sa` splits
// the two.  This arm asks it cleanly, for BOTH vectors, with own entries
// before, between and after the import items.
package m1;
  wire  [7:0] m_net;
  logic [7:0] m_var = 8'd1;
  typedef logic [7:0] mw_t;
  wire mw_t   m_wtd;
  logic [7:0] m_uarr [0:1];
endpackage
package m2;
  wire  [7:0] m_net2;
endpackage

package n1;
  wire  [7:0] own_net_a;
  logic [7:0] own_var_a;
  import m1::*;
  wire  [7:0] own_net_b;
  logic [7:0] own_var_b;
  import m2::*;
  wire  [7:0] own_net_c;
  logic [7:0] own_var_c;
endpackage

package n2;                       // the EXPLICIT twin of n1
  wire  [7:0] e_net_a;
  logic [7:0] e_var_a;
  import m1::m_net;
  wire  [7:0] e_net_b;
  logic [7:0] e_var_b;
  import m1::m_var;
  import m1::m_uarr;
  wire  [7:0] e_net_c;
  logic [7:0] e_var_c;
endpackage

module dut (output logic [31:0] o);
  import n1::*; import n2::*;
  assign o = {24'd0, own_net_a ^ e_net_a};
endmodule
