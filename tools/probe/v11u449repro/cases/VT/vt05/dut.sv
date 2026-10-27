// § formalClsElemMemberDrill449
package p;
  class C;
    string blks[int];
    extern function void get_blocks(ref C blks[2]);
  endclass
  function void C::get_blocks(ref C blks[2]);
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
