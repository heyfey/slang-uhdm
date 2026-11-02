// § clsInModTdLastWriter462
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  typedef union packed { logic [4:0] a; s_t s; } u_t;
endpackage
module m;
  import p::*;
  class C;
    u_t f;
    function void set(s_t x); f.s = x; endfunction
  endclass
  u_t v;
  assign v.a = 5'h3;
endmodule
module top;
  m u();
endmodule
