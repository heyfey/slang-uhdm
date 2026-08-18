// v98_c16 — the same law in a .v file.
package p16v;
  class a16win98v; typedef bit [1:0] vv16_t; endclass
  class m16base98v; typedef int vv16_t; function void own(vv16_t x); endfunction endclass
  class z16der98v extends m16base98v; function void hot(vv16_t x); endfunction endclass
endpackage
module top16v;
  p16v::z16der98v z;
  initial z = new();
endmodule
