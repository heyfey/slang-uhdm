// r11u75 g3 — LAW C: THE FOLD BASE'S HOME.  § caAsmMemberSliceFoldGenScope74
// folds `<base>.<member>` for a function-built packed-struct parameter, but
// its drain reads the base's elaborated `param_assign` out of a map that only
// the MODULE/PACKAGE listing fills; a base declared in the GENERATE scope
// itself stays symbolic (r11v74 `v7_foldshape` `gl_loc`).  This arm varies
// only WHERE THE BASE IS DECLARED, with the module-level row as the control.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c;
    c.n = x;
    c.t = 8'hC3;
    return c;
  endfunction
  localparam cfg_t PKG_BASE = build(64);
endpackage

module dut #(parameter p::cfg_t MOD_PAR = p::PKG_BASE)
  (output logic [31:0] o);
  localparam p::cfg_t MOD_LOC = p::build(128);   // module-level localparam
  logic [31:0] t_mod, t_pkg, t_par;
  assign t_mod = MOD_LOC.n;                      // control: folds at the base
  assign t_pkg = p::PKG_BASE.n;
  assign t_par = MOD_PAR.n;
  for (genvar i = 0; i < 2; i = i + 1) begin : gf
    localparam p::cfg_t G_LOC = p::build(256);   // GEN-SCOPE localparam base
    localparam p::cfg_t G_OVR = p::build(256 + i * 8); // per-iteration value
    logic [31:0] g_loc, g_ovr, g_mod, g_t, g_sh;
    logic [7:0]  g_narrow;
    assign g_loc    = G_LOC.n;      // the residue cell
    assign g_ovr    = G_OVR.n;      // per-instance: no cross-iteration leak
    assign g_mod    = MOD_LOC.n;    // module base read from a gen scope
    assign g_t      = G_LOC.t;      // the OTHER member of the gen base
    assign g_narrow = G_LOC.n;      // the adjustSize/lhs-width question
    assign g_sh     = G_LOC.n + 1;  // an operation AROUND it: declines
    if (1) begin : gn
      logic [31:0] n_loc, n_own;
      localparam p::cfg_t N_LOC = p::build(512); // NESTED gen-scope base
      assign n_loc = G_LOC.n;       // base one scope OUT
      assign n_own = N_LOC.n;       // base in THIS scope
    end
  end
  assign o = t_mod ^ t_pkg ^ t_par ^ gf[0].g_loc ^ gf[1].g_loc ^ gf[0].g_ovr
           ^ gf[1].g_ovr ^ gf[0].g_mod ^ gf[0].g_t ^ gf[0].g_narrow
           ^ gf[0].g_sh ^ gf[0].gn.n_loc ^ gf[0].gn.n_own;
endmodule
