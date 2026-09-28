// § tfArgOutsideClassOrder216 — the typedef's own package sorts after the outside package (MiniAmiq's shape: svaunit_pkg before uvm_pkg)
package zp;
  typedef enum logic [1:0] {A, B, C} e_t;
  class K;
    function void f(e_t x); endfunction
  endclass
  function automatic void g(e_t y); endfunction
endpackage
package aq;
  import zp::*;
  class M;
    function void h(e_t z); endfunction
  endclass
endpackage
module top;
  import zp::*;
  e_t v;
endmodule
