// § tfArgOutsideClassOrder216 — two files: the outside class in the second file at the same line and column as the package's own function
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
