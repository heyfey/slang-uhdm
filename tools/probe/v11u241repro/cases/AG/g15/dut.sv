// § cloneAggTsAtHomeListing241
package p;
  typedef enum { E0, E1 } e_t;
  typedef struct { int level; e_t k; } row_t;
  class pr;
    extern function int fmt(row_t row, e_t e);
    extern function void hdr();
  endclass
  function int pr::fmt(row_t row, e_t e);
    return row.level + int'(e);
  endfunction
  function void pr::hdr();
    begin
      row_t ri;
      e_t ee;
      ri.level = 1;
      void'(fmt(ri, ee));
    end
  endfunction
endpackage
package q1;
  import p::*;
  class u;
    pr x;
  endclass
endpackage
package q2;
  import p::*;
  class v;
    pr y;
  endclass
endpackage
module top;
  import q1::*;
  import q2::*;
  u w; v z;
endmodule
