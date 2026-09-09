// v226 b15 — §223's hoisted import nets + the shadowed-param fold, now with a
// PROCESS reading them.  `defStmtImportScope9 = &body` is raised for the new
// loop; this arm is what says whether that changes a parameter's fold.
package bi_pkg;
  parameter int SHADOW = 5;
  int    pv;
  int    tbl [string];
  typedef logic [3:0] q_t;
endpackage

interface bi_if;
  import bi_pkg::*;
  parameter int SHADOW = 9;       // shadows the package's
  q_t  qv;
  int  n;
  initial begin
    n  = SHADOW;                  // which SHADOW?
    n  = pv;                      // hoisted import net
    qv = 4'h3;
  end
  always_comb n = bi_pkg::SHADOW;
endinterface

interface bi_if2;
  import bi_pkg::SHADOW;
  int n;
  initial n = SHADOW;
endinterface
