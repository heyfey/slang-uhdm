// § unitHoistBindsSysCallRhs462
package p;
  parameter int D = 16;
  parameter int W = $clog2(D);
  function int f(); return W + 1; endfunction
endpackage
import p::*;
module top;
  logic [W-1:0] x;
  initial x = W;
endmodule
