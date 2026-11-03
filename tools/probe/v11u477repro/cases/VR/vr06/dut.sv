// § unitImpRootFileDef477
package p;
  parameter int W = 4;
  function automatic int pf(int a); return a + 1; endfunction
endpackage
package q;
  parameter int V = 2;
endpackage
import p::*;
`include "inc.svh"
module top;
  m u();
endmodule
