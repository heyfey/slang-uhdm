// r10uvm204 arm D — THE CONTROL.  The same declarations and the same loops with
// NO WILDCARD IMPORT anywhere, so no package clones any subroutine and the law
// has no site at all.  Both binaries must produce a BYTE-IDENTICAL database in
// BOTH views; anything else is a leak out of the clone gate.
package quarryD204;
  class LeafD204;
    int oreD204;
    function void assayD204(int v204);
    endfunction
  endclass
  typedef LeafD204 LeafAliasD204;
  class IterD204;
    function LeafD204 firstD204();
      return null;
    endfunction
    function LeafD204 nextD204();
      return null;
    endfunction
  endclass

  class AditD204;
    int sinkD204;
    extern function void winzeD204();
  endclass

  function void AditD204::winzeD204();
    IterD204 itD204;
    int      paD204;
    itD204 = new();
    for (LeafD204 cA204 = itD204.firstD204(); cA204 != null; cA204 = itD204.nextD204())
      cA204.assayD204(1);
    for (LeafAliasD204 cC204 = itD204.firstD204(); cC204 != null; cC204 = itD204.nextD204())
      cC204.assayD204(2);
    for (int iD204 = 0; iD204 < 4; iD204++)
      sinkD204 = iD204;
    for (paD204 = 0; paD204 < 4; paD204++)
      sinkD204 = paD204;
  endfunction
endpackage

package sluiceD204;                 // an IMPORTER THAT DOES NOT WILDCARD-IMPORT
  import quarryD204::AditD204;      // an EXPLICIT single import: no clone
  class FlumeD204;
    function void raceD204();
      AditD204 gateD204;
      gateD204 = null;
    endfunction
  endclass
endpackage

module topD204;
  initial begin
    sluiceD204::FlumeD204 fD204;
    fD204 = new();
    fD204.raceD204();
  end
endmodule
