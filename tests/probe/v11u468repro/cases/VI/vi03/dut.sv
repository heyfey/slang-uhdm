// § unitInclClassImports468
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
  function int f(); return 1; endfunction
endpackage
`include "m.svh"
import p::*;
`MKC(c)
module top; c h; endmodule
