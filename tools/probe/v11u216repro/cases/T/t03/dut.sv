// § tfArgOutsideClassKeyOrder216v — the typedef's package p1 and an outside package p: key p1::K sorts before p::M
package p1;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package p;
  import p1::*;
  class M;
    function void h(e_t z); endfunction
  endclass
endpackage
module top;
  import p1::*;
  e_t v;
endmodule
