// § unitImpRootFileDef477
package p;
  parameter int W = 4;
  function automatic int pf(int a); return a + 1; endfunction
endpackage
`include "inc.svh"
import p::*;
module top;
  m u();
endmodule
