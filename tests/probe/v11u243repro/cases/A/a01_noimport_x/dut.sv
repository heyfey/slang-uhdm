// § thisNetSurelogAnchor243
// a package referenced by p::c without import (its this written first) beside an imported package (out-of-body methods)
package p;
  class c;
    extern function void f();
  endclass
  function void c::f(); $display("%p", this); endfunction
endpackage
package q;
  class d;
    extern function void g();
  endclass
  function void d::g(); $display("%p", this); endfunction
endpackage
module top;
  import q::*;
  p::c o;
  d e;
endmodule
