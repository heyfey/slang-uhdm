// § tfArgOutsideClassOrder216 — no own package subroutine: an own class and an outside class
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
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
