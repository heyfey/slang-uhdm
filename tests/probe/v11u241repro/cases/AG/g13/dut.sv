// § cloneAggMemberOwn241
package p;
  typedef struct { int lo; int hi; } r_t;
  function automatic int f(r_t a, r_t b);
    r_t c;
    c.lo = a.lo + b.lo;
    c.hi = a.hi;
    return c.lo - c.hi + a.hi;
  endfunction
  function automatic int g(r_t x);
    r_t y [2];
    y[0] = x;
    return y[0].lo;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  int v;
endmodule
