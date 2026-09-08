// v214 arm 4 — THE `$unit` POOL'S BLAST RADIUS.  A compilation-unit
// `import pv4q::*;` hoists pv4q's parameters into design->Parameters(); pv4p's
// own def clone listing reads pv4p::ca4, and pv4q ALSO declares a parameter
// named `ca4` with a DIFFERENT value.  Surelog's lateBinding step (2) matches
// design parameters BY NAME ONLY, so this arm decides whether the § 146
// re-point that this pass now feeds `ref_obj` actuals to takes the FOREIGN
// design parameter — and whether golden does.
import pv4q::*;
package pv4q;
  parameter int ca4 = 999;
  parameter int qb4 = 5;
endpackage
package pv4p;
  parameter int ca4 = 17;
  parameter cb4 = ca4;
  function automatic int psink4(int a, int b); return a + b; endfunction
  class P4;
    extern function int p_rd4();
  endclass
  function int P4::p_rd4();
    return psink4(ca4, cb4);
  endfunction
endpackage
module topv4;
  pv4p::P4 p = new();
  int x;
  initial x = p.p_rd4();
endmodule
