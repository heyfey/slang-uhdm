// § unitImpRootFileDef477
`include "inc.svh"
module top;
  m u();
endmodule
package p;
  parameter int W = 4;
  function automatic int pf(int a); return a + 1; endfunction
endpackage
import p::*;
