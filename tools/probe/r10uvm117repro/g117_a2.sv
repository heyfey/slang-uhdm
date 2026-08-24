// r10uvm117 arm a2 — THE HOME GRID.  ONE declaration shape (a builtin-class
// body local, which both producers degrade to `ref_var`) and ONE reference
// position (an ordinary assignment LVALUE — the head's own), written in SIX
// different HOMES.  MEASUREMENT ONLY.  Every cell has its own name.
//
// The question the arm answers: is Surelog's implicit-wire mint a CLASS
// mechanism (§ oobRefVarLocalHoistNet107's gate) or a SUBROUTINE-BODY one?
package pk117b;

  class cls117b;
    process ibProp;
    extern function void oobFn117b();
    // an IN-BODY class method — the CONTROL: § 115 keeps `class_var` here, so
    // the declaration is not a `ref_var` and no wire can follow.
    function void inBodyFn117b();
      process homeInBodyDelta;
      homeInBodyDelta = process::self();
    endfunction
  endclass

  // an OUT-OF-BODY class method — § 107's own home, ours since r10uvm107.
  function void cls117b::oobFn117b();
    process homeOobGamma;
    homeOobGamma = process::self();
  endfunction

  // a FREE PACKAGE FUNCTION — the family.
  function automatic void homeFreeFn117b();
    process homeFreeFnAlpha;
    homeFreeFnAlpha = process::self();
  endfunction

  // a FREE PACKAGE TASK — the family's other half.
  task automatic homeFreeTask117b();
    process homeFreeTaskBeta;
    homeFreeTaskBeta = process::self();
  endtask

endpackage

// a $unit (compilation-unit) FUNCTION — no package at all.
function automatic void homeUnitFn117b();
  process homeUnitFnZeta;
  homeUnitFnZeta = process::self();
endfunction

import pk117b::*;
module top117b;
  // a MODULE's OWN function — the module is its own late-binding owner.
  function automatic void homeModFn117b();
    process homeModFnEpsilon;
    homeModFnEpsilon = process::self();
  endfunction
  cls117b h117b;
  initial begin
    homeFreeFn117b();
    homeFreeTask117b();
    h117b = new();
    h117b.oobFn117b();
    h117b.inBodyFn117b();
    homeModFn117b();
    homeUnitFn117b();
  end
endmodule
