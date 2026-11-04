// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
module m;
  class C;
    p::s_t f;
  endclass
  p::s_t v;
endmodule
module top;
  m u();
endmodule
