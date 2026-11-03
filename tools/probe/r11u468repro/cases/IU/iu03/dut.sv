// § unitInclClassImports468
// a nested include: the class two include levels down
package p;
  parameter int P = 3;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
`include "a.sv"
module top; c h; endmodule
