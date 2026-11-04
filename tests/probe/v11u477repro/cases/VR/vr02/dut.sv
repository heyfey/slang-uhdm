// § unitImpRootFileDef477
package p;
  parameter int W = 4;
  function automatic int pf(int a); return a + 1; endfunction
endpackage
`include "imp.svh"
module top;
  m u();
endmodule
module m;
  logic [W-1:0] x;
  initial x = pf(1);
endmodule
