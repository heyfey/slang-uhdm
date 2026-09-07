// r10uvm199 grid arm E — a RE-EXPORTED untyped unsized-based parameter:
// `eOuter` wildcard-imports `eInner`, the module wildcard-imports `eOuter`, so
// the module's copy carries `vpiImported=eOuter` while the parameter itself is
// declared in `eInner`.  The tag must not move.
package eInner;
  parameter E_IN = 'hbeef;
endpackage
package eOuter;
  import eInner::*;
  parameter E_OUT = 'hcafe;
endpackage
module eMod;
  import eOuter::*;
  initial $display(E_OUT);
endmodule
