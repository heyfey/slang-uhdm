// § cloneAggLocalOwnCopy241
package p;
  typedef union tagged { int i; logic [7:0] b; } tu_t;
  typedef union { int i; shortint s; } uu_t;
  class c;
    extern function int f(uu_t x);
    extern function int g();
  endclass
  function int c::f(uu_t x);
    return x.i;
  endfunction
  function int c::g();
    tu_t t;
    uu_t u;
    u.i = 3;
    return f(u);
  endfunction
endpackage
package q;
  import p::*;
  class w; c x; endclass
endpackage
module top;
  import q::*;
  w a;
endmodule
