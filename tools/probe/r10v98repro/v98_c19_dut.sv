// v98_c19 — the WINNER is a typedef inside a GENERIC class with three live
// specialisations (specializations() is an unordered map: determinism).
package p19v;
  class a19win98v #(int W = 1);
    typedef bit [W-1:0] gk19_t;
  endclass
  class m19base98v; typedef int gk19_t; function void own(gk19_t x); endfunction endclass
  class z19der98v extends m19base98v; function void hot(gk19_t x); endfunction endclass
endpackage
module top19v;
  import p19v::*;
  a19win98v#(4) s1; a19win98v#(8) s2; a19win98v#(12) s3;
  z19der98v z;
  initial begin s1 = new(); s2 = new(); s3 = new(); z = new(); end
endmodule
