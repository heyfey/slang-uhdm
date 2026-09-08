// § importedClassTsRideTheFileUnit206 — KEY COLLISION between the $unit's OWN
// typedef and an imported class's bare name.  The class's representative
// typespec is the package typedef `zz206` (sorts AFTER `cc206`), so the class
// key `cc206` is the alphabetically-first key for that object -- but `cc206` is
// already taken by the unit's own typedef.
package pa206;
  class cc206;
    int x;
  endclass
  typedef cc206 zz206;
endpackage

import pa206::*;

typedef int cc206;

module ta206;
  cc206 v;
  zz206 h;
  initial v = 0;
endmodule
