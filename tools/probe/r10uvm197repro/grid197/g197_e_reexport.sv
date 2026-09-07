// r10uvm197 grid arm E — a RE-EXPORTED typed string parameter: eOuter wildcard-
// imports eInner, and the module wildcard-imports eOuter, so the module's copy
// carries vpiImported=eOuter while the string itself is declared in eInner.
package eInner;
  parameter string E_IN = "innerstring";
endpackage
package eOuter;
  import eInner::*;
  parameter string E_OUT = "outerstring";
endpackage
module eMod;
  import eOuter::*;
  initial $display(E_OUT);
endmodule
