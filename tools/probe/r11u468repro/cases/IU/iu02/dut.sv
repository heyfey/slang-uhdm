// § unitInclClassImports468
// the include written before the file-scope import
package p;
  parameter int P = 3;
  int v;
  function int f(); return 1; endfunction
endpackage
`include "c.sv"
import p::*;
module top; c h; endmodule
