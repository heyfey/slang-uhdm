// v98_c12 — MUTUAL inherited-name references between two families: can the
// on-demand winner build recurse?
package p12v;
  class a12win98v;
    typedef int cy12a_t;
    typedef int cy12b_t;
  endclass
  class fam1base98v; typedef bit cy12a_t; endclass
  class fam2base98v; typedef bit cy12b_t; endclass
  class fam1der98v extends fam1base98v;
    function void h1(cy12a_t x); endfunction
    typedef cy12a_t alias1_t;
  endclass
  class fam2der98v extends fam2base98v;
    function void h2(cy12b_t x); endfunction
    typedef cy12b_t alias2_t;
  endclass
endpackage
module top12v;
  import p12v::*;
  fam1der98v a; fam2der98v b;
  initial begin a = new(); b = new(); end
endmodule
