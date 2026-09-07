// r10v195 arm C — MULTIPLE INSTANCES and a CHAINED wildcard import (a clone of
// a clone), three importers of one home, and three process locals in one
// subroutine.  MEASUREMENT ONLY.
package spring195v;
  class Otter195v;
    extern function void slide195v();
  endclass
  function void Otter195v::slide195v();
    process s_a195v;
    process s_b195v;
    process s_c195v;
    string  s_s195v;
    s_s195v = "n";
    s_a195v = null;
  endfunction
  function void weir195v();
    process w_a195v;
    process w_b195v;
    string  w_s195v;
    w_s195v = "o";
  endfunction
endpackage
package brook195v;
  import spring195v::*;
  class Heron195v;
    function void wade195v();
      Otter195v h_h195v;
      h_h195v = null;
    endfunction
  endclass
endpackage
package river195v;
  import brook195v::*;          // CHAINED: brook's own clones re-cloned here
  class Kingfisher195v;
    function void dive195v();
      Heron195v k_h195v;
      k_h195v = null;
    endfunction
  endclass
endpackage
package delta195v;
  import spring195v::*;         // a THIRD importer of the same home
  class Egret195v;
    function void stalk195v();
      Otter195v e_h195v;
      e_h195v = null;
    endfunction
  endclass
endpackage
