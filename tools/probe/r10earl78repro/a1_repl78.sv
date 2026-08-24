// r10earl78 arm a1 — the REPLICATION whole-Rhs cont_assign ladder.
// Every row: `assign <lhs> = <rhs>;` once in a GEN-IF scope (gen_i), once in a
// GEN-FOR scope (gen_f), and once in the MODULE BODY (the twin), so the three
// homes are compared cell for cell on the SAME shape.
module a1;
  localparam int TW = 5;
  localparam int Z  = 0;
  parameter  int PW = 5;

  logic [4:0]  mi_1, mi_0, mi_mb, mi_e, mi_cat, mi_nest, mi_ctl, mi_gv;
  logic [4:0]  mi_x, mi_lp, mi_expr, mi_p, mi_big, mi_nar, mi_z1;
  logic [9:0]  mi_wide;
  logic [1:0]  mi_small;
  logic        sig;
  logic [1:0]  sig2;

  // ---- module body twin (the control: this home already folds) ----
  assign mi_1    = {TW{1'b1}};        // M1  {N{1'b1}}
  assign mi_0    = {TW{1'b0}};        // M2  {N{1'b0}}
  assign mi_mb   = {TW{2'b10}};       // M3  {N{multi-bit literal}}  natural 10
  assign mi_e    = {TW{sig}};         // M4  {N{expr}}  -- must NOT fold
  assign mi_cat  = {1'b0, {4{1'b1}}}; // M5  concat containing a replication
  assign mi_nest = {2{{2{1'b1}}}};    // M6  nested replications  natural 4
  assign mi_ctl  = 5'b10101;          // M7  non-replication control (literal)
  assign mi_x    = {TW{1'bx}};        // M8  {N{1'bx}}
  assign mi_lp   = {1'b0, {Z{1'b1}}}; // M9  N == 0 (only legal in a concat)
  assign mi_p    = {PW{1'b1}};        // M10 N a PARAMETER (not a localparam)
  assign mi_wide = {10{1'b1}};        // M11 natural == target
  assign mi_nar  = {TW{1'b1}};        // M12 (dup of M1, different Lhs)
  assign mi_small= {TW{1'b1}};        // M13 natural 5 > target 2  (adjustSize)
  assign mi_expr = {(TW+1){1'b1}};    // M14 N an EXPRESSION  natural 6
  assign mi_z1   = {TW{1'bz}};        // M15 {N{1'bz}}
  assign mi_big  = {3{2'b01}};        // M16 natural 6 > target 5

  // ---- gen-if home ----
  if (TW > 0) begin : gen_i
    logic [4:0]  gi_1, gi_0, gi_mb, gi_e, gi_cat, gi_nest, gi_ctl;
    logic [4:0]  gi_x, gi_lp, gi_expr, gi_p, gi_big, gi_small0, gi_z1;
    logic [9:0]  gi_wide;
    logic [1:0]  gi_small;
    assign gi_1    = {TW{1'b1}};
    assign gi_0    = {TW{1'b0}};
    assign gi_mb   = {TW{2'b10}};
    assign gi_e    = {TW{sig}};
    assign gi_cat  = {1'b0, {4{1'b1}}};
    assign gi_nest = {2{{2{1'b1}}}};
    assign gi_ctl  = 5'b10101;
    assign gi_x    = {TW{1'bx}};
    assign gi_lp   = {1'b0, {Z{1'b1}}};
    assign gi_p    = {PW{1'b1}};
    assign gi_wide = {10{1'b1}};
    assign gi_small= {TW{1'b1}};
    assign gi_expr = {(TW+1){1'b1}};
    assign gi_z1   = {TW{1'bz}};
    assign gi_big  = {3{2'b01}};
    assign gi_small0 = {TW{1'b1}};
  end

  // ---- gen-for home, N a GENVAR ----
  for (genvar gv = 1; gv < 3; gv++) begin : gen_f
    logic [4:0] gf_1, gf_gv, gf_mb, gf_e;
    logic [1:0] gf_small;
    assign gf_1    = {TW{1'b1}};
    assign gf_gv   = {gv{1'b1}};     // N a GENVAR
    assign gf_mb   = {TW{2'b10}};
    assign gf_e    = {TW{sig}};
    assign gf_small= {TW{1'b1}};
  end
endmodule
