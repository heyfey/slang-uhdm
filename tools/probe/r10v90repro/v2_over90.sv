// r10v90 v2 — THE OVERRIDE / PRODUCER-PATH GRID.  Fence (e) is
// `isOverriddenParam`, a SPAN test.  Every way SV can rebind a parameter is
// tried here: named `#(.X())`, POSITIONAL `#(v)`, a `defparam`, an override
// that restates the DEFAULT VALUE, an INSTANCE ARRAY, a TOP-LEVEL module
// `parameter` left at its default (Surelog elaborates a top's parameters on a
// different path from a child's), and a LOCALPARAM whose initializer is a bare
// reference to an OVERRIDDEN parameter (the helper's recursion falls through
// to the DECLARED sign there).
module snk4_90 (input logic [3:0] a_i);
endmodule
module snk2_90 (input logic [1:0] a_i);
endmodule

// A child whose port-list parameter feeds the ips WIDTH.
module ch90 #(parameter int MW = 4) (input logic [31:0] s_i);
  for (genvar g = 0; g < 1; g++) begin : gm
    snk4_90 u_ov (.a_i(s_i[g*4 +: MW]));
  end
endmodule

// A child that DERIVES a localparam from an overridden port parameter.
module dv90 #(parameter int DW = 4) (input logic [31:0] s_i);
  localparam int          LD  = DW;      // derived, signed decl
  localparam int unsigned LDU = DW;      // derived, unsigned decl
  for (genvar g = 0; g < 1; g++) begin : gd
    snk4_90 u_d  (.a_i(s_i[g*4 +: LD ]));
    snk4_90 u_du (.a_i(s_i[g*4 +: LDU]));
  end
endmodule

// A child with an IMPLICIT port parameter (no `parameter` keyword).
module im90 #(int IW = 4) (input logic [31:0] s_i);
  for (genvar g = 0; g < 1; g++) begin : gi
    snk4_90 u_im (.a_i(s_i[g*4 +: IW]));
  end
endmodule

// THE TOP module carries a `parameter` of its own, left at its default.
module v2_over90 #(parameter int TP = 4, parameter int unsigned TPU = 4);
  localparam int P4 = 4;
  logic [31:0] sig;

  // (1) the TOP's OWN parameter as the width — is a top parameter on the
  //     overridden path in Surelog, or the default path?
  for (genvar g = 0; g < 1; g++) begin : gt
    snk4_90 t01 (.a_i(sig[g*4 +: TP ]));
    snk4_90 t02 (.a_i(sig[g*4 +: TPU]));
  end

  // (2) the four override spellings + the default.
  ch90            u_def (.s_i(sig));      // DEFAULT     -> the law fires
  ch90 #(.MW(2))  u_nam (.s_i(sig));      // NAMED       -> refused
  ch90 #(2)       u_pos (.s_i(sig));      // POSITIONAL  -> refused
  ch90 #(.MW(4))  u_same(.s_i(sig));      // override = the DEFAULT VALUE
  ch90            u_dp  (.s_i(sig));      // rebound by the defparam below
  defparam u_dp.MW = 2;
  ch90            u_dp2 (.s_i(sig));      // defparam to the DEFAULT VALUE
  defparam u_dp2.MW = 4;

  // (3) an INSTANCE ARRAY, no override.
  ch90 u_arr [0:1] (.s_i(sig));

  // (4) a localparam DERIVED from an overridden parameter, both decl signs.
  dv90           u_dv_def (.s_i(sig));
  dv90 #(.DW(2)) u_dv_ov  (.s_i(sig));
  dv90           u_dv_dp  (.s_i(sig));   // the SOURCE param rebound by defparam
  defparam u_dv_dp.DW = 2;

  // (5) an IMPLICIT port parameter, default and overridden.
  im90           u_im_def (.s_i(sig));
  im90 #(.IW(2)) u_im_ov  (.s_i(sig));
endmodule
