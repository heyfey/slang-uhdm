// v98_c7 — DEEP chain (4 levels) + multiple inheritance through interface
// classes; the reference at every level.
package p7v;
  interface class i7a98v; typedef bit [1:0] dp7_t; pure virtual function void pa(); endclass
  interface class i7b98v; pure virtual function void pb(); endclass
  class a7win98v; typedef bit [9:0] dp7_t; endclass
  class l1_98v;   typedef int dp7_t; function void own1(dp7_t x); endfunction endclass
  class l2_98v extends l1_98v; function void h2(dp7_t x); endfunction endclass
  class l3_98v extends l2_98v; function void h3(dp7_t x); endfunction endclass
  class l4_98v extends l3_98v implements i7a98v, i7b98v;
    virtual function void pa(); endfunction
    virtual function void pb(); endfunction
    function void h4(dp7_t x); endfunction
  endclass
endpackage
module top7v;
  import p7v::*;
  l4_98v z;
  initial z = new();
endmodule
