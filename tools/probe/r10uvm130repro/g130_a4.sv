// r10uvm130repro/g130_a4.sv — THE OWNER / MULTIPLICITY GRID, and the HOISTING-
// SHAPE NEGATIVE CONTROL.  MEASUREMENT ONLY.
// THREE top modules: two that import the package at FILE scope and one that
// imports NOTHING and names the class through its package scope.  Surelog's
// `lateBinding` starts `if (ref->Actual_group()) continue;` and the ref objects
// are SHARED, so the FIRST module written that cannot bind the name owns the
// ONLY wire (uvm117 residue R-MULTI).
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
package p130d;
  class kls130d;
    int dynD130d[];
    extern function void ownerFn130d();
  endclass
  function void kls130d::ownerFn130d();
    int ownerAlpha130d;
    ownerAlpha130d = 3;
    dynD130d = new[ownerAlpha130d];
  endfunction
endpackage

import p130d::*;

module kid130d;
  initial begin
    kls130d k130d;
    k130d = new();
    k130d.ownerFn130d();
  end
endmodule

module topA130d;
  kid130d ka130d();
endmodule

module topB130d;
  kid130d kb130d();
endmodule
