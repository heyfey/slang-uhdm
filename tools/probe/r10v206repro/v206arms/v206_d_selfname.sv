// The class representative NAMED AFTER ITS CLASS, listed in the package's own
// listing: the vpiInstance stamp is the question (writePackage restamps
// unconditionally and runs AFTER the design's union).
package pe206;
  class ee206;
    int q;
  endclass
  typedef ee206 ee206_t;
  typedef ee206 aa206_t;
endpackage

import pe206::*;

module td206;
  ee206 h;
  ee206_t g;
  aa206_t k;
  initial h = new();
endmodule
