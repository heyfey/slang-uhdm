// v98_c5 — SHADOWING: the derived class re-declares the name.  The reference
// must stay on the derived class's OWN typedef (reach == true).
package p5v;
  class a5win98v;
    typedef bit [2:0] sh5_t;
  endclass
  class m5base98v;
    typedef int sh5_t;
    function void own(sh5_t x); endfunction
  endclass
  class z5der98v extends m5base98v;
    typedef string sh5_t;                  // SHADOWS the base
    function void hot(sh5_t x); endfunction
  endclass
  class z6der98v extends m5base98v;        // no shadow: must MOVE
    function void hot2(sh5_t x); endfunction
  endclass
endpackage
module top5v;
  import p5v::*;
  z5der98v a; z6der98v b;
  initial begin a = new(); b = new(); end
endmodule
