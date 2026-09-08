// KEY COLLISION 1 — the $unit's OWN typedef takes the name an imported class's
// key wants.  The class's representative is a CLASS-SCOPE typedef, so the class
// key `ka206` is the only key that could hold it.
package pa206;
  class ka206;
    typedef ka206 this_type;
    int n;
  endclass
  typedef logic [3:0] ta206_plain;
endpackage

import pa206::*;

typedef logic [7:0] ka206_t;

module wa206;
  ka206 h;
  ta206_plain w;
  ka206_t z;
  initial z = 0;
endmodule
