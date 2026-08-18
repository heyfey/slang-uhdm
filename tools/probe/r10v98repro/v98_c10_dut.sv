// v98_c10 — a PACKAGE-level and a $unit-level typedef of the racing name, and
// the reference reached WITHOUT any wildcard import (fully qualified handles).
typedef byte pw10_t;
package apk10v;
  typedef shortint pw10_t;
endpackage
package p10v;
  class m10base98v; typedef int pw10_t; function void own(pw10_t x); endfunction endclass
  class z10der98v extends m10base98v; function void hot(pw10_t x); endfunction endclass
endpackage
module top10v;
  p10v::z10der98v z;
  initial z = new();
endmodule
