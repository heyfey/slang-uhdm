// § tfArgOutsideClassOrder216 — a packed struct typedef (not an enum) written by an own class, an own function and another package's class
package p;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  class K;
    function void f(s_t x); endfunction
  endclass
  function automatic void g(s_t y); endfunction
endpackage
package q;
  import p::*;
  class M;
    function void h(s_t z); endfunction
  endclass
endpackage
module top;
  import p::*;
  s_t v;
endmodule
