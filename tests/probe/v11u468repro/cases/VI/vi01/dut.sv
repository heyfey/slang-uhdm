// § unitInclClassImports468
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
`define MKC(n) class n; int x; endclass
`MKC(c)
module top; c h; endmodule
