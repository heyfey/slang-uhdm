// § grpOwnOobGenericCls472
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(int W = 2);
    int x;
    extern function new(int a);
    extern static function int cnt();
  endclass
  function D::new(int a); x = a; endfunction
  function int D::cnt(); return W; endfunction
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
