// § tfArgOutsideClassOrder216 — a module-scope class and another package's class, both outside
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  class N;
    function void h2(e_t z2); endfunction
  endclass
endpackage
module top;
  import p::*;
  class M;
    function void h(e_t z); endfunction
  endclass
  e_t v;
endmodule
