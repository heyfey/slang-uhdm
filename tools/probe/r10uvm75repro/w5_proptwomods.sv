// VERIFIER control for w3 — the IDENTICAL two-importer shape, but the
// unresolvable OOB name is a CLASS PROPERTY (`m_cnt`), i.e. the PRE-EXISTING
// classPropRefs path, with NO with-clause anywhere.  If PRISTINE already
// over-mints here, w3's defect is pre-existing and r10uvm75 only widens it.
package p75w5;
  class c75;
    int m_cnt;
    extern function int oobf(int k);
  endclass
  function int c75::oobf(int k);
    return m_cnt + k;      // unresolvable at package scope -> hoisted bind
  endfunction
endpackage
import p75w5::*;
module sub75w5;
  c75 c;
  int r;
  initial begin c = new(); r = c.oobf(2); end
endmodule
module top75w5;
  c75 c;
  int r;
  sub75w5 u_sub();
  initial begin c = new(); r = c.oobf(1); end
endmodule
