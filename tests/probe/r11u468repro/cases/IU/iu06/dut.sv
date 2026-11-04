// § unitInclClassImports468
// a module in the included file declaring a class
package p;
  parameter int P = 3;
  int v;
  function int f(); return 1; endfunction
endpackage
import p::*;
`include "m.sv"
module top; m u(); endmodule
