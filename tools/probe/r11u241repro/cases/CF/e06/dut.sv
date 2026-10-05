// § cloneAggLocalOwnCopy241
package p;
  typedef enum { E_A, E_B } e_t;
  class pr;
    extern function int fmt(e_t e);
    extern function void hdr();
  endclass
  function int pr::fmt(e_t e);
    return int'(e);
  endfunction
  function void pr::hdr();
    e_t ri;
    ri = E_B;
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
