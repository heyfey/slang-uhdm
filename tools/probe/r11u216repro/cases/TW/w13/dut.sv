// § tfArgOutsideClassOrder216 — the outside package's class in an included header
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
`include "m.svh"
endpackage
module top;
  import p::*;
  e_t v;
endmodule
