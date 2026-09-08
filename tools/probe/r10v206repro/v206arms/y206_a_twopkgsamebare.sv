// TWO packages whose classes share a BARE NAME, both file-scope imported.
// pf206's `gg206` is represented by a CLASS-SCOPE typedef, so its class key
// `gg206` is FRESH and succeeds.  pg206's `gg206` is represented by pg206's own
// top-level typedef `zg206`, already published at key `zg206`; its class key
// `gg206` sorts EARLIER but is now taken.  Does pg206's object survive?
package pf206;
  class gg206;
    typedef gg206 this_type;
    int a;
  endclass
endpackage

package pg206;
  class gg206;
    int b;
  endclass
  typedef gg206 zg206;
endpackage

import pf206::*;
import pg206::*;

module ya206;
  zg206 h;
  initial h = null;
endmodule
