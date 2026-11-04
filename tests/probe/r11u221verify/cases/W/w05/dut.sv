// § tfArgOutsideClassKeyOrder216v — package names with digits and underscores: p_a, p1 own, p (key p1:: < p:: < p_a::)
package p1;
  typedef enum logic [1:0] {A0, B0, C0} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package p_a;
  import p1::*;
  class N;
    function void h(e_t z); endfunction
  endclass
endpackage
package p;
  import p1::*;
  class M;
    function void m(e_t w); endfunction
  endclass
endpackage
module top;
  import p1::*;
  e_t v;
endmodule
