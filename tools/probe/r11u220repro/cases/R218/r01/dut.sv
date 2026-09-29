// § importCloneSharesHomeReturn218
package p1;
  typedef struct packed { logic [3:0] a; } s_t;
  class c;
    extern function s_t f(int i);
  endclass
  function s_t c::f(int i);
    s_t r; r.a = i; return r;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
package p3;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  import p3::*;
  assign o = 1;
endmodule
