// § clsInModTdLastWriter462
module m;
  typedef struct { int a; logic [3:0] b; } ls_t;
  class C;
    typedef struct { int q; } own_t;
    own_t o;
    ls_t f;
  endclass
  ls_t v;
endmodule
module top;
  m u();
endmodule
