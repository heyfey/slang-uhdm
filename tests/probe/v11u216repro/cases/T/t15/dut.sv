// § tfArgOutsideClassOrder216 — an outside class's task (not a function) and an outside class's static function with an output formal
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
    task t(input e_t z); endtask
    static function void s(output e_t o); o = A; endfunction
  endclass
endpackage
module top;
  import p::*;
  e_t v;
endmodule
