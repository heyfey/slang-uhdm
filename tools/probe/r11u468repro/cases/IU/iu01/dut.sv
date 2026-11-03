// § unitInclClassImports468
// a $unit class in an included file, the file-scope import written before the include
package p;
  parameter int P = 3;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
`include "c.sv"
module top; c h; endmodule
