// r10earl52 arm a3 — DOES THE CONDITION GATE IT, and WHERE does the rule
// live?  Varies (a) what the condition is made of, (b) the taken side,
// (c) nesting, (d) the declaration site (module localparam vs parameter vs
// package vs generate vs function), (e) whether a ternary is present at all.
package a3p_earl52;
  localparam bit PKGC = 1'b0;
  // in a PACKAGE, same shape as the head
  localparam int P_tern = PKGC ? 1'b0 : 1'b1;
  localparam int P_dir  =               1'b1;
endpackage

module a3_earl52 #(
  parameter bit  C   = 1'b0,     // module parameter, like PipeLine
  parameter int  CI  = 0
) ();
  localparam bit LC = 1'b0;      // local constant condition
  wire         nw;               // NOT constant

  // (a) condition shapes -- all take the ELSE branch 1'b1
  localparam int C_modparam = C        ? 1'b0 : 1'b1;   // the head's shape
  localparam int C_localpar = LC       ? 1'b0 : 1'b1;
  localparam int C_intparam = CI       ? 1'b0 : 1'b1;
  localparam int C_literal  = 1'b0     ? 1'b0 : 1'b1;
  localparam int C_compare  = (C == 1'b1) ? 1'b0 : 1'b1;
  localparam int C_notC     = !C       ? 1'b1 : 1'b0;   // THEN branch taken

  // (b) THEN side taken with the set-MSB literal
  localparam int T_then     = 1'b1     ? 1'b1 : 1'b0;

  // (c) nesting
  localparam int N_nest     = C ? 1'b0 : (C ? 1'b0 : 1'b1);
  localparam int N_nest2    = (C ? 1'b1 : 1'b0) ? 1'b0 : 1'b1;

  // (d) a ternary whose value is read through ANOTHER localparam hop
  localparam int V_tern     = C ? 1'b0 : 1'b1;
  localparam int V_hop      = V_tern;
  localparam bit B_tern     = C ? 1'b0 : 1'b1;
  localparam int V_bhop     = B_tern;

  // (e) generate-scope localparam
  generate
    if (1) begin : g
      localparam int G_tern = C ? 1'b0 : 1'b1;
      localparam int G_dir  =              1'b1;
    end
  endgenerate

  // (f) a PARAMETER (not localparam) with a ternary default, not overridden
  //     -- declared in the body so it is a body parameter, and in the port
  //        list via the header above.
  parameter int PB_tern = C ? 1'b0 : 1'b1;

  // (g) the package rows, read here so they elaborate
  localparam int U_pkg = a3p_earl52::P_tern;
endmodule
