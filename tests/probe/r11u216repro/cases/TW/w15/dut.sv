// § tfArgOutsideClassOrder216 — a module function beside an outside class (declined)
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
  function automatic void mf(e_t w); endfunction
  e_t v;
endmodule
