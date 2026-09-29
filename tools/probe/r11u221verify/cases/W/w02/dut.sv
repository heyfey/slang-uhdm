// § tfArgOutsideClassKeyOrder216v — uppercase package names (Zq sorts before work@ by byte, zq after) and a module-scope class
package p;
  typedef enum logic [1:0] {A0, B0, C0} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package Zq;
  import p::*;
  class N;
    function void h(e_t z); endfunction
  endclass
endpackage
module top;
  import p::*;
  class M;
    function void m(e_t w); endfunction
  endclass
  e_t v;
endmodule
