// § formalClsElemMemberDrill449
package p;
  class C;
    local int unsigned blks[C];
    extern function void get_blocks(ref C blks[$]);
  endclass
  function void C::get_blocks(ref C blks[$]);
    foreach (this.blks[blk_]) begin
      C b = blk_;
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
