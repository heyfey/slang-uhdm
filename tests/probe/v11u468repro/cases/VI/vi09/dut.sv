// § unitInclClassImports468
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
module top;
`include "c.svh"
  c h;
endmodule
