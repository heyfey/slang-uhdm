// § tfArgOutsideClassKeyOrder216v — the typedef's own package x_pkg (key x_pkg::K after work@top::M) and a module-scope class
package x_pkg;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
module top;
  import x_pkg::*;
  class M;
    function void h(e_t z); endfunction
  endclass
  e_t v;
endmodule
