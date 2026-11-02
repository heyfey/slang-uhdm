// § clsInModTdLastWriter462
package p;
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
  typedef struct packed { u_t x; logic y; } s_t;
endpackage
module m;
  import p::*;
  class C;
    s_t f;
    u_t g;
  endclass
  s_t v;
endmodule
module top;
  m u();
endmodule
