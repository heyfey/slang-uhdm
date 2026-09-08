// r10uvm206 grid arm E — TWO file-scope imports.  Both packages' class keys
// join the SAME unit group, and the merged listing is one alphabetical run
// over typedef names and class names together.
package pe206_a;
  class ce206_a;
    typedef ce206_a this_type;
    int a;
  endclass
  typedef int te206_a;
endpackage
package pe206_b;
  class ce206_b;
    typedef ce206_b this_type;
    int b;
  endclass
  typedef byte te206_b;
endpackage

import pe206_a::*;
import pe206_b::*;

module ge206;
  ce206_a h0;
  ce206_b h1;
  te206_a w0;
  te206_b w1;
endmodule
