// § tfArgOutsideClassOrder216 — another package's package-level function (bare import) beside the class writer
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  function automatic void h(e_t z); endfunction
endpackage
module top;
  import p::*;
  e_t v;
endmodule
