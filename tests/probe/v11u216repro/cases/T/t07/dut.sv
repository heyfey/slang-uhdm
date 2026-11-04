// § tfArgOutsideClassOrder216 — an outside class written in a macro body, formal qualified p::e_t, package prefix pair p / p_q
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
`define OUTCLS(nm) class nm; function void h(p::e_t z); endfunction endclass
package p_q;
  `OUTCLS(M)
endpackage
module top;
  import p::*;
  e_t v;
endmodule
