// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
  class PC;
    s_t z;
  endclass
endpackage
module m;
  import p::*;
  class C extends PC;
    s_t f;
  endclass
  s_t v;
endmodule
module top;
  m u();
endmodule
