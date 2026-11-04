// § classInheritsContainerImports23
// sister-ground face (ModuleEmit): the class lives in an included file; golden lists the $unit import copies in it, ours none
package p;
  parameter int P = 3;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
`include "c.sv"
module top; c h; endmodule
