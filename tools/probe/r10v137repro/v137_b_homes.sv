// r10v137 arm B — THE ADMITTED HOMES, PROBED FOR A WRONG ADMISSION.
// r10uvm137's gate admits three homes for the enclosing array (a subroutine
// FORMAL, a MODULE-level variable, an INTERFACE-level variable) and claims our
// loop-variable kind equals golden's on all three.  A wrong admission is the
// only way this law can move a cell OFF golden, so each admitted home is
// re-measured here with a STRUCT element, a CLASS element, a BIT element and a
// STRING element, and each with a dotted inner loop list.  MEASUREMENT ONLY.
package quill137;
  typedef class Rune137;
  typedef struct { bit marks137[Rune137]; int folio137[string]; } vellum137_s;
  class Rune137;
    bit marks137[Rune137];
    int folio137[string];
  endclass
endpackage

interface scriptorium137;
  // INTERFACE-level arrays — an ADMITTED home.
  quill137::vellum137_s ivs137[quill137::Rune137];
  quill137::Rune137     irn137[quill137::Rune137];
  bit                   ibt137[quill137::Rune137];
  string                ist137[quill137::Rune137];
  int                   itot137;
  function int scribe137();
    int n137;
    foreach (ivs137[b1]) foreach (b1.marks137[b2]) n137++;   // struct element
    foreach (irn137[b3]) foreach (b3.marks137[b4]) n137++;   // class  element
    foreach (ibt137[b5]) foreach (b5.marks137[b6]) n137++;   // bit    element
    foreach (ist137[b7]) foreach (b7.folio137[b8]) n137++;   // string element
    return n137;
  endfunction
  // A FORMAL of an interface function — the third admitted home, here with a
  // struct element, and with TWO loop variables on a two-dimensional formal.
  function automatic int quire137(ref quill137::vellum137_s fvs137[quill137::Rune137],
                        ref quill137::Rune137     frn137[quill137::Rune137]);
    int n137;
    foreach (fvs137[b9]) foreach (b9.folio137[ba]) n137++;
    foreach (frn137[bb]) foreach (bb.folio137[bc]) n137++;
    return n137;
  endfunction
endinterface

module topb137;
  // MODULE-level arrays — an ADMITTED home.
  quill137::vellum137_s mvs137[quill137::Rune137];
  quill137::Rune137     mrn137[quill137::Rune137];
  bit                   mbt137[quill137::Rune137];
  string                mst137[quill137::Rune137];
  quill137::Rune137     m2d137[quill137::Rune137][quill137::Rune137];
  int                   mtot137;

  scriptorium137 scr137();

  // A MODULE TASK's formal — an admitted home reached from a module.
  task automatic emboss137(ref quill137::vellum137_s tvs137[quill137::Rune137]);
    foreach (tvs137[b_d]) foreach (b_d.marks137[b_e]) mtot137++;
  endtask

  initial begin
    // B-M1..B-M4 — the MODULE-level arrays, dotted inner.
    foreach (mvs137[c1]) foreach (c1.marks137[c2]) mtot137++;
    foreach (mrn137[c3]) foreach (c3.marks137[c4]) mtot137++;
    foreach (mbt137[c5]) foreach (c5.marks137[c6]) mtot137++;
    foreach (mst137[c7]) foreach (c7.folio137[c8]) mtot137++;
    // B-M5 — a TWO-dimensional module-level array: both slots are admitted.
    foreach (m2d137[c9, ca]) foreach (c9.marks137[cb]) mtot137++;
    foreach (m2d137[cc, cd]) foreach (cd.folio137[ce]) mtot137++;
    // B-M7 — a SKIPPED second dimension.
    foreach (m2d137[ch, ]) foreach (ch.folio137[ci]) mtot137++;
    // B-M8 — THREE deep: a chain of dotted foreaches.
    foreach (mrn137[cj]) foreach (cj.marks137[ck]) foreach (ck.folio137[cl]) mtot137++;
    emboss137(mvs137);
    mtot137 += scr137.scribe137();
  end
endmodule
