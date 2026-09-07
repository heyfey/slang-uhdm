// r10v198 arm 5 — THE OTHER CLONE PATHS AND THE MUST-NOT-MOVE CONTROLS.
//   * an EXPLICIT `import p::f` of a package FREE subroutine (the other two
//     `importCopyTsInst` drivers in ParamEmit.cpp), whose body writes a
//     class-scope typedef by its SCOPED spelling;
//   * an importing package that ALSO declares its OWN class with an
//     out-of-body method — that method is NOT a clone and every cell of it
//     must stay RESOLVED in every view;
//   * a MODULE that wildcard-imports the same package (no clone at all);
//   * the HOME package's own def/elab listing of the same method.
package quarryV5;
  typedef struct { int pqAV5; } pkgStV5;
  class AditV5;
    typedef struct { int shaftV5; string driftV5; } clsStV5;
    typedef int clsIntV5;
    extern function void winzeV5();
  endclass
  function void AditV5::winzeV5();
    clsStV5  tfClsV5;
    pkgStV5  tfPkgV5;
    begin
      clsStV5 blkClsV5;
      blkClsV5.shaftV5 = 0;
    end
    tfClsV5.shaftV5 = 0;
    tfPkgV5.pqAV5 = 0;
  endfunction
  function automatic int freeV5(int aV5);
    AditV5::clsStV5 scopedV5;   // SCOPED spelling of a class typedef
    pkgStV5         plainV5;
    begin
      AditV5::clsStV5 blkScopedV5;
      blkScopedV5.shaftV5 = aV5;
    end
    scopedV5.shaftV5 = aV5;
    plainV5.pqAV5 = aV5;
    return aV5;
  endfunction
endpackage
package sluiceV5;                    // EXPLICIT import of the free subroutine
  import quarryV5::freeV5;
  typedef struct { int slAV5; } ownPkgStV5;
  class OwnV5;                       // this package's OWN class — NEVER a clone
    typedef struct { int ownAV5; string ownBV5; } ownStV5;
    extern function void ownMethodV5();
  endclass
  function void OwnV5::ownMethodV5();
    ownStV5    tfOwnV5;              // MUST STAY RESOLVED in every view
    ownPkgStV5 tfOwnPkgV5;
    begin
      ownStV5 blkOwnV5;
      blkOwnV5.ownAV5 = 0;
    end
    tfOwnV5.ownAV5 = 0;
    tfOwnPkgV5.slAV5 = 0;
  endfunction
  function int useV5();
    return freeV5(1);
  endfunction
endpackage
package raceV5;                      // WILDCARD import — the law's own path
  import quarryV5::*;
  class FlumeV5;
    function void goV5();
      AditV5 gV5;
      gV5 = null;
    endfunction
  endclass
endpackage
module topV5;
  import quarryV5::*;                // a MODULE importer clones nothing
  AditV5 mV5;
  initial begin
    AditV5::clsStV5 mBlkV5;
    mBlkV5.shaftV5 = 0;
    mV5 = null;
  end
endmodule
