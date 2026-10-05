// § thisNetSurelogAnchor243
// a file-scope import written after a module import's package in the text (out-of-body methods)
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
import p::*;
module top;
  import q::*;
  c o;
  d e;
endmodule
