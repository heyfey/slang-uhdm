// § unitInclClassImports468
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
  function int f(); return 1; endfunction
endpackage
package q;
  parameter int Q = 7;
endpackage
import p::*;
import q::Q;
`include "c.svh"
module top; c h; endmodule
