// § tfArgOutsideClassOrder216 — another package's class method with a qualified formal type
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  class M;
    function void h(p::e_t z); endfunction
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
