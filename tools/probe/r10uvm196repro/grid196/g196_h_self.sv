// r10uvm196 arm H — SELF-CONTAINED (package, file-scope import and modules in
// ONE file), so the WIDE BOUNDARY GATE — which compiles each source ALONE —
// exercises this law and can act as its POSITIVE CONTROL.  A gate that reports
// this arm unmoved cannot see.
package anvilPkg;
  parameter int    ANVIL_MASS  = 88;
  parameter string ANVIL_NAME  = "anvil";
  localparam int   ANVIL_LOCAL = 3;
  int anvilLoose = 1;
  function automatic int anvilTake(input int a);
    return a + ANVIL_MASS;
  endfunction
endpackage
import anvilPkg::*;
module hSelf;
  parameter int H_OWN = 7;
  int r;
  initial r = anvilTake(1) + H_OWN;
endmodule
module hSelfTwo;
  int r;
  initial r = anvilTake(2);
endmodule
