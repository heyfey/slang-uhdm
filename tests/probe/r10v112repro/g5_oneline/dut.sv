// g5 — TWO members whose whole declarations sit on ONE SOURCE LINE, so the
// two typedefs share a line and differ only in column.
package p5box;
  class B5 #(type Q = int, string Nm = "?"); int x5; endclass
endpackage
package p5use;
  import p5box::*;
  class za5; typedef B5 #(za5,"za5") t5; endclass  class Ab5; typedef B5 #(Ab5,"Ab5") t5; endclass
endpackage
