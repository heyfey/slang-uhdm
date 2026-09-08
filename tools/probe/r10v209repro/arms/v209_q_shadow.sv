// v209 verifier arm Q — NAME COLLISION.  A hoisted constructor local carries
// the SAME NAME as a package member of the same kind, so a rule that keys on
// the name rather than on the declaration would cross them.  The package
// member is a bare type identifier (net shape, unmarked) and the local is the
// same spelling (data declaration, automatic): the two must come out
// DIFFERENT.
package pq209;
  class cq209a;
    int n;
  endclass
  cq209a shared_h;
  int    shared_i;
  class cq209b;
    int q;
    extern function new();
  endclass
  function cq209b::new();
    cq209a shared_h;
    int    shared_i;
    shared_h = null;
    shared_i = 12;
    q = shared_i;
  endfunction
endpackage

import pq209::*;

module gq209;
  initial $display("q");
endmodule
