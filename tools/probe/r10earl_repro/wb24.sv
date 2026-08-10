// wb24.sv — pass-24 residue (1), the 2x2 EXTENSION of wa24.  wa24 established
// (child instance, PACKAGE param, wildcard-imported):
//     for-gen NESTED in if-gen  -> golden KEEPS a ref_obj bound to a FRESH
//                                  loc-less enum_const; we FOLD
//     FLAT module-level for-gen -> both FOLD
// This file varies everything else that could be the real discriminator:
// the QUALIFIER, the nesting KIND (if-in-if, for-in-for), the containing
// construct (cont_assign vs always_comb), the operand POSITION (select),
// the TOP-LEVEL if-gen scope itself, a MODULE parameter vs a package one,
// and the same nested shape in a TOP module (the pass-23 child-instance trap).
package q24;
  parameter logic [11:0] Q_A = 12'h1A0;
  parameter logic [11:0] Q_B = 12'h1B0;
  parameter logic [11:0] Q_C = 12'h1C0;
  parameter logic [11:0] Q_D = 12'h1D0;
  parameter logic [11:0] Q_E = 12'h1E0;
  parameter logic [11:0] Q_F = 12'h1F0;
  parameter logic [11:0] Q_G = 12'h2A0;
  parameter int unsigned Q_N = 4;
endpackage

module cb24
  import q24::*;
#(
  parameter bit En = 1'b1,
  parameter int unsigned NR = 4
) (
  input  logic [11:0] addr,
  input  logic        we,
  input  logic [15:0] dat,
  output logic [3:0]  o_qual, o_ifif, o_forfor, o_proc, o_sel, o_mp,
  output logic        o_topif
);
  localparam logic [11:0] M_LP = 12'h3C0;

  // ---- R1: for-gen NESTED in if-gen, QUALIFIED read ----
  if (En) begin : g_outer
    logic [NR-1:0] r_qual;
    logic [NR-1:0] r_mp;
    logic [NR-1:0] r_proc;
    logic [NR-1:0] r_sel;
    for (genvar i = 0; i < NR; i++) begin : g_in
      assign r_qual[i] = we & (addr == (q24::Q_A + (i[11:0] >> 2)));
      // ---- R2: same scope, MODULE localparam, PLAIN operand ----
      assign r_mp[i]   = we & (addr == M_LP);
      // ---- R3: same scope, a PROCESS (always_comb) ----
      always_comb r_proc[i] = we & (addr == Q_B);
      // ---- R4: same scope, SELECT-position read ----
      assign r_sel[i]  = we & dat[Q_C[3:0]];
    end
    assign o_qual   = r_qual;
    assign o_mp     = r_mp;
    assign o_proc   = r_proc;
    assign o_sel    = r_sel;
    // ---- R5: the TOP-LEVEL if-gen scope's OWN cont_assign ----
    assign o_topif  = we & (addr == Q_D);
  end

  // ---- R6: if-gen NESTED in if-gen ----
  if (En) begin : g_if1
    logic [3:0] r_ifif;
    if (NR > 2) begin : g_if2
      assign r_ifif = we ? {4{(addr == Q_E)}} : 4'b0;
    end
    assign o_ifif = r_ifif;
  end

  // ---- R7: for-gen NESTED in for-gen ----
  logic [3:0] r_ff;
  for (genvar a = 0; a < 2; a++) begin : g_f1
    for (genvar b = 0; b < 2; b++) begin : g_f2
      assign r_ff[a*2+b] = we & (addr == (Q_F + (b[11:0] >> 1)));
    end
  end
  assign o_forfor = r_ff;
endmodule

module wb24
  import q24::*;
(
  input  logic [11:0] addr,
  input  logic        we,
  input  logic [15:0] dat,
  output logic [3:0]  a, b, c, d, e, f,
  output logic        g,
  output logic [3:0]  t_nested
);
  cb24 #(.En(1'b1), .NR(4)) u_c (
    .addr(addr), .we(we), .dat(dat),
    .o_qual(a), .o_ifif(b), .o_forfor(c), .o_proc(d), .o_sel(e), .o_mp(f),
    .o_topif(g)
  );

  // ---- R8: THE TRAP ROW — the very same nested shape in the TOP module ----
  if (1) begin : t_outer
    logic [3:0] tw;
    for (genvar k = 0; k < 4; k++) begin : t_in
      assign tw[k] = we & (addr == (Q_G + (k[11:0] >> 2)));
    end
    assign t_nested = tw;
  end
endmodule
