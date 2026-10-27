// § formalClsElemMemberDrill449
package p;
  class C;
    local int unsigned blks[C];
    extern function void get_blocks(ref C blks[]);
  endclass
  function void C::get_blocks(ref C blks[]);
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
