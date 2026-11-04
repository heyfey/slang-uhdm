// § formalClsElemMemberDrill449
package p;
  class C;
    int vals[string];
    extern function void get(ref int vals[$]);
  endclass
  function void C::get(ref int vals[$]);
    foreach (this.vals[k]) vals.push_back(this.vals[k]);
  endfunction
endpackage
package r;
  import p::*;
  int k2;
endpackage
module top;
  import r::*;
endmodule
