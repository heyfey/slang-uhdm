// vsd11 v2 — THE PARAMETERISED OWNER, written BARE.
// `scopedTdLeaf11` still calls `GenericClassDefSymbol::getDefaultSpecialization`
// on a root that resolves to a generic class.  The implementer removed that call
// from the CLAIM TABLE because it MINTS a specialisation that did not exist
// (the `UINT:1475` side effect) but LEFT IT in the leaf lookup.  `apv2::td` is
// the spelling that reaches it: legal SV (all parameters defaulted), an
// IdentifierName root, so `scopedTdSegs11` accepts it.
package pv2;

  class zel2;
    int q;
  endclass

  typedef zel2 pk2_t;          // package claimant -> every class typedef of zel2 degrades

  class apv2 #(int W = 8);
    typedef zel2 d_t;          // DEGRADES (pk2_t claimed zel2)
    typedef int  own_t;        // in-place target: always resolves
    int w = W;
  endclass

  // A REAL specialisation the design makes, so the claim table sees one.
  class user2;
    apv2#(3) inst3;
    function void f2();
      apv2::d_t     a_default;   // BARE generic root -> getDefaultSpecialization
      apv2::own_t   a_own;
      apv2#(3)::d_t a_explicit;  // ClassName root -> refused by scopedTdSegs11
      a_default = null;
    endfunction
  endclass

endpackage

module topv2;
  initial begin
    pv2::user2 u = new();
    u.f2();
  end
endmodule
