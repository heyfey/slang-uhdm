// VERIFIER — sharpen w3/w5: TWO SIBLING importers, neither instantiating the
// other.  Tells whether golden's single-wire choice is DEPTH (innermost) or
// ELABORATION ORDER.
package p75w6;
  class c75;
    int m_cnt;
    extern function int oobf(int k);
  endclass
  function int c75::oobf(int k);
    return m_cnt + k;
  endfunction
endpackage
import p75w6::*;
module a75w6;
  c75 c; int r;
  initial begin c = new(); r = c.oobf(1); end
endmodule
module b75w6;
  c75 c; int r;
  initial begin c = new(); r = c.oobf(2); end
endmodule
