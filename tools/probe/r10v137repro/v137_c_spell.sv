// r10v137 arm C — THE LOOP-LIST SPELLINGS, and the SET HYGIENE of the gate.
// Every written spelling the brief names is put in the loop-list slot, and the
// bases that this law keys on are made to SHADOW and to be REUSED so that a
// stale entry in `foreachElemDrilledLV137` would show.  MEASUREMENT ONLY.
package glyph137;
  typedef class Sigil137;
  typedef struct { bit strokes137[Sigil137]; int weight137[string]; } stamp137_s;
  class Sigil137;
    bit strokes137[Sigil137];
    int weight137[string];
    Sigil137 kin137;
  endclass
  class Seal137;
    bit crest137[Sigil137];               // class PROPERTY
    static bit blaze137[Sigil137];        // STATIC class property
  endclass
  bit ptop137[Sigil137];                  // PACKAGE-level array
  class Wax137 extends Seal137;
    bit ridge137[Sigil137];
    extern function int press137(ref stamp137_s fst137[Sigil137],
                                 ref Sigil137   fsg137[Sigil137]);
  endclass

  function int Wax137::press137(ref stamp137_s fst137[Sigil137],
                                ref Sigil137   fsg137[Sigil137]);
    bit lcl137[Sigil137];                 // subroutine LOCAL
    int n137;
    // C1 — a PLAIN LOCAL loop list.
    foreach (lcl137[d1]) n137++;
    // C2 — a PLAIN PROPERTY loop list.
    foreach (ridge137[d2]) n137++;
    // C3 — a `this.`-rooted loop list.
    foreach (this.ridge137[d3]) n137++;
    // C4 — a `super.`-rooted loop list.
    foreach (super.crest137[d4]) n137++;
    // C5 — a `::`-scoped loop list.
    foreach (glyph137::ptop137[d5]) n137++;
    // C6 — a PACKAGE array, unqualified.
    foreach (ptop137[d6]) n137++;
    // C7 — a FORMAL loop list.
    foreach (fst137[d7]) n137++;
    // C8 — a STATIC property, `::`-scoped.
    foreach (Seal137::blaze137[d8]) n137++;

    // C9 — a `this.`-rooted list NESTED under an admitted formal's loop var.
    foreach (fst137[d9]) foreach (this.ridge137[da]) n137++;
    // C10 — a `::`-scoped list NESTED under an admitted formal's loop var.
    foreach (fst137[db]) foreach (glyph137::ptop137[dc]) n137++;
    // C11 — a TWO-LEVEL dotted path rooted at a CLASS base.
    foreach (fsg137[dd]) foreach (dd.kin137.strokes137[de]) n137++;
    // C12 — a TWO-LEVEL dotted path rooted at a STRUCT base.
    foreach (fst137[df]) foreach (df.strokes137[dg]) n137++;

    // C13 — SET HYGIENE: the same loop-variable NAME first over an admitted
    // formal, then over a NON-admitted subroutine local.  A stale entry would
    // make the second inner list fall back too.
    foreach (fst137[dh]) foreach (dh.strokes137[di]) n137++;
    foreach (lcl137[dh]) foreach (dh.strokes137[dj]) n137++;
    // C14 — the reverse order.
    foreach (lcl137[dk]) foreach (dk.strokes137[dl]) n137++;
    foreach (fst137[dk]) foreach (dk.strokes137[dm]) n137++;
    // C15 — SHADOWING: an inner foreach over an admitted formal re-using the
    // outer's name, then a dotted list under it.
    foreach (lcl137[dn]) begin
      foreach (fst137[dp]) foreach (dp.strokes137[dq]) n137++;
    end
    return n137;
  endfunction
endpackage

module topc137;
  glyph137::Wax137 wax137;
  glyph137::stamp137_s ast137[glyph137::Sigil137];
  glyph137::Sigil137   asg137[glyph137::Sigil137];
  int outc137;
  initial begin
    wax137 = new();
    outc137 = wax137.press137(ast137, asg137);
  end
endmodule
