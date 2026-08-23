// a8 — CONTROL.  A group with exactly ONE declaration keeps its OWN argument:
// there is no base to clone from, so nothing may move.
package pk8box;
  class BoxS8 #(type Q = int, string Nm = "?"); int s8; endclass
endpackage
package pk8use;
  import pk8box::*;
  class solo8;
    typedef BoxS8 #(solo8,"solo8") sid8;
  endclass
endpackage
