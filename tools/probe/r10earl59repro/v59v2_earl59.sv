// r10earl59 arm V2 — THE GRID for the law at ModuleEmit.cpp:15081
//   "A NESTED gen scope (parent scope is itself a generate block) leaves a
//    MODULE-level whole-ref LHS unbound; refs to GEN-scope nets still bind"
// V1 REFUTED the module-level half at d2 for an OPERATION Rhs.  This grid
// varies the Rhs SHAPE, the LHS's DECLARING SCOPE, the generate KIND and the
// NESTING DEPTH, one axis at a time, so the surviving fence is measured.
//
// row naming  <target>_<nesting>_<rhs-shape>
//   target : pn = ANSI output PORT net | mn = module `wire` | mv = module `logic`
//            an = module net inside an if-gen ANCESTOR of the writer
//            ln = the writing block's OWN gen-local net
//            lv = the writing block's OWN gen-local var
//   nesting: d1 = flat if-gen | d2 = if-gen in if-gen | d3 = three deep
//            if_in_fg = if-gen inside a for-generate body
//            fg_in_if = for-generate body inside an if-gen
//            ug_in_if = UNNAMED begin/end inside an if-gen
//   rhs    : op tern bare lit bsel psel cat un fn sys modbare parm

module a2sub (
  input               clk,
  input        [3:0]  din,
  output       [3:0]  pn_d2_op,
  output       [3:0]  pn_d2_bare,
  output logic [3:0]  pv_d2_op
);
  function automatic [3:0] f4(input [3:0] x); return x ^ 4'h5; endfunction

  localparam [3:0] PK = 4'h3;

  wire  [3:0] mn_src;
  logic       mempty;
  assign mn_src = din;
  assign mempty = din[0];

  // ---- Rhs SHAPE axis, every row a MODULE-level wire LHS at d2 --------------
  wire  [3:0] mn_d2_op, mn_d2_tern, mn_d2_bare, mn_d2_lit, mn_d2_bsel;
  wire  [3:0] mn_d2_psel, mn_d2_cat, mn_d2_un, mn_d2_fn, mn_d2_sys;
  wire  [3:0] mn_d2_modbare, mn_d2_parm;
  // ---- LHS SCOPE axis, operation Rhs ---------------------------------------
  logic [3:0] mv_d2_op;
  wire  [3:0] mn_d3_op, mn_if_in_fg_op, mn_fg_in_if_op, mn_ug_in_if_op;
  wire  [3:0] mn_d2_bselLhs, mn_d2_pselLhs;
  wire  [3:0] mn_d1_op, mn_d1_bare;

  if (1) begin : g_a
    wire  [3:0] an_net;                 // an ANCESTOR gen scope's net
    logic [3:0] an_var;
    assign an_net = mn_src;
    assign mn_d1_op   = mempty ? 4'b0 : mn_src;
    assign mn_d1_bare = mn_src;

    if (1) begin : g_b
      wire  [3:0] ln_net;
      logic [3:0] lv_var;
      assign ln_net = mn_src;

      // Rhs shape axis
      assign mn_d2_op      = ln_net | mn_src;
      assign mn_d2_tern    = mempty ? 4'b0 : ln_net;
      assign mn_d2_bare    = ln_net;
      assign mn_d2_lit     = 4'b0;
      assign mn_d2_bsel    = {3'b0, ln_net[1]};
      assign mn_d2_psel    = {2'b0, ln_net[2:1]};
      assign mn_d2_cat     = {ln_net[1:0], mn_src[1:0]};
      assign mn_d2_un      = ~ln_net;
      assign mn_d2_fn      = f4(ln_net);
      assign mn_d2_sys     = $signed(ln_net);
      assign mn_d2_modbare = mn_src;
      assign mn_d2_parm    = PK;

      // LHS scope axis, operation Rhs throughout
      assign pn_d2_op   = ln_net | mn_src;
      assign pn_d2_bare = ln_net;
      assign pv_d2_op   = ln_net | mn_src;
      assign mv_d2_op   = ln_net | mn_src;
      assign an_net     = ln_net | mn_src;   // ANCESTOR gen scope NET
      assign lv_var     = ln_net | mn_src;   // OWN-scope gen VAR
      assign mn_d2_bselLhs[1] = ln_net[0] | mn_src[0];  // bit-select LHS
      assign mn_d2_pselLhs[2:1] = ln_net[1:0] | mn_src[1:0];  // part-select LHS

      if (1) begin : g_c
        wire [3:0] l3_net;
        assign l3_net   = mn_src;
        assign mn_d3_op = l3_net | mn_src;   // depth 3
      end

      genvar gj;
      for (gj = 0; gj < 1; gj = gj + 1) begin : g_fi
        wire [3:0] lf_net;
        assign lf_net        = mn_src;
        assign mn_fg_in_if_op = lf_net | mn_src;  // for-gen body inside if-gen
      end

      if (1) begin
        wire [3:0] lu_net;
        assign lu_net         = mn_src;
        assign mn_ug_in_if_op = lu_net | mn_src;  // UNNAMED block inside if-gen
      end
    end
  end

  genvar gk;
  for (gk = 0; gk < 1; gk = gk + 1) begin : g_g
    wire [3:0] lg_net;
    assign lg_net = mn_src;
    if (1) begin : g_h
      wire [3:0] lh_net;
      assign lh_net         = mn_src;
      assign mn_if_in_fg_op = lh_net | mn_src;  // if-gen inside for-gen body
    end
  end
endmodule

module a1;
  wire       clk;
  wire [3:0] din, o1, o2, o3;
  a2sub u_sub (.clk(clk), .din(din), .pn_d2_op(o1), .pn_d2_bare(o2), .pv_d2_op(o3));
endmodule
