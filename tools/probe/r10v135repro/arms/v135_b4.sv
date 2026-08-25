// r10v135 (VERIFIER) ARM b4 — MULTIPLICITY.  One package, THREE top modules:
// one imports and calls, one imports but never calls, one does neither.
// GOLDEN mints the implicit wire in exactly the modules Surelog's late binding
// reaches; anything else is the R-MULTI residue.
package pkgMultSierra4;
  class idxTangoCls4; int v; endclass
  class ownerUnif4;
    extern function void multVictor4();
  endclass
  function void ownerUnif4::multVictor4();
    bit m01Prom4 [idxTangoCls4];
    m01Prom4.delete();
  endfunction
  function void freeWhisky4(input bit m02FreeFormal4 [idxTangoCls4]);
    m02FreeFormal4.delete();
  endfunction
endpackage

module topOneXray4;                  // imports AND calls
  import pkgMultSierra4::*;
  ownerUnif4 oAlfaMult4;
  bit m03Act4 [idxTangoCls4];
  initial begin
    oAlfaMult4 = new();
    oAlfaMult4.multVictor4();
    freeWhisky4(m03Act4);
  end
endmodule

module topTwoYankee4;                // imports, never calls
  import pkgMultSierra4::*;
  int yv4;
  initial yv4 = 1;
endmodule

module topThreeZulu4;                // neither
  int zv4;
  initial zv4 = 2;
endmodule
