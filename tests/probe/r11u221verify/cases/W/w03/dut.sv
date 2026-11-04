// § tfArgOutsideClassKeyOrder216v — nested outside classes two levels deep q::Z::Y::A beside q::M and q::B (Z's key between B and M)
package p;
  typedef enum logic [1:0] {A0, B0, C0} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  class B;
    function void hb(e_t z); endfunction
  endclass
  class Z;
    class Y;
      class A;
        function void h(e_t z); endfunction
      endclass
    endclass
  endclass
  class M0;
    int k;
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
