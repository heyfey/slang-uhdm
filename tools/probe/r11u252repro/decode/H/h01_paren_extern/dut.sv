// § cloneHpIdxSelectByChain252 (decode only: an out-of-body definition with parentheses and two local declarations is stage 1 on both binaries)
package p;
  class req; int sp; endclass
  class seqr;
    req arb_q[$];
    function int is_blocked(int x); return 0; endfunction
    extern function int choose();
  endclass
  function int seqr::choose();
    int avail[$];
    int i;
    for (i = 0; i < avail.size(); i++)
      if (is_blocked(arb_q[avail[i]].sp) != 0) i--;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
