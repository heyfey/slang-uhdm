// x206_a with the two imports written in the OTHER order: pc206 (whose typedef
// takes the key `cb206`) is imported FIRST, so Surelog's first-writer-wins
// DataTypeMap gives `cb206` to the TYPEDEF and pb206's class object can only be
// reached through its own typedef key `zb206`.
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

import pc206::*;
import pb206::*;

module za206;
  zb206 h;
  kb206 g;
  initial h = null;
endmodule
