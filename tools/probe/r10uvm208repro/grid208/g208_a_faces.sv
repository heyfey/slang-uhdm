// r10uvm208 arm A — THE SIX FACES.  The corpus's six refused cells reduced to
// one file: a `foreach`-walked array of a package typedef declared at every
// context the six occupy — the subroutine's own level, a `begin` block, a
// `foreach` body, and a nested `begin` inside a `foreach` — in a FREE
// subroutine, with a second scalar typedef alongside so a kind that is NOT the
// element type cannot ride along.  A second package wildcard-imports the body,
// which is what makes the clone.
//
// The `foreach` is what makes the crossing our emitter's memoised element chain
// produces: the home body's foreach REFERENCE VARIABLE and the clone body's
// declaration are handed one and the same `array_typespec` and one and the same
// element `ref_typespec`.  GOLDEN'S ARITY IS THE SPEC — on the corpus's own six
// cells golden reads `outer=1 arr=1 elemref=1` per clone declaration with the
// alias BARE, while the home's cells share a different chain whose alias stays
// QUALIFIED.  Every clone cell here must end BARE and every home cell must stay
// QUALIFIED, in BOTH views.
package p208a_h;
  typedef bit [7:0] bt208;
  typedef logic [3:0] lt208;

  function automatic int fa208(input int n208);
    bt208 lvl0_208[];              // face 1 — the subroutine's own level
    lt208 llog208[];               // a different kind, must not ride along
    int   acc208 = 0;
    foreach (lvl0_208[i208])
      acc208 += int'(lvl0_208[i208]);
    foreach (llog208[j208])
      acc208 += int'(llog208[j208]);
    begin
      bt208 blk208[];              // face 2 — a `begin` block
      foreach (blk208[k208])
        acc208 += int'(blk208[k208]);
    end
    for (int q208 = 0; q208 < 2; q208++) begin
      bt208 loop208[];             // face 3 — a loop body
      foreach (loop208[m208])
        acc208 += int'(loop208[m208]);
    end
    foreach (lvl0_208[p208]) begin
      bt208 fe208[];               // face 4 — a `foreach` body
      begin
        bt208 deep208[];           // face 5 — a nested `begin` inside it
        foreach (deep208[d208])
          acc208 += int'(deep208[d208]);
      end
      foreach (fe208[e208])
        acc208 += int'(fe208[e208]);
    end
    return acc208 + n208;
  endfunction

  // face 6 — a second HOME body using the same element type, which is the
  // other declaration our emitter's memo hands the same chain to
  function automatic int fb208();
    bt208 home208[];
    int   h208 = 0;
    foreach (home208[i208])
      h208 += int'(home208[i208]);
    return h208;
  endfunction
endpackage

package p208b_c;
  import p208a_h::*;
  function automatic int gc208();
    return fa208(1) + fb208();
  endfunction
endpackage

module g208_a_faces;
  import p208b_c::*;
  int r208;
  initial r208 = gc208();
endmodule
