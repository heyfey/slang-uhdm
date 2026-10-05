// § thisNetSurelogAnchor243
// an explicit item import of the second package, a wildcard import of the first (out-of-body methods)
package p1;
  class c1;
    extern function void f();
  endclass
  function void c1::f(); $display("%p", this); endfunction
endpackage
package p2;
  class c2;
    extern function void g();
  endclass
  function void c2::g(); $display("%p", this); endfunction
endpackage
module top;
  import p2::c2;
  import p1::*;
  c2 o;
  c1 e;
endmodule
