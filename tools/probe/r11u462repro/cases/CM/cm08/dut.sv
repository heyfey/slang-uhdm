// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
endpackage
module m;
  import p::s_t;
  import p::u_t;
  class C;
    s_t k;
  endclass
  s_t v;
  u_t w;
endmodule
module top;
  m u();
endmodule
