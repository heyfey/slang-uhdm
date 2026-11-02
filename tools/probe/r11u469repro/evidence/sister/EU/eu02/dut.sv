// § classInheritsContainerImports23
// control: the same class in the importing file itself, STRICT_EQUAL on pristine
package p;
  parameter int P = 3;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
class c;
  int x;
endclass
module top; c h; endmodule
