// KEY COLLISION 2 — THE DROP PATH.  Package pb206's class `cb206` is
// represented by pb206's own top-level typedef `zb206` (key `zb206`), which the
// import publishes.  The class key `cb206` sorts BEFORE `zb206`, so the merge
// wants to MOVE the object to `cb206` — but `cb206` is already taken by package
// pc206's typedef of the same name.  Does the object survive?
package pb206;
  class cb206;
    int n;
  endclass
  typedef cb206 zb206;
endpackage

package pc206;
  typedef logic [7:0] cb206;
endpackage

import pb206::*;
import pc206::*;

module wb206;
  zb206 h;
  initial h = null;
endmodule
