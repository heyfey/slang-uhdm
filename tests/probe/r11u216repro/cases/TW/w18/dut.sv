// § tfArgOutsideClassOrder216 — two outside classes in one module and a package class
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package q;
  import p::*;
  class N;
    task t(input e_t z2); endtask
  endclass
endpackage
module top;
  import p::*;
  class Mb;
    function void h(e_t z); endfunction
  endclass
  class Ma;
    function void h(e_t z3); endfunction
  endclass
  e_t v;
endmodule
