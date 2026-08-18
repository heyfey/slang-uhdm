// v98_c17 — a NESTED class winner (short-name key, pass 11's shape) racing a
// package-level class whose key carries the package prefix.
package pv17v;
  class zouter17v;
    class binner17v;                 // key "binner17v" < "pv17v::zbase17v"
      typedef bit [7:0] nk17_t;
    endclass
  endclass
  class zbase17v; typedef int nk17_t; function void own(nk17_t x); endfunction endclass
  class zder17v extends zbase17v; function void hot(nk17_t x); endfunction endclass
endpackage
module top17v;
  pv17v::zder17v z;
  pv17v::zouter17v::binner17v b;
  initial begin z = new(); b = new(); end
endmodule
