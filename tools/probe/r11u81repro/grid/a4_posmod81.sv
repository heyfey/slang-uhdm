// r11u81 arm a4 — THE ROUTE DISCRIMINATOR.  `ParamOverloading` regressed on
// the first cut of § hopStoreHandsOnItsTypespec81: its `'{v1, v2}` over two
// MODULE parameters is golden a constant with NO typespec at all, where the
// same hop out of a PACKAGE localparam is golden the hop's `int_typespec`.
// Surelog has TWO name-substitution routes — `CompileExpression.cpp:3030`
// mints a FRESH constant out of the simple Value store (typespec only when
// `sval->isSigned()`), and `:2973-2995` clones the `param_assign` Rhs and
// hangs the PARAMETER's own typespec on it.  This arm puts the four
// combinations side by side: module vs package home, POSITIONAL vs NAMED
// pattern, `parameter` vs `localparam` hop.
package a4p;
  localparam PU = 1;
  localparam PH = 4'h5;
  typedef struct packed {
    logic [4:0] w; logic [4:0] x; logic [4:0] y; logic [4:0] z;
  } t4;
  localparam t4 PKGNAMED = '{w: PU, x: PH, y: PU, z: PH};
  localparam t4 PKGPOS   = '{PU, PH, PU, PH};
endpackage
module a4_posmod81;
  typedef struct packed {
    logic [4:0] w; logic [4:0] x; logic [4:0] y; logic [4:0] z;
  } t4;
  parameter  MU = 1;
  parameter  MH = 4'h5;
  localparam LU = 1;
  localparam LH = 4'h5;
  parameter  t4 MODPOS    = '{MU, MH, LU, LH};
  parameter  t4 MODNAMED  = '{w: MU, x: MH, y: LU, z: LH};
  localparam t4 LOCPOS    = '{MU, MH, LU, LH};
  localparam t4 LOCNAMED  = '{w: MU, x: MH, y: LU, z: LH};
  a4_sink #(.R(MODPOS))   s1();
  a4_sink #(.R(MODNAMED)) s2();
  a4_sink #(.R(LOCPOS))   s3();
  a4_sink #(.R(LOCNAMED)) s4();
  a4_sink #(.R(a4p::PKGNAMED)) s5();
  a4_sink #(.R(a4p::PKGPOS))   s6();
endmodule
module a4_sink #(parameter a4p::t4 R = '{default: 0})
                (output logic [4:0] o);
  assign o = R.w;
endmodule
