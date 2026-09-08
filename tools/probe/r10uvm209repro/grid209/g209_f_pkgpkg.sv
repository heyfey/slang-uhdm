// r10uvm209 grid arm F — THE TRANSITIVE PATH.  A package that wildcard-imports
// another materialises a CLONE of the home package's whole listing (the
// package-side sibling of the module hoist), and a module then imports THAT.
// This is the shape SeqDriver's `adpcm_pkg` has, and the arm that says whether
// the transitive copies carry the lifetime too.
package pf209;
  class cj209;
    int n;
  endclass
  class ck209;
    int q;
    extern function new();
  endclass
  function ck209::new();
    cj209  lf_cls;
    int    lf_int;
    string lf_str;
    lf_cls = null;
    q = 4;
  endfunction
  cj209 pf_cls;
  int   pf_int = 11;
endpackage

package pg209;
  import pf209::*;
  int pg_own = 13;
endpackage

import pg209::*;

module gf209;
  initial $display("%0d", pg_own);
endmodule
