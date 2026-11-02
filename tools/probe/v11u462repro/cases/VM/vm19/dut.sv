// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
interface zi;
  import p::*;
  s_t w;
endinterface
module m;
  import p::*;
  class C;
    s_t f;
  endclass
  s_t v;
endmodule
module top;
  m u();
  zi i();
endmodule
