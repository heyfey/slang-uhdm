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
    for (i = 0; i < avail.size(); i++) begin
      arb_q[avail[i]].sp++;
      arb_q[avail[i]].sp = arb_q[avail[i]].sp + 1;
    end
    return 0;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
