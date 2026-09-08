// verifier arm 7 — MUST-STAY-FOLDED control, wider than the pass's arm H.
package v7pkg;
  parameter        S_ADD   = 1 + 2;
  parameter        S_MUL   = 3 * 4;
  parameter        S_REPL  = {3{2'b01}};
  parameter        S_CATS  = {"ab", "cd"};
  parameter signed S_SGN   = -7;
  parameter        S_BITS  = $bits(int);
  parameter        S_CAST  = int'(3.7);
  parameter        S_CLOG  = $clog2(17);
  parameter [7:0]  S_VEC   = 8'hAB;
  parameter        S_TERN  = (1 > 0) ? 1 : 2;
endpackage
module v7mod;
  import v7pkg::*;
endmodule
