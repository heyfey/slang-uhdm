// wb.sv — PASS 14, the 2x2 that separates § pkgOwnParamIntEnc's KEY.
// wa.sv proved a MATERIALIZED IMPORT COPY of `parameter int A = X % Y` folds
// to a signed INT constant (ct7) in golden and UINT (ct9) in ours.  The open
// question is whether the key is (a) "the param_assign Rhs of a materialized
// import copy" or (b) "any TYPED param whose initializer is intEnc" — (b)
// would touch every module in the corpus, so it must be measured, not assumed.
//   rows M/N  a module's OWN typed localparam / parameter with a `%` init
//             (NOT imported) — the negative control for (b).
//   rows P/Q  the module's own `+` twins.
//   rows A/C  the imported `%` / `+` copies (wa rows A/C, re-measured here).
package wbp;
  parameter int WDW = 16;
  parameter int WBW = 5;
  parameter int A = WDW % WBW;   // intEnc
  parameter int C = WDW + WBW;   // plain
endpackage

module wbmod;
  import wbp::*;
  localparam int M = 16 % 5;     // own localparam, intEnc
  parameter  int N = 16 % 5;     // own parameter,  intEnc
  localparam int P = 16 + 5;     // own localparam, plain
  parameter  int Q = 16 + 5;     // own parameter,  plain
  logic [A:0] a_n;
  logic [C:0] c_n;
  logic [M:0] m_n;
endmodule
