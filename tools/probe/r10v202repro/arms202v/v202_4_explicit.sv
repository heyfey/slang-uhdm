// r10v202 arm 4 — THE EXPLICIT-ITEM IMPORT CLONE (§ impCloneDeclRangeNoBind200's
// own construct) beside the WILDCARD one, plus MODULE / INTERFACE / PROGRAM
// importers, plus RANGED declarations in the same cloned body.  The verifier's
// questions:
//   * does the law reach an EXPLICIT-item import clone (the § 200 fence's
//     window) and, if so, does golden agree there?
//   * do § 200's ranged own-declarations still read as § 200 left them when a
//     § 202 cell sits in the same body?
//   * do the non-package importers stay put (they SHARE the home subroutine)?
package quarryV4202;
  class PlainV4202;
    int aV4;
  endclass
  typedef PlainV4202  clsV4202;      // PACKAGE-scope typedef of a class
  typedef logic [7:0] vecV4202;      // CONTROL — a plain package typedef
  parameter int WV4202 = 4;

  class AditV4202;
    extern function void winzeV4202();
  endclass

  function void AditV4202::winzeV4202();
    clsV4202          tfClsV4;
    vecV4202          tfVecV4;                 // CONTROL
    logic [WV4202-1:0] tfRngV4;                // § 200's ranged own-declaration
    begin
      clsV4202           blkClsV4;
      vecV4202           blkVecV4;             // CONTROL
      logic [WV4202-1:0] blkRngV4;             // § 200's ranged own-declaration
      blkClsV4 = null;
      blkVecV4 = 8'h0;
      blkRngV4 = '0;
    end
    tfClsV4 = null;
    tfVecV4 = 8'h0;
    tfRngV4 = '0;
  endfunction
endpackage

package expV4202;                              // EXPLICIT-ITEM importer
  import quarryV4202::AditV4202;
  import quarryV4202::clsV4202;
  class UexpV4202;
    function void fV4();
      AditV4202 gExpV4;
      gExpV4 = null;
    endfunction
  endclass
endpackage

package wildV4202;                             // WILDCARD importer (the law's own)
  import quarryV4202::*;
  class UwildV4202;
    function void fV4();
      AditV4202 gWildV4;
      gWildV4 = null;
    endfunction
  endclass
endpackage

module modV4202;                               // MODULE importer — must not move
  import quarryV4202::*;
  AditV4202 gModV4;
  initial gModV4 = null;
endmodule

interface ifcV4202;                            // INTERFACE importer — must not move
  import quarryV4202::*;
  AditV4202 gIfcV4;
endinterface

program progV4202;                             // PROGRAM importer — must not move
  import quarryV4202::*;
  AditV4202 gPrgV4;
  initial gPrgV4 = null;
endprogram
