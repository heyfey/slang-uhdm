// § thisNetHomeListedOnly243v
// the top imports the package written first; a child module imports a later package (out-of-body methods)
package p2;
  class c2;
    extern function void g();
  endclass
  function void c2::g(); $display("%p", this); endfunction
endpackage
package p1;
  class c1;
    extern function void f();
  endclass
  function void c1::f(); $display("%p", this); endfunction
endpackage
module child;
  import p1::*;
  c1 a;
endmodule
module top;
  import p2::*;
  c2 b;
  child u();
endmodule
