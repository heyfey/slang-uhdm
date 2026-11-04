// § tfArgOutsideClassOrder216 — the outside class method written by a macro
`define M_H(t) function void h(t z); endfunction
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
    `M_H(e_t)
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
