// § unitInclClassImports468
// the included class in a package body: the package's own body imports only
package p;
  parameter int P = 3;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
package q;
`include "c.sv"
endpackage
module top; q::c h; endmodule
