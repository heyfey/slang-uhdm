// TWO file-scope imports of TWO packages that each declare a class with the
// SAME bare name: one key, two candidate objects.
package pf206;
  class gg206;
    int a;
  endclass
  typedef gg206 f206_t;
endpackage

package pg206;
  class gg206;
    int b;
  endclass
  typedef gg206 g206_t;
endpackage

import pf206::*;
import pg206::*;

module te206;
  f206_t x;
  g206_t y;
  initial x = null;
endmodule
