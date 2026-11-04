// § tfArgOutsideClassOrder216 — an out-of-body method definition of the outside class
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
    extern function void h(e_t z);
  endclass
  function void M::h(e_t z); endfunction
endpackage
module top;
  import p::*;
  e_t v;
endmodule
