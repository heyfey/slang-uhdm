// § cloneAggLocalOwnCopy241
package p;
  typedef struct { int a; } s_t;
  typedef s_t s2_t;
  class c;
    extern function int f(s2_t x);
    extern function int h();
  endclass
  function int c::f(s2_t x);
    return x.a;
  endfunction
  function int c::h();
    s_t l1;
    s2_t l2;
    s_t arr[2];
    l1.a = 1; l2 = l1; arr[0] = l2;
    return f(l2) + arr[0].a;
  endfunction
endpackage
package q;
  import p::*;
  class u; c x; endclass
endpackage
module top;
  import q::*;
  u w;
endmodule
