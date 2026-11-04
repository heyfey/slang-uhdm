// § cloneAggMemberOwn241
package p;
  typedef struct {
    int    level;
    string name;
  } row_t;
  class pr;
    extern function string fmt(row_t row);
  endclass
  function string pr::fmt(row_t row);
    return row.name;
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
