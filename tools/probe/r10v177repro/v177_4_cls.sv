// r10v177 adversarial arm 4 — CLASSES: PARAMETERIZED, INHERITED, NESTED-HOME,
// AND THE OUT-OF-BODY SPELLINGS.
// The predicate's `ctx.cls` arm compares the alias's PARENT SCOPE against the
// class `tdDeclCtx10` walks to, with no view test and no specialization test.
// A parameterized class has ONE TypeAliasType PER SPECIALIZATION and its
// methods are per-specialization too; an out-of-body body written in the
// package reaches the `pkgClone` arm, whose walk stops at the PACKAGE and
// compares it against the alias's owner — so a CLASS-SCOPE alias returned out
// of body is answered `false` there by construction.  None of that is covered
// by g177_a/b/c/d, whose classes are all plain and whose out-of-body returns
// all name PACKAGE aliases.

package genp9;
  typedef enum { GP_A, GP_B } Root;
  typedef Root RootRef;               // package alias of a name

  class Base9;
    typedef enum { BA_1, BA_2 } BaseEnum;
    typedef BaseEnum BaseRef;         // BASE class's own alias of a name
    function BaseRef  baseOwn();  return BA_1; endfunction
    function BaseEnum baseDir();  return BA_2; endfunction
  endclass

  // A DERIVED class returning the BASE's alias — the alias's parent scope is
  // Base9, the compiling class is Deriv9, so the predicate must answer false.
  class Deriv9 extends Base9;
    typedef enum { DE_P, DE_Q } DerivEnum;
    typedef DerivEnum DerivRef;       // the DERIVED class's own alias
    function BaseRef  derInherited(); return BA_2; endfunction
    function DerivRef derOwn();       return DE_P; endfunction
    function RootRef  derPkgVia();    return GP_A; endfunction
  endclass

  // A PARAMETERIZED class: one TypeAliasType per specialization.
  class Box9 #(type PAY = int, int WIDE = 4);
    typedef enum { BX_S, BX_T } BoxEnum;
    typedef BoxEnum BoxRef;           // per-specialization alias of a name
    typedef PAY     PayRef;           // an alias of a TYPE PARAMETER's name
    function BoxRef  boxOwn(); return BX_S; endfunction
    function PayRef  boxPay(); return '0;   endfunction
    extern function BoxRef boxOob();
  endclass
  function Box9::BoxRef Box9::boxOob(); return BX_T; endfunction

  // OUT-OF-BODY bodies written in the package: the `pkgClone` arm.
  class Deck9;
    typedef enum { DK_X, DK_Y } DeckEnum;
    typedef DeckEnum DeckRef;         // CLASS-scope alias, named out of body
    extern function DeckRef  deckClsVia();
    extern function RootRef  deckPkgVia();
    extern function Root     deckPkgDir();
    extern static function RootRef deckStaticVia();
    function DeckRef deckInBody(); return DK_X; endfunction
  endclass
  function Deck9::DeckRef Deck9::deckClsVia();  return DK_Y; endfunction
  function RootRef         Deck9::deckPkgVia();  return GP_B; endfunction
  function Root            Deck9::deckPkgDir();  return GP_A; endfunction
  function RootRef         Deck9::deckStaticVia(); return GP_B; endfunction
endpackage

module Bench9;
  import genp9::*;
  Deriv9 d9 = new();
  Deck9  k9 = new();
  Box9 #(byte, 8) b9 = new();
  Box9 #(shortint, 2) b9b = new();
  initial $display(d9.derInherited(), d9.derOwn(), d9.derPkgVia(),
                   k9.deckClsVia(), k9.deckPkgVia(), k9.deckPkgDir(),
                   Deck9::deckStaticVia(), k9.deckInBody(),
                   b9.boxOwn(), b9.boxOob(), b9b.boxOwn());
endmodule
