// § cloneHpIdxSelectByChain252
package p;
  class req; int sp; endclass
  class seqr;
    req arb_q[$];
    extern function int pick(int x);
    function int choose();
      integer avail[$];
      return pick(arb_q[avail[0]].sp) + arb_q[avail[pick(0)]].sp;
    endfunction
  endclass
  function int seqr::pick(int x); return x; endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
