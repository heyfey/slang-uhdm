// r10uvm137 arm A — THE BASE-RESOLUTION MATRIX for a DOTTED foreach loop list.
// Varies WHAT the first written segment of `<base>.<member>[k]` is, holding the
// member (and therefore the resolvable answer) constant.
// MEASUREMENT ONLY.  Names deliberately unalike.
package quarry137;

  typedef class Nugget137;

  class Nugget137;
    bit       wells137[Nugget137];   // associative, keyed by a CLASS
    int       shafts137[string];     // associative, keyed by string
    string    tallies137[int];       // associative, keyed by int
    int       drums137[$];           // queue
    byte      crates137[];           // dynamic
    shortint  pegs137[6];            // fixed
  endclass

  Nugget137 depot137;                // PACKAGE-LEVEL handle

  class Quarry137;
    Nugget137 anvil137;              // CLASS PROPERTY handle
    static Nugget137 beacon137;      // STATIC class property handle
    extern function void survey137(Nugget137 chisel137, ref bit ledger137[Nugget137]);
  endclass

  function void Quarry137::survey137(Nugget137 chisel137,
                                     ref bit ledger137[Nugget137]);
    Nugget137 lantern137;            // SUBROUTINE LOCAL handle
    bit       roster137[Nugget137];  // SUBROUTINE LOCAL assoc keyed by class
    int       tally137;

    // C1 base = SUBROUTINE LOCAL handle
    foreach (lantern137.wells137[u1]) tally137++;
    // C2 base = FORMAL (input) handle
    foreach (chisel137.wells137[u2]) tally137++;
    // C3 base = CLASS PROPERTY handle (implicit this)
    foreach (anvil137.wells137[u3]) tally137++;
    // C4 base = STATIC class property handle
    foreach (beacon137.wells137[u4]) tally137++;
    // C5 base = PACKAGE-LEVEL handle
    foreach (depot137.wells137[u5]) tally137++;
    // C6 base = LOOP VARIABLE of an enclosing foreach over a LOCAL assoc
    foreach (roster137[u6])
      foreach (u6.wells137[u7]) tally137++;
    // C7 base = LOOP VARIABLE of an enclosing foreach over a FORMAL assoc
    foreach (ledger137[u8])
      foreach (u8.wells137[u9]) tally137++;
    // C8 the same base, MEMBER VARIED — string-keyed
    foreach (roster137[ua])
      foreach (ua.shafts137[ub]) tally137++;
    // C9 the same base, MEMBER VARIED — int-keyed
    foreach (roster137[uc])
      foreach (uc.tallies137[ud]) tally137++;
    // C10 the same base, MEMBER VARIED — queue
    foreach (roster137[ue])
      foreach (ue.drums137[uf]) tally137++;
    // C11 the same base, MEMBER VARIED — dynamic
    foreach (roster137[ug])
      foreach (ug.crates137[uh]) tally137++;
    // C12 the same base, MEMBER VARIED — fixed
    foreach (roster137[ui])
      foreach (ui.pegs137[uj]) tally137++;
    // C13 RESOLVABLE base, MEMBER VARIED — string-keyed
    foreach (lantern137.shafts137[uk]) tally137++;
    // C14 RESOLVABLE base, MEMBER VARIED — int-keyed
    foreach (lantern137.tallies137[ul]) tally137++;
    // C15 RESOLVABLE base, MEMBER VARIED — queue
    foreach (lantern137.drums137[um]) tally137++;
    // C16 RESOLVABLE base, MEMBER VARIED — dynamic
    foreach (lantern137.crates137[un]) tally137++;
    // C17 RESOLVABLE base, MEMBER VARIED — fixed
    foreach (lantern137.pegs137[uo]) tally137++;
    // C18 BARE control: the local assoc itself
    foreach (roster137[up]) tally137++;
    // C19 `this.`-rooted dotted (uvm134 R1 territory; measured, not claimed)
    foreach (this.anvil137.wells137[uq]) tally137++;
  endfunction

endpackage

module topq137;
  quarry137::Quarry137 rig137;
  bit lot137[quarry137::Nugget137];
  initial begin
    rig137 = new();
    rig137.survey137(null, lot137);
  end
endmodule
