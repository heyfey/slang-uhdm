// r10v198 arm 1 — SHADOWING.  A class-scope typedef whose NAME is also a
// PACKAGE-scope typedef in the same package.  slang binds the bare name to the
// CLASS one (correct shadowing); Surelog's compileVariable looks the name up in
// the PACKAGE's data-type map, which HAS an entry, so the home body may never
// degrade at all — in which case the clone copy is resolved in golden and this
// law must NOT fire.  Controls of the same kinds sit in the same body.
package quarryV1;
  typedef struct { int lodeV1; string seamV1; } shadeStV1;  // PACKAGE-scope
  typedef int shadeIntV1;                                   // PACKAGE-scope
  typedef struct { int soleV1; } onlyPkgStV1;               // CONTROL: no class twin
  class AditV1;
    typedef struct { int shaftV1; string driftV1; } shadeStV1;  // CLASS shadow
    typedef int shadeIntV1;                                     // CLASS shadow
    typedef struct { int cribV1; } onlyClsStV1;                 // no package twin
    extern function void winzeV1(int collarV1);
  endclass
  function void AditV1::winzeV1(int collarV1);
    shadeStV1   tfShadeV1;      // SHADOWED name, class struct
    shadeIntV1  tfShadeIntV1;   // SHADOWED name, class int
    onlyClsStV1 tfOnlyClsV1;    // unshadowed class struct  (the law's cell)
    onlyPkgStV1 tfOnlyPkgV1;    // CONTROL: package struct
    begin
      shadeStV1   blkShadeV1;
      shadeIntV1  blkShadeIntV1;
      onlyClsStV1 blkOnlyClsV1;
      onlyPkgStV1 blkOnlyPkgV1;
      blkShadeV1.shaftV1 = collarV1;
      blkShadeIntV1 = 0;
      blkOnlyClsV1.cribV1 = 0;
      blkOnlyPkgV1.soleV1 = 0;
    end
    tfShadeV1.shaftV1 = 0;
    tfShadeIntV1 = 0;
    tfOnlyClsV1.cribV1 = 0;
    tfOnlyPkgV1.soleV1 = 0;
  endfunction
endpackage
package sluiceV1;
  import quarryV1::*;
  class FlumeV1;
    function void raceV1();
      AditV1 gateV1;
      gateV1 = null;
    endfunction
  endclass
endpackage
