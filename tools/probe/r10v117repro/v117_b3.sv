// r10v117 (verifier) arm b3 — THE RESOLUTION CONTROLS and THE DECLARATION
// ORDER r10uvm117's fourth edit (the mint-order staging) never measured.
// MEASUREMENT ONLY.
//
// r10uvm117 staged every FREE PACKAGE SUBROUTINE pool entry and appends it
// AFTER the package's classes, because both boundary arms it repaired
// (r10uvm77repro/v77x4_scope.sv, r10buvm9repro/w1v_pkgclsts.sv) declare the
// CLASS BEFORE the free subroutine.  The OPPOSITE source order -- a free
// subroutine written BEFORE the class that shares the name -- is what
// `PkgFnFirst` measures: Surelog's pool is SOURCE order, so golden should span
// the wire at the FREE FUNCTION's line, and the staging hands it the CLASS's.
//
// It also asks what happens when the hoisted name ALSO exists as a module net,
// as a package variable, as a class property, and as a module parameter.

// ---------------------------------------------------- free subroutine FIRST
package PkgFnFirst;
  function automatic void earlyFreeFnV3();
    process sharedOrderName;      // line 20 -- the FREE FUNCTION's span
    sharedOrderName = process::self();
  endfunction
  class LateClsV3;
    extern function void lateOobV3();
  endclass
  function void LateClsV3::lateOobV3();
    process sharedOrderName;      // line 27 -- the CLASS's span
    sharedOrderName = process::self();
  endfunction
endpackage

// ---------------------------------------------------------- class FIRST
package PkgClsFirst;
  class EarlyClsV3;
    extern function void earlyOobV3();
  endclass
  function void EarlyClsV3::earlyOobV3();
    process reverseOrderName;     // the CLASS's span (earlier line)
    reverseOrderName = process::self();
  endfunction
  function automatic void lateFreeFnV3();
    process reverseOrderName;     // the FREE FUNCTION's span (later line)
    reverseOrderName = process::self();
  endfunction
endpackage

// ------------------------------------------- the same name in TWO free subs
package PkgTwinName;
  function automatic void twinFnOneV3();
    process twinNameT8;           // FIRST in source
    twinNameT8 = process::self();
  endfunction
  task automatic twinTaskTwoV3();
    process twinNameT8;           // SECOND in source
    twinNameT8 = process::self();
  endtask
endpackage

// ------------------------------------------------------- the shadow controls
package PkgShadow;
  process pkgVarShadowC1;         // a PACKAGE VARIABLE of the same name
  class ShadowClsV3;
    process clsPropShadowC2;      // a CLASS PROPERTY of the same name
  endclass
  function automatic void shadowFnV3();
    process modNetShadowC3;       // also a MODULE NET name below
    process paramShadowC4;        // also a MODULE PARAMETER name below
    process clsPropShadowC2;      // shadows the class property (unrelated scope)
    pkgVarShadowC1 = process::self();   // resolves to the PACKAGE VARIABLE
    modNetShadowC3 = process::self();
    paramShadowC4  = process::self();
    clsPropShadowC2 = process::self();
  endfunction
endpackage

import PkgFnFirst::*;
import PkgClsFirst::*;
import PkgTwinName::*;
import PkgShadow::*;
module TopBeeThree;
  parameter int paramShadowC4 = 7;
  wire modNetShadowC3;
  LateClsV3  h3a;
  EarlyClsV3 h3b;
  initial begin
    earlyFreeFnV3();
    h3a = new(); h3a.lateOobV3();
    h3b = new(); h3b.earlyOobV3();
    lateFreeFnV3();
    twinFnOneV3();
    twinTaskTwoV3();
    shadowFnV3();
  end
endmodule
