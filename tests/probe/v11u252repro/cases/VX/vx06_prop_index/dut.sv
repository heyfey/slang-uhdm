// § cloneHpIdxSelectByChain252
package p;
  class req; int sp; int arr[4]; endclass
  class seqr;
    req arb_q[$];
    int m_idx[$];
    function int is_blocked(int x); return 0; endfunction
    function int pick(int x); return x; endfunction
    extern function int choose();
  endclass
  function int seqr::choose();
    int i, j, temp;
    integer avail[$];
    int idx[$];
    for (i = 0; i < m_idx.size(); i++)
      temp = arb_q[m_idx[i]].sp;
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
