// § formalClsElemMemberDrill449
package p;
  class C;
    C nxt;
    local int unsigned blks[C];
    extern function void get_all(ref C q[$]);
  endclass
  function void C::get_all(ref C q[$]);
    foreach (q[i]) begin
      C b = q[i];
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
