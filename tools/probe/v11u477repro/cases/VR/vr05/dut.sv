// § unitImpRootFileDef477
package p;
  parameter int W = 4;
  function automatic int pf(int a); return a + 1; endfunction
endpackage
import p::W;
`include "inc.svh"
module top;
  m u();
endmodule
