// r10uvm161 arm A — THE WINDOW.  Is an IMMEDIATE ASSERTION's CONDITION a
// binding window for an IN-BODY class method's locals and formals, the way an
// if / case CONDITION is?  Every cell below has a DIFFERENT name, a different
// literal and a different declared kind, so no cell can be confirmed by its
// neighbour (RESUME.md §9: an arm that names everything a_t/b_t/c_t over
// A/B/C is self-confirming).
//
// Controls carried on purpose, all four already decided by earlier passes:
//   * an `if` CONDITION at depth 0            -> golden BINDS  (classMethodNoBind is cleared there)
//   * an assignment LHS / RHS                 -> golden BARE
//   * a `while` CONDITION                     -> golden BARE   (never a window)
//   * anything one control body deeper        -> golden BARE   (§ controlBodyNoBind28)
package pkga161;

  class kwin161;
    int prop161;
    string sprop161;

    // IN-BODY class method.  Parenthesised header -> the BLOCK-ITEM
    // production, so the locals are owned by a synthesised body `begin`.
    function void inbody161(int farg161, string sarg161);
      int quartz161;
      chandle marlow161;
      string vellum161;
      logic [3:0] copper161;

      // ---- CONTROLS (already-decided cells) ----
      if (quartz161 == 11) prop161 = 12;          // if condition, d0
      quartz161 = 13;                             // assignment lhs
      prop161 = quartz161 + 14;                   // assignment rhs
      while (quartz161 < 15) quartz161 = 16;      // while condition (not a window)

      // ---- THE MEASURED CELLS: assertion CONDITIONS at depth 0 ----
      assert (quartz161 != 21);                   // plain local, int
      assert (marlow161 != null);                 // plain local, chandle  <- the corpus shape
      assert (vellum161 != "gantry");             // plain local, string
      assert (copper161 != 4'd7);                 // plain local, packed logic
      assert (farg161 != 22);                     // FORMAL
      assert (sarg161 != "harrow");               // FORMAL, string
      assert (prop161 != 23);                     // class PROPERTY
      assert (sprop161 != "kestrel");             // class PROPERTY, string
      assume (quartz161 != 24);                   // assume condition
      cover (vellum161 != "lintel");              // cover condition
      assert #0 (copper161 != 4'd5);              // DEFERRED assert
      assert final (farg161 != 25);               // FINAL assert

      // ---- the ACTION BLOCKS (pass and else), depth 0 ----
      assert (quartz161 != 31) prop161 = quartz161;      // pass action reads the local
      assert (copper161 != 4'd3) else prop161 = 32;      // else action only
      assert (vellum161 != "mullion")
        prop161 = 33;
      else
        sprop161 = vellum161;                            // else action reads the local

      // ---- one control body deeper ----
      if (farg161 == 41) begin
        assert (quartz161 != 42);                 // assertion condition at d1
        assert (marlow161 != null);               // chandle at d1
      end
      while (quartz161 < 43) begin
        assert (vellum161 != "newel");            // assertion condition in a loop body
      end
      forever begin
        assert (copper161 != 4'd1);
        break;
      end
    endfunction

    // A method whose header has NO port-list paren -> the TF-ITEM production.
    // The locals are FUNCTION-parented there, so the same window is asked of a
    // different listing.
    function void tfitem161;
      int gudgeon161;
      chandle pintle161;
      assert (gudgeon161 != 51);
      assert (pintle161 != null);
      if (gudgeon161 == 52) prop161 = 53;
      gudgeon161 = 54;
    endfunction

    // A STATIC method.
    static function void statmeth161(int sfarg161);
      int transom161;
      assert (transom161 != 61);
      assert (sfarg161 != 62);
      if (transom161 == 63) transom161 = 64;
    endfunction

    // A TASK.
    task tsk161(int targ161);
      int shackle161;
      assert (shackle161 != 71);
      assert (targ161 != 72);
      if (shackle161 == 73) shackle161 = 74;
    endtask

    // An extern method, DEFINED OUT OF BODY below: `classMethodNoBind` is
    // never set for it, so it is the other side of the gate.
    extern function void oob161(int oarg161);
  endclass

  function void kwin161::oob161(int oarg161);
    int spandrel161;
    chandle wicket161;
    assert (spandrel161 != 81);
    assert (wicket161 != null);
    assert (oarg161 != 82);
    if (spandrel161 == 83) spandrel161 = 84;
    spandrel161 = 85;
  endfunction

  // A package FREE function — no class at all.
  function void freefn161(int parg161);
    int lintel161;
    chandle sconce161;
    assert (lintel161 != 91);
    assert (sconce161 != null);
    assert (parg161 != 92);
    if (lintel161 == 93) lintel161 = 94;
  endfunction

endpackage

module mwin161;
  import pkga161::*;

  // A MODULE function.
  function void modfn161(int marg161);
    int corbel161;
    chandle plinth161;
    assert (corbel161 != 101);
    assert (plinth161 != null);
    assert (marg161 != 102);
    if (corbel161 == 103) corbel161 = 104;
  endfunction

  int mvar161;
  initial begin
    int ivar161;
    assert (ivar161 != 111);
    assert (mvar161 != 112);
    if (ivar161 == 113) mvar161 = 114;
  end
endmodule
