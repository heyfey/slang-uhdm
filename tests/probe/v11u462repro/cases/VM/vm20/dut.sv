// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
module zz;
  import p::*;
  class C;
    s_t f;
  endclass
  s_t v;
endmodule
module top;
  import p::*;
  s_t q;
  zz u();
endmodule
