// § formalClsElemMemberDrill449
package p;
  class C;
    static int unsigned blks[C];
    function void get_blocks(ref C blks[$]);
      foreach (blks[i]) blks[i] = null;
    endfunction
  endclass
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
