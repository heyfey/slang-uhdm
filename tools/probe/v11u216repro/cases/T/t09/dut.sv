// § tfArgOutsideClassKeyOrder216v — a nested outside class q::Z::A beside q::M (Surelog compiles A with its outer class Z)
package p;
  typedef enum logic [1:0] {A0, B0, C0} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  class Z;
    class A;
      function void h(e_t z); endfunction
    endclass
  endclass
  class M;
    function void h2(e_t z2); endfunction
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
