// r10uvm204 arm B — THE CONTEXTS.  The SAME for-loop shape written in every
// site the law could reach, so the census's site classes are read off a real
// Surelog golden and not assumed: a package FREE subroutine, an OUT-OF-BODY
// class method (the clone's own site), an IN-BODY class method (never cloned),
// a MODULE task and a MODULE initial body (never cloned either).
package quarryB204;
  class LeafB204;
    int oreB204;
    function void assayB204(int v204);
    endfunction
  endclass
  class IterB204;
    function LeafB204 firstB204();
      return null;
    endfunction
    function LeafB204 nextB204();
      return null;
    endfunction
  endclass

  int sinkB204;

  // CONTEXT 1 — a package FREE subroutine.
  function void freeB204();
    IterB204 itB204;
    itB204 = new();
    for (LeafB204 cF204 = itB204.firstB204(); cF204 != null; cF204 = itB204.nextB204())
      cF204.assayB204(1);
  endfunction

  class AditB204;
    int lodeB204;
    extern task outB204();               // CONTEXT 2 — OUT-OF-BODY class method
    function void inB204();              // CONTEXT 3 — IN-BODY class method
      IterB204 itI204;
      itI204 = new();
      for (LeafB204 cI204 = itI204.firstB204(); cI204 != null; cI204 = itI204.nextB204())
        cI204.assayB204(2);
    endfunction
  endclass

  task AditB204::outB204();
    IterB204 itO204;
    itO204 = new();
    for (LeafB204 cO204 = itO204.firstB204(); cO204 != null; cO204 = itO204.nextB204())
      cO204.assayB204(3);
    begin
      for (LeafB204 cN204 = itO204.firstB204(); cN204 != null; cN204 = itO204.nextB204())
        cN204.assayB204(4);              // nested one block deeper
    end
  endtask
endpackage

package sluiceB204;                      // THE WILDCARD IMPORTER
  import quarryB204::*;
  class FlumeB204;
    function void raceB204();
      AditB204 gateB204;
      gateB204 = null;
    endfunction
  endclass
endpackage

module topB204;                          // CONTEXT 4 + 5 — MODULE task and body
  import sluiceB204::*;
  import quarryB204::*;
  int rB204;
  task mtB204();
    IterB204 itM204;
    itM204 = new();
    for (LeafB204 cM204 = itM204.firstB204(); cM204 != null; cM204 = itM204.nextB204())
      cM204.assayB204(5);
  endtask
  initial begin
    IterB204 itT204;
    itT204 = new();
    for (LeafB204 cT204 = itT204.firstB204(); cT204 != null; cT204 = itT204.nextB204())
      cT204.assayB204(6);
    mtB204();
    freeB204();
  end
endmodule
