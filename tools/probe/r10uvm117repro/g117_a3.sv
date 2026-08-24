// r10uvm117 arm a3 — THE OWNER GRID.  ONE free-package-function `ref_var`
// local, and FIVE candidate hoisting modules: two TOPS, a CHILD instantiated
// THREE times, a module that imports the package at BODY scope, and a module
// that imports nothing at all.  MEASUREMENT ONLY.
//
// The question: WHICH module (and how many) gets the implicit wire.  Surelog
// mints it ONCE per reference — `UhdmWriter::lateBinding`'s own first line is
// `if (ref->Actual_group()) continue;` and the ref objects are SHARED — so the
// FIRST module written that cannot bind the name owns the only wire
// (§ oobRefVarLocalHoistNet107's residue R-MULTI).
package pk117c;
  function automatic void ownerFn117c();
    process ownerAlpha;
    ownerAlpha = process::self();
  endfunction
  function automatic void ownerFn2117c();
    process ownerBeta;
    ownerBeta = process::self();
  endfunction

  // THE MULTIPLICITY CONTROL — § classPropRefs' OWN name family, which the
  // PRISTINE binary already hoists.  If the pristine binary mints `ctlProp117c`
  // in all three importing modules where golden mints it in ONE, the spread
  // belongs to the shared hoisted-net pool and this pass INHERITS it rather
  // than introducing it (§ oobRefVarLocalHoistNet107's residue R-MULTI).
  class ctl117c;
    int ctlProp117c;
    extern function void ctlFn117c();
  endclass
  function void ctl117c::ctlFn117c();
    ctlProp117c = 5;
  endfunction
endpackage

// FILE-SCOPE import: this is the spelling CompileModule.cpp:571-581 feeds to
// importPackage for every module in the file.
import pk117c::*;

module kid117c;
  ctl117c ck117c;
  initial begin
    ownerFn117c();
    ck117c = new();
    ck117c.ctlFn117c();
  end
endmodule

module topA117c;
  kid117c k1();
  kid117c k2();
  kid117c k3();
  ctl117c ca117c;
  initial begin
    ownerFn117c();
    ca117c = new();
    ca117c.ctlFn117c();
  end
endmodule

module topB117c;
  ctl117c cb117c;
  initial begin
    ownerFn2117c();
    cb117c = new();
    cb117c.ctlFn117c();
  end
endmodule
