// a9 — RISK ARM.  Two class-scope typedefs of ONE foreign generic with
// DIFFERENT TYPEDEF NAMES and different arguments.  The group key is the
// TARGET generic class, not the typedef name, so these should still form one
// group; if golden does NOT clone them, overwriting would move a cell AWAY.
package pk9box;
  class BoxN9 #(type Q = int, string Nm = "?"); int n9; endclass
endpackage
package pk9use;
  import pk9box::*;
  class Kb9;
    typedef BoxN9 #(Kb9,"Kb9") first_id9;
  endclass
  class ra9;
    typedef BoxN9 #(ra9,"ra9") second_id9;
  endclass
endpackage
