// § tfArgOutsideClassKeyOrder216v — the typedef's package (second file of t11)
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
