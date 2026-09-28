// § tfArgOutsideClassOrder216 — the outside class method in the design's own module-scope class (not a package)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
module top;
  import p::*;
  class M;
    function void h(e_t z); endfunction
  endclass
  e_t v;
endmodule
