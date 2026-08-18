// v98_c9 — HOMES of the DECLARING class: $unit, module-nested, class-nested.
typedef int unit_marker_t;
class u9win98v;                        // $unit home, key "work@u9win98v"
  typedef bit [8:0] hm9_t;
endclass
package p9v;
  class outer9v;
    class inner9v;                     // nested: key is the SHORT name
      typedef bit [7:0] hm9_t;
    endclass
    typedef int hm9_t;
  endclass
  class m9base98v; typedef int hm9_t; function void own(hm9_t x); endfunction endclass
  class z9der98v extends m9base98v; function void hot(hm9_t x); endfunction endclass
endpackage
module mod9v;
  class mc9v; typedef bit [5:0] hm9_t; endclass
  mc9v h;
  initial h = new();
endmodule
module top9v;
  import p9v::*;
  mod9v u_m();
  z9der98v z;
  u9win98v u;
  initial begin z = new(); u = new(); end
endmodule
