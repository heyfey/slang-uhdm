// § tfArgClassMethodOrder176
package p;
  typedef enum {A, B, C} e_t;
  class ka;
    function void f(e_t x);
    endfunction
  endclass
`include "cls.svh"
  function automatic int h(e_t z);
    return int'(z);
  endfunction
endpackage
module top;
  import p::*;
  ka o; kb q; int r;
  initial begin o = new; q = new; o.f(B); q.g(C); r = h(A); end
endmodule
