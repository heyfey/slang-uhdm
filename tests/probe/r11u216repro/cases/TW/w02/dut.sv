// § tfArgOutsideClassOrder216 — control: the same package without the outside writer
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
module top;
  import p::*;
  e_t v;
endmodule
