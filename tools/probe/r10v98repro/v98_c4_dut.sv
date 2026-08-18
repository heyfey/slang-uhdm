// v98_c4 — H3: an INTERFACE CLASS declaring the racing name, alphabetically
// first.  vsd11 says interface classes are not in bindTypedefs_'s list.
package p4v;
  interface class a4if98v;
    typedef bit [5:0] ik4_t;
    pure virtual function void ping();
  endclass
  class m4base98v;
    typedef int ik4_t;
    function void own(ik4_t x); endfunction
  endclass
  class z4der98v extends m4base98v implements a4if98v;
    virtual function void ping(); endfunction
    function void hot(ik4_t x); endfunction
  endclass
  class z5uses98v implements a4if98v;
    virtual function void ping(); endfunction
    function void hotif(a4if98v::ik4_t y); endfunction   // QUALIFIED iface-class td
  endclass
endpackage
module top4v;
  import p4v::*;
  z4der98v z;
  initial z = new();
endmodule
