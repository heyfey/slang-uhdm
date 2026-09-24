// r10earl59 arm V3 — completes V2's grid on the two axes V2 left open:
//   (a) the Rhs SHAPES V2 did not spell (bare bit_select, bare part_select,
//       hier_path/member-access, cast, replication, comparison, a bare ref to
//       an ANCESTOR gen scope's net);
//   (b) the LHS DECLARING SCOPE x GENERATE KIND cells the existing law's
//       `mapsToVar0` half claims (a module-level VAR written from a
//       FOR-generate body, and an ancestor gen scope's VAR at d2).
module a3sub (
  input              clk,
  input       [3:0]  din,
  output      [3:0]  pn_out
);
  typedef struct packed { logic [3:0] f; logic [3:0] g; } st_t;
  st_t        mst;
  wire  [3:0] mn_src;
  logic       mempty;
  assign mn_src = din;
  assign mempty = din[0];
  assign mst    = {din, din};

  // (a) Rhs SHAPE axis at d2, module-level wire LHS
  wire  [3:0] mn_d2_bselbare, mn_d2_pselbare, mn_d2_hier, mn_d2_cast;
  wire  [3:0] mn_d2_repl, mn_d2_cmp, mn_d2_bareanc, mn_d2_barelocvar;
  // (b) LHS SCOPE x GEN KIND
  logic [3:0] mv_fg_op, mv_d1_op, mv_d1_bare;
  wire  [3:0] mn_fg_op, mn_d2_ancvar_dummy;
  wire  [3:0] pn_dummy;
  assign pn_out = pn_dummy;

  if (1) begin : g_a
    wire  [3:0] an_net;
    logic [3:0] an_var;
    assign an_net = mn_src;
    assign an_var = mn_src;
    assign mv_d1_op   = mempty ? 4'b0 : mn_src;   // module VAR, flat if-gen, op
    assign mv_d1_bare = mn_src;                   // module VAR, flat if-gen, bare

    if (1) begin : g_b
      wire  [3:0] ln_net;
      logic [3:0] lv_var;
      assign ln_net = mn_src;
      assign lv_var = mn_src;

      assign mn_d2_bselbare   = ln_net[1];          // BARE bit_select Rhs
      assign mn_d2_pselbare   = ln_net[2:1];        // BARE part_select Rhs
      assign mn_d2_hier       = mst.f;              // member access / hier_path
      assign mn_d2_cast       = 4'(ln_net);         // cast
      assign mn_d2_repl       = {2{ln_net[1:0]}};   // replication (operation)
      assign mn_d2_cmp        = ln_net == mn_src;   // comparison (operation)
      assign mn_d2_bareanc    = an_net;             // BARE ref, ANCESTOR gen net
      assign mn_d2_barelocvar = lv_var;             // BARE ref, own-scope gen VAR
      assign an_var           = ln_net | mn_src;    // ANCESTOR gen VAR LHS, op
      assign an_net           = ln_net;             // ANCESTOR gen NET LHS, bare
      assign lv_var           = ln_net;             // OWN-scope gen VAR LHS, bare
    end
  end

  genvar gk;
  for (gk = 0; gk < 1; gk = gk + 1) begin : g_g
    wire [3:0] lg_net;
    assign lg_net   = mn_src;
    assign mv_fg_op = lg_net | mn_src;   // module VAR from a FOR-gen body
    assign mn_fg_op = lg_net | mn_src;   // module NET from a FOR-gen body
  end
endmodule

module a1;
  wire       clk;
  wire [3:0] din, o1;
  a3sub u_sub (.clk(clk), .din(din), .pn_out(o1));
endmodule
