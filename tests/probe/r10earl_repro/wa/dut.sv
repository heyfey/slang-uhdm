// wa.sv — PASS 14 witness for the flash_phy_pkg ct7-vs-ct9 head.
// § pkgOwnParamIntEnc: golden reads `parameter int AddrBitsRemain =
// DataWidth % BusWidth` in a PACKAGE's own param_assign as a signed INT
// constant (ct7); we write UINT (ct9).  The 2x2 separates the two candidate
// keys — (a) the `%` operator itself vs (b) the fact that the operands are
// CROSS-PACKAGE reads — and adds `+` rows as the negative control.
package wap;
  parameter int WDW = 16;
  parameter int WBW = 4;
endpackage

package waq;
  // A: cross-package `%`  — the flash_phy_pkg:31 shape exactly.
  parameter int A = wap::WDW % wap::WBW;
  // B: cross-package `/`  — flash_phy_pkg:34.
  parameter int B = wap::WDW / wap::WBW;
  // C: cross-package `+`  — the NEGATIVE control (an ADD is not intEnc).
  parameter int C = wap::WDW + wap::WBW;
  // D: SAME-package `%`   — is the cross-package hop load-bearing?
  parameter int WD2 = 16;
  parameter int WB2 = 4;
  parameter int D = WD2 % WB2;
  // E: SAME-package `+`   — negative control for D.
  parameter int E = WD2 + WB2;
  // F: a plain read of an intEnc parameter (A) — the propagation arm.
  parameter int F = A;
endpackage

module wamod;
  import waq::*;
  logic [A:0] a_n;
  logic [C:0] c_n;
endmodule
