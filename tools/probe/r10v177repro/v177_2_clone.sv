// r10v177 adversarial arm 2 — THE WILDCARD-IMPORT CLONE, BOTH HALVES.
// r10uvm177 gates its CLASS-METHOD clone with `!pkgImportCloneEmit` and says
// (README §2) that the component compiling an imported clone is the IMPORTER,
// which runs after the home package's typedefs are bound, so golden keeps the
// RESOLVED kind there.  The emitter clones FREE SUBROUTINES into an importing
// package too (ParamEmit.cpp ~20768, `pkgImportCloneEmit = true` with
// `pkgClassTfClone` left NULL) — and that half reaches the predicate's
// free-subroutine loop, which is gated on `defPkgView` ALONE and compares the
// alias's package against the HOME package the walk finds.  This arm makes both
// halves exist in one file so golden can say which answer each takes.

package homep9;
  typedef enum { HP_ONE, HP_TWO } HpBase;
  typedef HpBase   HpRef;          // alias OF A NAME, home package's own
  typedef int      HpIntBase;
  typedef HpIntBase HpIntRef;

  // FREE functions — cloned into every wildcard importer's listing.
  function HpBase freeDirect(); return HP_ONE; endfunction
  function HpRef  freeVia();    return HP_TWO; endfunction
  function HpIntRef freeIntVia(); return 5; endfunction

  // A CLASS with an OUT-OF-BODY method — the head's own shape.
  class Vault9;
    extern function HpRef  oobVia();
    extern function HpBase oobDirect();
    function HpRef inbodyVia(); return HP_TWO; endfunction
  endclass
  function HpRef  Vault9::oobVia();    return HP_ONE; endfunction
  function HpBase Vault9::oobDirect(); return HP_TWO; endfunction
endpackage

// The IMPORTER.  Its DEF listing carries clones of homep9's free functions and
// of Vault9's methods; its own typedefs are irrelevant to those clones.
package userp9;
  import homep9::*;
  typedef enum { UP_L, UP_M } UpBase;
  typedef UpBase UpRef;            // the importer's OWN alias of a name
  function UpRef ownVia(); return UP_L; endfunction
  // Use the imported names, so the wildcard import is live rather than dead.
  function HpRef useHome(); Vault9 v = new(); return v.oobVia(); endfunction
  function HpBase useHomeDir(); return freeDirect(); endfunction
endpackage

// A SECOND importer, so a clone that moves is not a one-listing accident.
package alsop9;
  import homep9::*;
  function int alsoCall(); return int'(freeVia()); endfunction
endpackage

module Consumer9;
  import homep9::*;
  import userp9::*;
  import alsop9::*;
  initial $display(freeDirect(), freeVia(), freeIntVia(), ownVia(), alsoCall());
endmodule
