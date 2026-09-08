// r10uvm204 arm C — SHADOWING, and the two ways the pristine binary got it
// wrong.  Two SIBLING loops declare the same name at the subroutine's own
// statement level (the `uvm_vreg::write` shape: both reach the name map, so the
// map's LAST writer used to win for BOTH); a NESTED loop redeclares an outer
// loop's name; and a subroutine LOCAL carries a loop variable's name, which the
// innermost-out climb must not prefer over the loop's own.
package quarryC204;
  class LeafC204;
    int oreC204;
    function void assayC204(int v204);
    endfunction
  endclass
  class IterC204;
    function LeafC204 firstC204();
      return null;
    endfunction
    function LeafC204 nextC204();
      return null;
    endfunction
  endclass

  class AditC204;
    int sinkC204;
    extern function void winzeC204();
  endclass

  function void AditC204::winzeC204();
    IterC204 itC204;
    LeafC204 cbC204;                  // a SUBROUTINE LOCAL of the loops' name
    int      k204;
    itC204 = new();
    cbC204 = null;
    // SIBLING 1 — must bind ITS OWN `cbC204`, not sibling 2's and not the local.
    for (LeafC204 cbC204 = itC204.firstC204(); cbC204 != null; cbC204 = itC204.nextC204())
      cbC204.assayC204(1);
    // SIBLING 2 — must bind ITS OWN.
    for (LeafC204 cbC204 = itC204.firstC204(); cbC204 != null; cbC204 = itC204.nextC204())
      cbC204.assayC204(2);
    // NESTED — the inner loop redeclares `k204`; the inner body must reach the
    // INNER declaration and the outer body the OUTER one.
    for (int k204 = 0; k204 < 2; k204++) begin
      this.sinkC204 = k204;
      for (int k204 = 0; k204 < 2; k204++)
        this.sinkC204 = k204;
    end
    // AFTER the loops: the SUBROUTINE LOCAL is the only `cbC204` in scope.
    cbC204.assayC204(3);
    this.sinkC204 = k204;
  endfunction
endpackage

package sluiceC204;
  import quarryC204::*;
  class FlumeC204;
    function void raceC204();
      AditC204 gateC204;
      gateC204 = null;
    endfunction
  endclass
endpackage

module topC204;
  import sluiceC204::*;
  initial begin
    FlumeC204 fC204;
    fC204 = new();
    fC204.raceC204();
  end
endmodule
