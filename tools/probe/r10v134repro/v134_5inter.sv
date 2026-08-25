// r10v134 grid 5 — INTERACTIONS with the protected laws:
//   buvm33 (`::`-written scoped array), uvm84/85 (this./super.),
//   buvm34 (loop-variable int fallback), uvm25 (package class-handle array).
package zpk5;

  class Node5;
    int nq[$];
    int nf[3];
  endclass

  class BaseA5;
    Node5 bn[$];
    Node5 bplain[$];
    function void b_here(); foreach (bn[w1]) foreach (bn[w1].nq[w2]) $display(w2); endfunction
  endclass

  class DerivB5 extends BaseA5;
    typedef DerivB5 this_type5;
    static Node5 statnodes[$];
    Node5 dn[$];

    // super.-rooted, indexed, member
    function void d_super();  foreach (super.bn[w3]) foreach (super.bn[w3].nq[w4]) $display(w4); endfunction
    // super. plain (control, must not move)
    function void d_superb(); foreach (super.bplain[w5]) $display(w5); endfunction
    // this_type::-written scoped array (buvm33), plain — control
    function void d_scoped();  foreach (this_type5::statnodes[w6]) $display(w6); endfunction
    // this_type::-written scoped array, INDEXED then member — the interaction
    function void d_scopedidx();
      foreach (this_type5::statnodes[w7]) foreach (this_type5::statnodes[w7].nq[w8]) $display(w8);
    endfunction
    // package::-written scoped array, indexed then member
    function void d_pkgscoped();
      foreach (zpk5::pkgnodes[w9]) foreach (zpk5::pkgnodes[w9].nf[wa]) $display(wa);
    endfunction
    // this. + indexed + member
    function void d_thisidx(); foreach (this.dn[wb]) foreach (this.dn[wb].nq[wc]) $display(wc); endfunction
  endclass

  Node5 pkgnodes[$];
  Node5 pkgfix[5];

  // package free function, bare package class-handle array (uvm25 control)
  function void p_bare5(); foreach (pkgnodes[wd]) $display(wd); endfunction
  // package free function, indexed then member -> the law
  function void p_idx5();  foreach (pkgnodes[we]) foreach (pkgnodes[we].nq[wf]) $display(wf); endfunction
  function void p_idxf5(); foreach (pkgfix[wg]) foreach (pkgfix[wg].nf[wh]) $display(wh); endfunction

endpackage

// A $unit-scope wildcard import (classPropUnitImport21's gate)
import zpk5::*;

module top5;
  Node5 tn[2];
  initial foreach (tn[wi]) foreach (tn[wi].nq[wj]) $display(wj);
endmodule
