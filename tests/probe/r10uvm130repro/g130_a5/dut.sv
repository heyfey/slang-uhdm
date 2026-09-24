// r10uvm130repro/g130_a5.sv — THE NO-IMPORT NEGATIVE CONTROL.  MEASUREMENT ONLY.
// The SAME body as g130_a4's, but NO module imports the package at file scope:
// one imports it INSIDE its body, one names the class through its package scope
// and imports nothing.  A module that does not hoist the package must carry NO
// wire, and § newArrayArgNoBind16's original answer (bare, no actual) must stand.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package p130e;
  class kls130e;
    int dynE130e[];
    extern function void noHoistFn130e();
  endclass
  function void kls130e::noHoistFn130e();
    int noHoistAlpha130e;
    noHoistAlpha130e = 3;
    dynE130e = new[noHoistAlpha130e];
  endfunction
endpackage

module bodyImp130e;
  import p130e::*;
  initial begin
    kls130e k130e;
    k130e = new();
    k130e.noHoistFn130e();
  end
endmodule

module scopedOnly130e;
  initial begin
    p130e::kls130e k2130e;
    k2130e = new();
    k2130e.noHoistFn130e();
  end
endmodule

module bystander130e;
  initial $display("no package here");
endmodule
