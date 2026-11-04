// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
module m;
  import p::s_t;
  class C;
    s_t f;
  endclass
  s_t v;
endmodule
module top;
  m u();
endmodule
