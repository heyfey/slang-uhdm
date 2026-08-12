// r10earl32 VERIFIER arm v3 — THE FALL-THROUGH ARMS THE FOLD NOW REACHES.
//
// The shipped fix is a FALL-THROUGH: when fcArgFold32 holds, the call-argument
// carve-out is skipped and control reaches, in order, the
//   (1) pkgElabSymOperands       (2) noParamSubst && paramSubstRefused
//   (3) patParamNoFold / paramRhsDefView && paramDefRhsIsOp
// arms, EACH OF WHICH RETURNS A ref_obj OF A DIFFERENT SHAPE than the carve-out
// did.  Arm (2) is reachable from the CORPUS: `-disable-feature=
// parametersubstitution` is one of the two IMPLEMENTED_FEATURES the testflags
// mode passes through verbatim (scripts/verify_golden.py:269).  Under that flag
// a call-argument package parameter used to leave the carve-out's QUALIFIED ref
// (name `pk::P`, span = the `pk::` qualifier, Actual = the package def param)
// and now leaves arm (2)'s ref instead (fullname scoped to the reader, span =
// the whole read, Actual = the elaborated param_assign Lhs).
//
// Run this arm TWICE: once plain, once with the flag on BOTH tools.
package m32x;
  localparam logic [11:0] P = 12'h380;
endpackage

module m32xa (output logic [31:0] o1, o2);
  import m32x::*;
  function automatic logic [31:0] mf(logic [11:0] v); return {v, 20'h0}; endfunction
  assign o1 = mf(m32x::P);   // x1 QUALIFIED
  assign o2 = mf(P);         // x2 BARE (the materialized import copy)
endmodule

module m32xtop;
  logic [31:0] a1, a2;
  m32xa ua (.o1(a1), .o2(a2));
endmodule
