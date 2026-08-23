// r10earl71 arm d1 — MEASUREMENT ONLY.  ONE axis: the RHS SHAPE of the
// imported package parameter named in a port-actual select bound.
package pz_earl71;
  parameter int ZW = 64;
  parameter int ZB = 32;
  parameter int ZA = 10;
endpackage

package pp_earl71;
  parameter  int LIT  = 20;
  parameter  int XREF = pz_earl71::ZA;
  parameter  int CLGL = $clog2(16);
  parameter  int DIVP = pz_earl71::ZW / pz_earl71::ZB;
  parameter  int CLGP = $clog2(DIVP);
  parameter  int TERN = DIVP == 1 ? 1 : CLGP;
  parameter  int SUBP = XREF - CLGP;
  localparam int LLIT = 20;
  localparam int LCLG = $clog2(16);
endpackage

module lf71 (
  input [31:0] p0, input [31:0] p1, input [31:0] p2, input p3,
  input [31:0] p4, input [31:0] p5, input [31:0] p6, input [31:0] p7);
endmodule

module m1_earl71 import pp_earl71::*; (
  input [31:0] sig, output logic [31:0] o0);
  // ---- LIT : module-body home
  lf71 i_mod_LIT (
      .p0(sig[LIT+2:1]),
      .p1(sig[0 +: LIT]),
      .p2(sig[LIT +: 4]),
      .p3(sig[LIT]),
      .p4(sig[LIT+1:0]),
      .p5(sig[31:LIT]),
      .p6(LIT),
      .p7(sig[LIT+2:LIT])
  );
  logic [31:0] c_LIT; assign c_LIT = sig[31:LIT];
  // ---- XREF : module-body home
  lf71 i_mod_XREF (
      .p0(sig[XREF+2:1]),
      .p1(sig[0 +: XREF]),
      .p2(sig[XREF +: 4]),
      .p3(sig[XREF]),
      .p4(sig[XREF+1:0]),
      .p5(sig[31:XREF]),
      .p6(XREF),
      .p7(sig[LIT+2:XREF])
  );
  logic [31:0] c_XREF; assign c_XREF = sig[31:XREF];
  // ---- CLGL : module-body home
  lf71 i_mod_CLGL (
      .p0(sig[CLGL+2:1]),
      .p1(sig[0 +: CLGL]),
      .p2(sig[CLGL +: 4]),
      .p3(sig[CLGL]),
      .p4(sig[CLGL+1:0]),
      .p5(sig[31:CLGL]),
      .p6(CLGL),
      .p7(sig[LIT+2:CLGL])
  );
  logic [31:0] c_CLGL; assign c_CLGL = sig[31:CLGL];
  // ---- DIVP : module-body home
  lf71 i_mod_DIVP (
      .p0(sig[DIVP+2:1]),
      .p1(sig[0 +: DIVP]),
      .p2(sig[DIVP +: 4]),
      .p3(sig[DIVP]),
      .p4(sig[DIVP+1:0]),
      .p5(sig[31:DIVP]),
      .p6(DIVP),
      .p7(sig[LIT+2:DIVP])
  );
  logic [31:0] c_DIVP; assign c_DIVP = sig[31:DIVP];
  // ---- CLGP : module-body home
  lf71 i_mod_CLGP (
      .p0(sig[CLGP+2:1]),
      .p1(sig[0 +: CLGP]),
      .p2(sig[CLGP +: 4]),
      .p3(sig[CLGP]),
      .p4(sig[CLGP+1:0]),
      .p5(sig[31:CLGP]),
      .p6(CLGP),
      .p7(sig[LIT+2:CLGP])
  );
  logic [31:0] c_CLGP; assign c_CLGP = sig[31:CLGP];
  // ---- TERN : module-body home
  lf71 i_mod_TERN (
      .p0(sig[TERN+2:1]),
      .p1(sig[0 +: TERN]),
      .p2(sig[TERN +: 4]),
      .p3(sig[TERN]),
      .p4(sig[TERN+1:0]),
      .p5(sig[31:TERN]),
      .p6(TERN),
      .p7(sig[LIT+2:TERN])
  );
  logic [31:0] c_TERN; assign c_TERN = sig[31:TERN];
  // ---- SUBP : module-body home
  lf71 i_mod_SUBP (
      .p0(sig[SUBP+2:1]),
      .p1(sig[0 +: SUBP]),
      .p2(sig[SUBP +: 4]),
      .p3(sig[SUBP]),
      .p4(sig[SUBP+1:0]),
      .p5(sig[31:SUBP]),
      .p6(SUBP),
      .p7(sig[LIT+2:SUBP])
  );
  logic [31:0] c_SUBP; assign c_SUBP = sig[31:SUBP];
  // ---- LLIT : module-body home
  lf71 i_mod_LLIT (
      .p0(sig[LLIT+2:1]),
      .p1(sig[0 +: LLIT]),
      .p2(sig[LLIT +: 4]),
      .p3(sig[LLIT]),
      .p4(sig[LLIT+1:0]),
      .p5(sig[31:LLIT]),
      .p6(LLIT),
      .p7(sig[LIT+2:LLIT])
  );
  logic [31:0] c_LLIT; assign c_LLIT = sig[31:LLIT];
  // ---- LCLG : module-body home
  lf71 i_mod_LCLG (
      .p0(sig[LCLG+2:1]),
      .p1(sig[0 +: LCLG]),
      .p2(sig[LCLG +: 4]),
      .p3(sig[LCLG]),
      .p4(sig[LCLG+1:0]),
      .p5(sig[31:LCLG]),
      .p6(LCLG),
      .p7(sig[LIT+2:LCLG])
  );
  logic [31:0] c_LCLG; assign c_LCLG = sig[31:LCLG];
  for (genvar g_LIT = 0; g_LIT < 2; g_LIT++) begin: gf_LIT
    lf71 i_gen_LIT (
        .p0(sig[LIT+2:1]),
        .p1(sig[0 +: LIT]),
        .p2(sig[LIT +: 4]),
        .p3(sig[LIT]),
        .p4(sig[LIT+1:0]),
        .p5(sig[31:LIT]),
        .p6(LIT),
        .p7(sig[LIT+2:LIT])
    );
    logic [31:0] t_LIT; assign t_LIT = sig[31:LIT];
  end
  for (genvar g_XREF = 0; g_XREF < 2; g_XREF++) begin: gf_XREF
    lf71 i_gen_XREF (
        .p0(sig[XREF+2:1]),
        .p1(sig[0 +: XREF]),
        .p2(sig[XREF +: 4]),
        .p3(sig[XREF]),
        .p4(sig[XREF+1:0]),
        .p5(sig[31:XREF]),
        .p6(XREF),
        .p7(sig[LIT+2:XREF])
    );
    logic [31:0] t_XREF; assign t_XREF = sig[31:XREF];
  end
  for (genvar g_CLGL = 0; g_CLGL < 2; g_CLGL++) begin: gf_CLGL
    lf71 i_gen_CLGL (
        .p0(sig[CLGL+2:1]),
        .p1(sig[0 +: CLGL]),
        .p2(sig[CLGL +: 4]),
        .p3(sig[CLGL]),
        .p4(sig[CLGL+1:0]),
        .p5(sig[31:CLGL]),
        .p6(CLGL),
        .p7(sig[LIT+2:CLGL])
    );
    logic [31:0] t_CLGL; assign t_CLGL = sig[31:CLGL];
  end
  for (genvar g_DIVP = 0; g_DIVP < 2; g_DIVP++) begin: gf_DIVP
    lf71 i_gen_DIVP (
        .p0(sig[DIVP+2:1]),
        .p1(sig[0 +: DIVP]),
        .p2(sig[DIVP +: 4]),
        .p3(sig[DIVP]),
        .p4(sig[DIVP+1:0]),
        .p5(sig[31:DIVP]),
        .p6(DIVP),
        .p7(sig[LIT+2:DIVP])
    );
    logic [31:0] t_DIVP; assign t_DIVP = sig[31:DIVP];
  end
  for (genvar g_CLGP = 0; g_CLGP < 2; g_CLGP++) begin: gf_CLGP
    lf71 i_gen_CLGP (
        .p0(sig[CLGP+2:1]),
        .p1(sig[0 +: CLGP]),
        .p2(sig[CLGP +: 4]),
        .p3(sig[CLGP]),
        .p4(sig[CLGP+1:0]),
        .p5(sig[31:CLGP]),
        .p6(CLGP),
        .p7(sig[LIT+2:CLGP])
    );
    logic [31:0] t_CLGP; assign t_CLGP = sig[31:CLGP];
  end
  for (genvar g_TERN = 0; g_TERN < 2; g_TERN++) begin: gf_TERN
    lf71 i_gen_TERN (
        .p0(sig[TERN+2:1]),
        .p1(sig[0 +: TERN]),
        .p2(sig[TERN +: 4]),
        .p3(sig[TERN]),
        .p4(sig[TERN+1:0]),
        .p5(sig[31:TERN]),
        .p6(TERN),
        .p7(sig[LIT+2:TERN])
    );
    logic [31:0] t_TERN; assign t_TERN = sig[31:TERN];
  end
  for (genvar g_SUBP = 0; g_SUBP < 2; g_SUBP++) begin: gf_SUBP
    lf71 i_gen_SUBP (
        .p0(sig[SUBP+2:1]),
        .p1(sig[0 +: SUBP]),
        .p2(sig[SUBP +: 4]),
        .p3(sig[SUBP]),
        .p4(sig[SUBP+1:0]),
        .p5(sig[31:SUBP]),
        .p6(SUBP),
        .p7(sig[LIT+2:SUBP])
    );
    logic [31:0] t_SUBP; assign t_SUBP = sig[31:SUBP];
  end
  for (genvar g_LLIT = 0; g_LLIT < 2; g_LLIT++) begin: gf_LLIT
    lf71 i_gen_LLIT (
        .p0(sig[LLIT+2:1]),
        .p1(sig[0 +: LLIT]),
        .p2(sig[LLIT +: 4]),
        .p3(sig[LLIT]),
        .p4(sig[LLIT+1:0]),
        .p5(sig[31:LLIT]),
        .p6(LLIT),
        .p7(sig[LIT+2:LLIT])
    );
    logic [31:0] t_LLIT; assign t_LLIT = sig[31:LLIT];
  end
  for (genvar g_LCLG = 0; g_LCLG < 2; g_LCLG++) begin: gf_LCLG
    lf71 i_gen_LCLG (
        .p0(sig[LCLG+2:1]),
        .p1(sig[0 +: LCLG]),
        .p2(sig[LCLG +: 4]),
        .p3(sig[LCLG]),
        .p4(sig[LCLG+1:0]),
        .p5(sig[31:LCLG]),
        .p6(LCLG),
        .p7(sig[LIT+2:LCLG])
    );
    logic [31:0] t_LCLG; assign t_LCLG = sig[31:LCLG];
  end
  assign o0 = sig;
endmodule

module top_earl71 (input [31:0] sig, output logic [31:0] o0);
  m1_earl71 i_m1 (.sig(sig), .o0(o0));
endmodule
