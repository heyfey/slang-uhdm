// § unitImpRootFileDef477
package p;
  parameter int W = 4;
  function automatic int pf(int a); return a + 1; endfunction
endpackage
import p::*;
module top;
  `include "body.svh"
endmodule
