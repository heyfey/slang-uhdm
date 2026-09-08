// The same DROP PATH with the colliding key coming from the $unit's OWN
// typedef rather than a second package.
package pd206;
  class cd206;
    int n;
  endclass
  typedef cd206 zd206;
  class kd206;
    typedef kd206 this_type;
    int m;
  endclass
endpackage

import pd206::*;

typedef logic [7:0] cd206_hold;

module xb206;
  zd206 h;
  kd206 g;
  cd206_hold w;
  initial w = 0;
endmodule
