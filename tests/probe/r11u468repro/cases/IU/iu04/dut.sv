// § unitInclClassImports468
// two classes in the included file, one extending the other, a typedef in the package
package p;
  parameter int P = 3;
  typedef logic [3:0] nib_t;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
`include "c.sv"
module top; d h; endmodule
