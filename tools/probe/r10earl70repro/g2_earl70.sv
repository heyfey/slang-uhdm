// r10earl70 arm 2 — MEASUREMENT ONLY.  The AXES arm 1 left open for
// § connPsBoundOuterScopeKeepsRef70: the written QUALIFIER, the generate
// container (for / if / nested / instance array), an UNTYPED package
// parameter, and the module-scope control.
package qa_earl70;
  parameter  int QP  = 16;
  parameter      QU  = 16;          // UNTYPED package parameter
  parameter  int QLO = 1;
  localparam int QL  = 16;
endpackage

module qlf_earl70 (
  input [31:0] p0, input [31:0] p1, input [31:0] p2, input [31:0] p3);
endmodule

module q1_earl70 import qa_earl70::*; (input [31:0] sig, output logic [31:0] o);
  localparam int MLOC = 16;

  // A1 module-scope home, bare / qualified / untyped / localparam-of-package
  qlf_earl70 i_mod (
    .p0(sig[QP-1:QLO]),
    .p1(sig[qa_earl70::QP-1:QLO]),
    .p2(sig[QU-1:QLO]),
    .p3(sig[QL-1:QLO])
  );

  // A2 gen-for home, same four
  for (genvar i = 0; i < 2; i++) begin: gfor
    qlf_earl70 i_g (
      .p0(sig[QP-1:QLO]),
      .p1(sig[qa_earl70::QP-1:QLO]),
      .p2(sig[QU-1:QLO]),
      .p3(sig[QL-1:QLO])
    );
  end

  // A3 gen-IF home
  if (1) begin: gif
    qlf_earl70 i_gi (
      .p0(sig[QP-1:QLO]),
      .p1(sig[qa_earl70::QP-1:QLO]),
      .p2(sig[QU-1:QLO]),
      .p3(sig[MLOC-1:QLO])
    );
  end

  // A4 NESTED gen-for inside gen-for, with an OUTER gen-block localparam
  for (genvar j = 0; j < 2; j++) begin: gout
    localparam int OUTL = 16;
    for (genvar k = 0; k < 2; k++) begin: gin
      localparam int INL = 16;
      qlf_earl70 i_gn (
        .p0(sig[QP-1:QLO]),
        .p1(sig[OUTL-1:QLO]),
        .p2(sig[INL-1:QLO]),
        .p3(sig[MLOC-1:QLO])
      );
    end
  end

  // A5 INSTANCE ARRAYS were measured on GOLDEN in this arm's first cut and
  // then REMOVED: slang rejects `qlf i_arr[1:0](.p0(sig[QP-1:QLO]))` (a 15-bit
  // actual does not divide over two 32-bit ports), so the arm could not be
  // compiled by BOTH tools.  Golden's answer is recorded in the README grid:
  // a module-scope instance ARRAY folds exactly like a single module-scope
  // instantiation, and an instance array INSIDE a gen-for keeps the ref and
  // binds the enum_const exactly like a single gen-scope instantiation.
  assign o = sig;
endmodule

module qtop_earl70 (input [31:0] sig, output logic [31:0] o);
  q1_earl70 i_q1 (.sig(sig), .o(o));
endmodule
