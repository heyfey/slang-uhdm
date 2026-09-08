// TWO packages, each with a class whose representative is a CLASS-SCOPE
// typedef, imported at file scope in ANTI-ALPHABETICAL declaration order.
package pz206;
  class kz206;
    typedef kz206 this_type;
    int z;
  endclass
endpackage

package pa2206;
  class ka2206;
    typedef ka2206 this_type;
    int a;
  endclass
endpackage

import pz206::*;
import pa2206::*;

module wd206;
  kz206 h0;
  ka2206 h1;
endmodule
