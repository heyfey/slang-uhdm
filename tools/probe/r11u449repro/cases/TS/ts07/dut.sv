// § formalClsElemMemberDrill449
package p;
  class B; endclass
  class C;
    B other;
    local int unsigned blks[B];
    extern function void get_blocks(ref B blks[$]);
  endclass
  function void C::get_blocks(ref B blks[$]);
    foreach (this.blks[blk_]) begin
      B b = blk_;
      blks.push_back(b);
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
