// v98_c14 — THREE instances of the same top-shaped module (1..3 instances).
package p14v;
  class a14win98v; typedef bit [2:0] in14_t; endclass
  class m14base98v; typedef int in14_t; function void own(in14_t x); endfunction endclass
  class z14der98v extends m14base98v; function void hot(in14_t x); endfunction endclass
endpackage
module leaf14v;
  import p14v::*;
  z14der98v z;
  initial z = new();
endmodule
module top14v;
  leaf14v i1(); leaf14v i2(); leaf14v i3();
endmodule
