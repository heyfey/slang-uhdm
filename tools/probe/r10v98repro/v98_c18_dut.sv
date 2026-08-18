// v98_c18 — the racing NAME is also a CLASS name in the design (the
// getClassDefinition fallbacks in compileDatastructureTypespec).
package p18v;
  class cn18_t; int f; endclass                 // a CLASS called cn18_t
  class a18win98v; typedef bit [3:0] cn18_t; endclass
  class m18base98v; typedef int cn18_t; function void own(cn18_t x); endfunction endclass
  class z18der98v extends m18base98v; function void hot(cn18_t x); endfunction endclass
endpackage
module top18v;
  import p18v::*;
  z18der98v z;
  initial z = new();
endmodule
