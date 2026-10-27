// § formalClsElemMemberDrill449
package p;
  class B;
    int items[$];
  endclass
  class C;
    extern function void walk(ref B items[$]);
  endclass
  function void C::walk(ref B items[$]);
    foreach (items[i]) items[i] = null;
  endfunction
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
