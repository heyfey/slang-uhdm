// § tfArgOutsideClassOrder216 — a CRLF file (w01)
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
    function void h(e_t z); endfunction
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
