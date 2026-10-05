// § cloneAggMemberOwn241
package p;
  typedef struct { int lo; int hi; } in_t;
  typedef struct { in_t r; string nm; } out_t;
  class c;
    extern function int span(out_t o);
  endclass
  function int c::span(out_t o);
    out_t t;
    t = o;
    t.nm = "x";
    return t.r.hi - o.r.lo;
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
