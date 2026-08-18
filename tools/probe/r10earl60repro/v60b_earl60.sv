// r10earl60 arm B — the NAME-COLLISION half of the grid: what a WILDCARD IMPORT
// does when the module's own parameter has the SAME NAME as a package member.
// These are the corpus shapes r10earl60's census found on the OTHER side of the
// disagreement (usbdev NEndpoints, rv_timer N_HARTS/N_TIMERS, flash_erase_ctrl
// AddrW, flash_mp MpRegions, rstmgr_ctrl PowerDomains).
package q_pkg;
  parameter  int N = 12;         // package PARAMETER
  localparam int L = 5;          // package LOCALPARAM
  localparam int W = 7;
endpackage

// usbdev shape: wildcard import, local name COLLIDES, RHS explicitly scoped
module s_coll_scoped ();
  import q_pkg::*;
  localparam int N = q_pkg::N;
endmodule

// rv_timer shape: wildcard import AFTER the declarations, RHS is a LITERAL
module s_lit_after ();
  localparam int N = 1;
  localparam int L = 2;
  import q_pkg::*;
  logic [L-1:0] d;
endmodule

// same but the import comes BEFORE the colliding declarations
module s_lit_before ();
  import q_pkg::*;
  localparam int N = 1;
  localparam int L = 2;
  logic [L-1:0] d;
endmodule

// flash_erase_ctrl / rstmgr_ctrl shape: PARAMETER PORT whose name collides with
// a wildcard-imported package member, overridden at the instantiation site
module s_port_coll #(
  parameter int N = 3,
  localparam int LP = N + 1
) ();
  import q_pkg::*;
  logic [LP-1:0] d;
endmodule

// rstmgr_ctrl's exact spelling: the import sits on the module header
module s_hdr_coll import q_pkg::*; #(
  parameter int N = 3,
  localparam int LP = N - 1
) ();
  logic [LP:0] d;
endmodule

module a1 ();
  s_coll_scoped u0 ();
  s_lit_after   u1 ();
  s_lit_before  u2 ();
  s_port_coll #(.N(q_pkg::N)) u3 ();
  s_hdr_coll  #(.N(q_pkg::L)) u4 ();
endmodule
