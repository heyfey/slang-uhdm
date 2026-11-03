// § unitImpRootFileDef477
package p;
  parameter int W = 4;
  int pv = 3;
  function automatic int pf(int a); return a + 1; endfunction
endpackage
import p::*;
`include "inc.svh"
module top;
  logic c;
  ifc i(c);
endmodule
