// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
module a_m;
  import p::*;
  class K;
    s_t f;
  endclass
  s_t v;
endmodule
module b_m;
  import p::*;
  s_t w;
endmodule
module top;
  a_m x();
  b_m y();
endmodule
