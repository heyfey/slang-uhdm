// § unitImpRootFileDef477
package p;
  parameter int W = 4;
  function automatic int pf(int a); return a + 1; endfunction
endpackage
`define INC "inc.svh"
import p::*;
`include `INC
module top;
  m u();
endmodule
