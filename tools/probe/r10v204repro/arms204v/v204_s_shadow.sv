// r10v204 arm S — NESTING and SHADOWING inside a clone body: for-in-for with a
// redeclared name, sibling for loops sharing a name, foreach inside for, for
// inside foreach.  All inside a NESTED begin block (the minting case).
package quarrysv204;
  class Leafsv204;
    int oresv204;
    function void assaysv204(int v204);
    endfunction
  endclass
  class Itersv204;
    function Leafsv204 firstsv204();
      return null;
    endfunction
    function Leafsv204 nextsv204();
      return null;
    endfunction
  endclass
  class Aditsv204;
    int sinksv204;
    int arrsv204[4];
    extern function void shaftsv204(int selsv204);
  endclass

  function void Aditsv204::shaftsv204(int selsv204);
    Itersv204 itsv204;
    itsv204 = new();
    if (selsv204 == 1) begin
      // S1 nested for redeclaring the OUTER loop's name.
      for (Leafsv204 cSv204 = itsv204.firstsv204(); cSv204 != null; cSv204 = itsv204.nextsv204())
        begin
          cSv204.assaysv204(1);
          for (Leafsv204 cSv204 = itsv204.firstsv204(); cSv204 != null; cSv204 = itsv204.nextsv204())
            cSv204.assaysv204(2);
          cSv204.assaysv204(3);
        end
      // S2 SIBLING loops declaring the same name.
      for (Leafsv204 cTv204 = itsv204.firstsv204(); cTv204 != null; cTv204 = itsv204.nextsv204())
        cTv204.assaysv204(4);
      for (Leafsv204 cTv204 = itsv204.firstsv204(); cTv204 != null; cTv204 = itsv204.nextsv204())
        cTv204.assaysv204(5);
      // S3 FOREACH inside a FOR: both loop names read in the innermost body.
      for (int iUv204 = 0; iUv204 < 4; iUv204++)
        foreach (this.arrsv204[jUv204])
          this.sinksv204 = iUv204 + jUv204 + this.arrsv204[jUv204];
      // S4 FOR inside a FOREACH.
      foreach (this.arrsv204[kVv204])
        for (int iVv204 = 0; iVv204 < 2; iVv204++)
          this.sinksv204 = kVv204 + iVv204;
    end
  endfunction
endpackage

package sluicesv204;
  import quarrysv204::*;
  class Flumesv204;
    function void racesv204();
      Aditsv204 gatesv204;
      gatesv204 = null;
    endfunction
  endclass
endpackage

module topsv204;
  import sluicesv204::*;
  initial begin
    Flumesv204 f204;
    f204 = new();
    f204.racesv204();
  end
endmodule
