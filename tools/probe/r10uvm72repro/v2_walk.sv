// VERIFIER arm v2 — the WALK semantics pkgFreeSubForName72 implements, at the
// edges a1/a2 do not reach:
//   * CROSS-PACKAGE inheritance: base class in pkg A, derived in pkg B, and a
//     free `ge` in BOTH.  Which one does golden bind?  The helper walks out of
//     the CALLER, so it must answer pkg B's.
//   * a class NESTED in a class: the walk pops MORE THAN ONE ClassType.
//   * DIRECT member vs WILDCARD import PRECEDENCE: a package that declares its
//     own `ge` AND wildcard-imports another that also declares one.
package qa;
  function int ge(int v);            // pkg A's free twin
    return v + 10;
  endfunction
  class abase;
    function int ge(int v);          // the shadowing method
      return v + 1;
    endfunction
  endclass
endpackage

package qb;
  import qa::*;
  function int ge(int v);            // pkg B's OWN free twin (direct member)
    return v + 20;
  endfunction
  // caller lives in qb, base class lives in qa
  class bderived extends qa::abase;
    int r;
    function void x_cross();
      r = ge(1);                     // cross-package: qb::ge or qa::ge?
    endfunction
  endclass
endpackage

// wildcard-ONLY: package qc has NO own `ge`, imports qa's
package qc;
  import qa::*;
  class cderived extends qa::abase;
    int r;
    function void x_wild();
      r = ge(2);                     // only reachable twin is qa::ge
    endfunction
  endclass
endpackage

module top;
  qb::bderived b;
  qc::cderived c;
  initial begin
    b = new(); b.x_cross();
    c = new(); c.x_wild();
  end
endmodule
