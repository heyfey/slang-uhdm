// § cloneAggTsAtHomeListing241
`define FM(T, N) T N
package p;
`include "types.svh"
  class pr;
    extern function string fmt(`FM(row_t, row));
    extern function void hdr();
  endclass
  function string pr::fmt(`FM(row_t, row));
    return row.name;
  endfunction
  function void pr::hdr();
    row_t ri;
    ri.level = 1;
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
