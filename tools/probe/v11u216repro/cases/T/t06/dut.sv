// § tfArgOutsideClassOrder216 — a parameterized outside class (its method writes the enum through a specialization)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  class M #(int N = 1);
    function void h(e_t z); endfunction
  endclass
  class U;
    M#(2) m;
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
