// r10v204 arm N — the INIT FORMS again, but every loop inside a NESTED begin
// block, which is the case arm A never tested: pristine leaves those references
// BARE (a nested-block loop never reaches funcMap), so this is where the patch
// MINTS new bindings.  One real Surelog golden decides each form.
package quarryv204;
  class Leafv204;
    int orev204;
    function void assayv204(int v204);
    endfunction
  endclass
  typedef Leafv204 AliasLeafv204;

  class Iterv204;
    function Leafv204 firstv204();
      return null;
    endfunction
    function Leafv204 nextv204();
      return null;
    endfunction
  endclass

  class Aditv204;
    int sinkv204;
    extern function void winzev204(int selv204);
  endclass

  function void Aditv204::winzev204(int selv204);
    Iterv204 itv204;
    int      pav204;
    itv204 = new();
    pav204 = 0;
    if (selv204 == 1) begin
      int dupv204;
      dupv204 = 7;
      // N1 CLASS-TYPE DECLARATION (the corpus shape; positive control).
      for (Leafv204 cN1v204 = itv204.firstv204(); cN1v204 != null; cN1v204 = itv204.nextv204())
        cN1v204.assayv204(1);
      // N2 TYPEDEF-ALIAS DECLARATION (residue R1, now in the minting case).
      for (AliasLeafv204 cN2v204 = itv204.firstv204(); cN2v204 != null; cN2v204 = itv204.nextv204())
        cN2v204.assayv204(2);
      // N3 BUILTIN-TYPE DECLARATION.
      for (int iN3v204 = 0; iN3v204 < 4; iN3v204++)
        this.sinkv204 = iN3v204;
      // N4 MULTIPLE DECLARED INITS (residue R2, now in the minting case).
      for (int mN4v204 = 0, nN4v204 = 1; mN4v204 < 4; mN4v204++)
        this.sinkv204 = mN4v204 + nN4v204;
      // N5 PLAIN ASSIGNMENT -- THE FENCE.
      for (pav204 = 0; pav204 < 4; pav204++)
        this.sinkv204 = pav204;
      // N6 STRING-TYPED DECLARATION.
      for (string sN6v204 = "a"; sN6v204 != "b"; sN6v204 = "b")
        this.sinkv204 = sN6v204.len();
      // N7 SHADOWING a block local of the same name.
      for (int dupv204 = 0; dupv204 < 2; dupv204++)
        this.sinkv204 = dupv204;
      this.sinkv204 = dupv204;
    end
  endfunction
endpackage

package sluicev204;
  import quarryv204::*;
  class Flumev204;
    function void racev204();
      Aditv204 gatev204;
      gatev204 = null;
    endfunction
  endclass
endpackage

module topv204;
  import sluicev204::*;
  initial begin
    Flumev204 f204;
    f204 = new();
    f204.racev204();
  end
endmodule
