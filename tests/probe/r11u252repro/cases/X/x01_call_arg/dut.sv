// § cloneHpIdxSelectByChain252
package p;
  class req; int sp; int arr[4]; endclass
  class seqr;
    req arb_q[$];
    function int is_blocked(int x); return 0; endfunction
    function int pick(int x); return x; endfunction
    extern function int choose();
  endclass
  function int seqr::choose();
    int i, temp;
    integer avail[$];
    int idx[$];
    for (i = 0; i < avail.size(); i++)
      if (is_blocked(arb_q[avail[i]].sp) != 0) i--;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
