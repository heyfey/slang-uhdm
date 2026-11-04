// § cloneAggLocalOwnCopy241
package p;
  typedef struct {
    int    level;
    string name;
  } row_t;
  class pr;
    extern function void hdr();
  endclass
  function void pr::hdr();
    row_t ri;
    ri.level = 1;
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
