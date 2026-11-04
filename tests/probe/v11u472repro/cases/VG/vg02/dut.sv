// § grpOwnOobGenericCls472
package p;
  function int pf(); return 1; endfunction
endpackage
package q;
  import p::*;
  class D #(type T = int);
    T v;
    extern function T get();
    extern function void set(T x);
  endclass
  function D::T D::get(); return v; endfunction
  function void D::set(T x); v = x; endfunction
endpackage
package r;
  import q::*;
  class S;
    int k;
  endclass
endpackage
module top;
  import r::*;
endmodule
