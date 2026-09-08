// The same collision with the imports written in the OTHER order.
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

import pg206::*;
import pf206::*;

module yb206;
  zg206 h;
  initial h = null;
endmodule
