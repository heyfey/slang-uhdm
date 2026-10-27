// § formalClsElemMemberDrill449
package p;
  class A;
    int unsigned blks[A];
  endclass
  class C extends A;
    extern function void get_blocks(ref C blks[$]);
  endclass
  function void C::get_blocks(ref C blks[$]);
    foreach (blks[i]) blks[i] = null;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
