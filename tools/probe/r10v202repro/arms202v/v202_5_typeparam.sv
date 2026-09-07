// r10v202 arm 5 — THE PACKAGE-SCOPE `parameter type` BOUND TO A CLASS, ISOLATED.
// No chained typedef (Surelog rejects those with CP0317 and the arm-1 golden
// carried two ERRORs); this arm's golden must build CLEAN so the cell it
// decides cannot be blamed on a broken database.
//
// In slang a `parameter type` is a TypeParameterSymbol whose targetType is a
// TypeAliasType, and that alias's PARENT SCOPE is the PACKAGE — so both of
// `pkgClassTdLocalName202`'s clauses (TypeAlias + parent scope Package +
// canonical ClassType) are TRUE for a local declared with it.  The question is
// whether golden degrades it like a typedef, or RESOLVES it.
package quarryV5202;
  class PlainV5202;
    int aV5;
  endclass

  typedef PlainV5202 clsTdV5202;         // the LAW's own construct — must FIRE
  parameter type tparV5202 = PlainV5202; // the QUESTION

  class AditV5202;
    extern function void winzeV5202();
  endclass

  function void AditV5202::winzeV5202();
    clsTdV5202 tfTdV5;
    tparV5202  tfTparV5;
    begin
      clsTdV5202 blkTdV5;
      tparV5202  blkTparV5;
      blkTdV5   = null;
      blkTparV5 = null;
    end
    tfTdV5   = null;
    tfTparV5 = null;
  endfunction
endpackage

package sluiceV5202;
  import quarryV5202::*;
  class FlumeV5202;
    function void raceV5202();
      AditV5202 gateV5;
      gateV5 = null;
    endfunction
  endclass
endpackage
