// r10uvm192 ARM D — THE ARM THAT TESTS RATHER THAN AGREES: name collisions,
// case, ordering and the shapes the fence must REFUSE.  MEASUREMENT ONLY.
package quillPkg;

  // D1 — a FREE function whose name equals a class method's name.  The
  //      package listing then holds BOTH `tally` and `Ledger::tally`, and the
  //      fence's EXACT-name test is the only thing separating them.
  function automatic int tally();
    return 41;
  endfunction

  class Ledger;
    extern static function int tally();
    extern static function int TALLY();     // D2 — CASE: a different entry
    extern static function int caller();
  endclass
  function int Ledger::tally();
    return 43;
  endfunction
  function int Ledger::TALLY();
    return 47;
  endfunction
  function int Ledger::caller();
    return Ledger::tally()      // the class entry
         + Ledger::TALLY()      // the case-different class entry
         + tally()              // the FREE function, unqualified
         + quillPkg::tally();   // the FREE function, package-qualified (173)
  endfunction

  // D3 — ORDER: a class DECLARED AFTER the body that calls it.
  class Late;
    extern static function int mark();
  endclass
  function int Late::mark();
    return 53;
  endfunction

  class Early;
    extern static function int early();
  endclass
  function int Early::early();
    return Late::mark();
  endfunction

  // D4 — a class method calling a method OF ITS OWN CLASS, class-qualified.
  class Selfish;
    extern static function int one();
    extern static function int two();
  endclass
  function int Selfish::one();
    return 59;
  endfunction
  function int Selfish::two();
    return Selfish::one();
  endfunction

  // D5 — the SAME call written twice in one body, and once inside an argument.
  class Twice;
    extern static function int pick(input int q);
    extern static function int both();
  endclass
  function int Twice::pick(input int q);
    return q + 61;
  endfunction
  function int Twice::both();
    return Twice::pick(Twice::pick(1)) + Twice::pick(2);
  endfunction

endpackage
