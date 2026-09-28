// § tfArgOutsideClassOrder216 — package enum written by an own class method, an own function, and another package's class method (bare import)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  class M;
    function void h(e_t z); endfunction
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
