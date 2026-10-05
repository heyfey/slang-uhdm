// § cloneAggMemberOwn241
package p;
  typedef struct { int lo; int hi; } in_t;
  typedef struct {
    int    level;
    in_t   r;
  } row_t;
  class pr;
    extern function int fmt(row_t row);
    extern function void hdr();
  endclass
  function int pr::fmt(row_t row);
    return row.r.hi + row.level;
  endfunction
  function void pr::hdr();
    row_t ri;
    ri.level = 1;
    ri.r.lo = 2;
    void'(fmt(ri));
  endfunction
endpackage
package q;
  import p::*;
  class u;
    pr x;
  endclass
endpackage
module top;
  import q::*;
  u w;
  initial w = new();
endmodule
