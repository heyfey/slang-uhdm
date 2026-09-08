// A file-scope import of a package that ITSELF imports another package: do the
// TRANSITIVELY visible classes ride into the design's listing?
package pd206;
  class ff206;
    int z;
  endclass
  typedef ff206 ff206_t;
endpackage

package pc206;
  import pd206::*;
  class hh206;
    int w;
  endclass
  typedef hh206 hh206_t;
endpackage

import pc206::*;

module tc206;
  hh206 a;
  initial a = new();
endmodule
