// § formalClsElemMemberDrill449
package p;
  class B;
    int blks[string];
  endclass
  class C;
    extern function void get_blocks(ref B blks[$]);
  endclass
  function void C::get_blocks(ref B blks[$]);
    foreach (blks[blk_]) begin
      blks[blk_] = null;
    end
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
