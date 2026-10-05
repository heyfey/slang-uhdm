// § thisNetSurelogAnchor243
// two file-scope imports written against their packages' text order (out-of-body methods)
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
import p2::*;
import p1::*;
module top;
  c1 a;
  c2 b;
endmodule
