// VERIFIER arm (r11v51) — the cell vb2 had to be split out: a PART-SELECT of a
// concatenation as a package parameter Rhs.  RECORDED AS AN OURS-SIDE ERROR
// CELL, not as a golden claim: our binary exits 4 with "unsupported constructs
// encountered: range select base".  An arm whose compile fails teaches
// error-recovery, not golden — this one is here so the failure is on the
// record with its rc, and so road B's implementer knows the construct is a
// hole in our emitter before the elaborated-package arm is touched.
package pk;
  parameter logic [1:0] C0 = 2'b00;
  parameter logic [1:0] K5 = {C0}[1:0];
endpackage
module dut (output logic o);
  assign o = ^{pk::K5[0]};
endmodule
