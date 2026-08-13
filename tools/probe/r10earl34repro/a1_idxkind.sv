// r10earl34 ARM A1 — THE INDEX-KIND GRID.
//
// One question per cell: when a hier_path's DISPLAY NAME carries a select
// index, does Surelog print the WRITTEN identifier or the REDUCED value?
// Every cell is the target's shape — packed array of structs, two member
// levels, cont-assign LVALUE — so the only thing that varies is the INDEX.
//
// The target (Earlgrey flash_ctrl.sv:315) is cell A: a WILDCARD-IMPORTED
// package localparam.  Everything else is a control that tells us how far
// the law may travel.

package e34_pkg;
  localparam int PkgLp    = 8;   // the witness kind (flash_ctrl MpRegions)
  parameter  int PkgParam = 5;   // package PARAMETER, not localparam
  localparam int PkgTwo   = 2;
endpackage

typedef struct packed {
  logic [3:0] q;
} e34_inner_t;

typedef struct packed {
  e34_inner_t base;
  e34_inner_t size;
} e34_cfg_t;

module a1_idxkind import e34_pkg::*; (
  input  logic        clk,
  output logic [3:0]  o_a, o_b, o_c, o_d, o_e, o_f, o_g, o_h
);

  // ---- cell A: WILDCARD-IMPORTED package localparam (THE WITNESS) --------
  e34_cfg_t [PkgLp:0] arr_a;
  assign arr_a[PkgLp].base.q = 4'h0;
  assign o_a = arr_a[0].base.q;

  // ---- cell B: MODULE-LOCAL localparam -----------------------------------
  localparam int LocLp = 6;
  e34_cfg_t [LocLp:0] arr_b;
  assign arr_b[LocLp].base.q = 4'h0;
  assign o_b = arr_b[0].base.q;

  // ---- cell D: LITERAL index (control — already a constant) --------------
  e34_cfg_t [7:0] arr_d;
  assign arr_d[3].base.q = 4'h0;
  assign o_d = arr_d[0].base.q;

  // ---- cell G: EXPRESSION index over the imported param ------------------
  e34_cfg_t [PkgLp:0] arr_g;
  assign arr_g[PkgLp-1].base.q = 4'h0;
  assign o_g = arr_g[0].base.q;

  // ---- cell Q: QUALIFIED read of the same package localparam -------------
  e34_cfg_t [PkgLp:0] arr_q;
  assign arr_q[e34_pkg::PkgLp].base.q = 4'h0;
  assign o_e = arr_q[0].base.q;

  // ---- cell P: wildcard-imported package PARAMETER (not localparam) ------
  e34_cfg_t [PkgParam:0] arr_p;
  assign arr_p[PkgParam].base.q = 4'h0;
  assign o_f = arr_p[0].base.q;

  // ---- cell M: MODULE PARAMETER index ------------------------------------
  // (declared in the body so the module stays parameterless at instantiation)
  parameter int ModP = 4;
  e34_cfg_t [ModP:0] arr_m;
  assign arr_m[ModP].base.q = 4'h0;
  assign o_c = arr_m[0].base.q;

  // ---- cell C: GENVAR index ----------------------------------------------
  e34_cfg_t [3:0] arr_c;
  genvar gi;
  generate
    for (gi = 0; gi < 4; gi++) begin : g_blk
      assign arr_c[gi].base.q = 4'h0;
    end
  endgenerate
  assign o_h = arr_c[0].base.q;

endmodule
