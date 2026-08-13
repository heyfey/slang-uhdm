// The wildcard-import CLONE body: a package function whose return-type range
// names its own package's folded parameter, imported into a module that CALLS
// it.  This is the shape whose pendingFuncRet entry has pkgScope==false =>
// pf.inst==nullptr => retTopView67==false => retLocalDefView67 forced TRUE.
// README.verifier.md §2.4 names it as unmeasured.
package c5pkg;
  parameter C5_W = 120*8-1;
  function bit[C5_W:0] c5_bits(string s);
    c5_bits = 0;
  endfunction
endpackage

import c5pkg::*;

module c5top;
  bit [C5_W:0] v;
  initial v = c5_bits("x");
endmodule
