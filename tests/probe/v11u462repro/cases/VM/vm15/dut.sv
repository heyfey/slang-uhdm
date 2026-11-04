// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
module m;
  import p::*;
  class C;
    function void f(s_t x); endfunction
  endclass
  s_t v;
endmodule
module top;
  m u1();
  m u2();
endmodule
