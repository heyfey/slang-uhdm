// THE DROP PATH, UNMASKED.  One package contributes TWO class keys:
//   * `cb206` — whose representative is the package's OWN top-level typedef
//     `zb206`, already published at key `zb206`; the class key sorts EARLIER,
//     so the merge tries to MOVE it -- but `cb206` is taken by pc206's typedef.
//   * `kb206` — whose representative is a CLASS-SCOPE typedef, a FRESH key that
//     succeeds and so makes the pass republish.
// Pristine lists the class_typespec at `zb206`.  Does it survive the merge?
package pb206;
  class cb206;
    int n;
  endclass
  typedef cb206 zb206;
  class kb206;
    typedef kb206 this_type;
    int m;
  endclass
endpackage

package pc206;
  typedef logic [7:0] cb206;
endpackage

import pb206::*;
import pc206::*;

module xa206;
  zb206 h;
  kb206 g;
  initial h = null;
endmodule
