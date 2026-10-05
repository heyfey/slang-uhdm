// § thisNetSurelogAnchor243
// an imported package written first, a later package used only by p::c (out-of-body methods)
package q;
  class d;
    extern function void g();
  endclass
  function void d::g(); $display("%p", this); endfunction
endpackage
package p;
  class c;
    extern function void f();
  endclass
  function void c::f(); $display("%p", this); endfunction
endpackage
module top;
  import q::*;
  p::c o;
  d e;
endmodule
