// r10v137 arm F — the HOMES arm A/B did not reach: a FREE PACKAGE function and
// task, a STATIC class method, an ALWAYS block, a FORK…JOIN_NONE, and a
// STATEMENT-BLOCK automatic local, each with the admitted FORMAL/module home
// carrying a STRUCT element (the kind whose base DRILLS in Surelog) and a BIT
// element (the corpus shape).  MEASUREMENT ONLY.
package anvil137;
  typedef class Peg137;
  typedef struct { bit slots137[Peg137]; int rungs137[string]; } rack137_s;
  class Peg137;
    bit slots137[Peg137];
    int rungs137[string];
  endclass
  class Jig137;
    static function int fit137(ref rack137_s frk137[Peg137],
                               ref bit       fbt137[Peg137]);
      int n137;
      // F1/F2 — a STATIC class method's formals.
      foreach (frk137[k1]) foreach (k1.slots137[k2]) n137++;
      foreach (fbt137[k3]) foreach (k3.slots137[k4]) n137++;
      return n137;
    endfunction
  endclass
  // F3/F4 — a FREE PACKAGE function's formals.
  function automatic int rig137(ref rack137_s grk137[Peg137],
                                ref bit       gbt137[Peg137]);
    int n137;
    foreach (grk137[k5]) foreach (k5.rungs137[k6]) n137++;
    foreach (gbt137[k7]) foreach (k7.rungs137[k8]) n137++;
    return n137;
  endfunction
  // F5 — a FREE PACKAGE task's formal.
  task automatic hoist137(ref rack137_s hrk137[Peg137], output int n137);
    n137 = 0;
    foreach (hrk137[k9]) foreach (k9.slots137[ka]) n137++;
  endtask
endpackage

module topf137v;
  anvil137::rack137_s mrk137[anvil137::Peg137];
  bit                 mbt137[anvil137::Peg137];
  int                 n137, m137, p137;
  // F6/F7 — an ALWAYS block over MODULE-level arrays.
  always @(*) begin
    foreach (mrk137[l1]) foreach (l1.slots137[l2]) n137++;
    foreach (mbt137[l3]) foreach (l3.rungs137[l4]) n137++;
  end
  initial begin
    // F8/F9 — a FORK…JOIN_NONE over MODULE-level arrays.
    fork
      begin
        foreach (mrk137[l5]) foreach (l5.slots137[l6]) m137++;
        foreach (mbt137[l7]) foreach (l7.slots137[l8]) m137++;
      end
    join_none
    // F10/F11 — a STATEMENT-BLOCK AUTOMATIC local (a NON-admitted home).
    begin
      automatic anvil137::rack137_s ark137[anvil137::Peg137];
      automatic bit                 abt137[anvil137::Peg137];
      foreach (ark137[l9]) foreach (l9.slots137[la]) p137++;
      foreach (abt137[lb]) foreach (lb.slots137[lc]) p137++;
    end
    p137 += anvil137::Jig137::fit137(mrk137, mbt137);
    p137 += anvil137::rig137(mrk137, mbt137);
    anvil137::hoist137(mrk137, n137);
  end
endmodule
