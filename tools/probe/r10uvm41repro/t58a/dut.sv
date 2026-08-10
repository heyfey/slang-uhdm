// r10uvm41 arm t58a — THE SHARED-TYPESPEC MUTATION WITNESS.
//
// Pass 40's own verifier found a REGRESSION (not merely an omission) in the
// new makeAssocArrayVar: when an associative index is written as a TYPEDEF
// NAME, `assocIndexTs` returns `sharedAliasTs(idx)` — the ONE typespec object
// that every declaration of that typedef's type points at — and the caller
// then stamped setLoc / Instance / VpiSigned onto it.  The in-code comment
// claimed only the freshly-minted predefined-integer arm was touched, but the
// guard tested the CANONICAL KIND, so `typedef int myint` walked straight
// through it.
//
// The observable damage is that UNRELATED declarations get re-spanned to
// another declaration's index bracket: golden puts every `pkb::b8` typespec
// occurrence at the TYPEDEF, and a patched pass-40 build moved a third of
// them to the `[b8]` of one function-local array.
//
// So this arm is a pure NEGATIVE control for the mutation, measured on the
// SHARED object's own span/name, and it deliberately exercises all four
// call sites that can reach a shared alias:
//   * a BODY-LOCAL assoc array indexed by a typedef name (TaskFuncEmit
//     makeAssocArrayVar — the new site, both the bit-vector alias and the
//     PredefinedInteger alias that slipped the vpiSigned guard),
//   * an assoc FORMAL indexed by a typedef name (TaskFuncEmit io_decl arm),
//   * a CLASS PROPERTY indexed by a typedef name (UhdmExporter emitAssocDims,
//     the inherited idiom),
//   * plus plenty of ordinary users of the same typedefs whose typespec must
//     stay spanned at the typedef declaration: a module-level net/var, a class
//     property, a function local, a formal, and a package variable.
package pkb;

  typedef bit [7:0] b8;      // the shared bit_typespec, spanned HERE
  typedef int myint;         // the shared int_typespec, spanned HERE

  // ordinary users of b8 / myint — none of these may move
  b8 pkgvar;
  myint pkgint;

  class oobb;
    b8 prop;                       // property typed by the alias
    myint iprop;
    b8 pmapb[b8];                  // class property, assoc index = alias
    int pmapi[myint];
    extern function void mIdxB();
    extern function void mIdxI();
    extern function void mUse();
    extern function void mFormal(b8 fb, int fmap[b8], int imap[myint]);
  endclass

  // the NEW site: a body-local assoc array whose index is a typedef NAME
  function void oobb::mIdxB();
    int ab[b8];
    b8 localb;
    ab[8'h3] = 1;
    localb = 8'h1;
  endfunction

  // the same, with a PredefinedInteger alias — this is the cell the
  // canonical-kind guard let through to VpiSigned
  function void oobb::mIdxI();
    int ai[myint];
    myint locali;
    ai[3] = 1;
    locali = 3;
  endfunction

  function void oobb::mUse();
    b8 v;
    myint w;
    v = 8'h2;
    w = 4;
  endfunction

  function void oobb::mFormal(b8 fb, int fmap[b8], int imap[myint]);
    fmap[fb] = 1;
    imap[0] = 2;
  endfunction

  // a package FREE function, the other listing that reaches the new arm
  function void fIdxB();
    int fb2[b8];
    b8 fv;
    fb2[8'h4] = 1;
    fv = 8'h5;
  endfunction

  function void fIdxI();
    int fi2[myint];
    myint fw;
    fi2[5] = 1;
    fw = 6;
  endfunction

  // an IN-BODY class method (never promoted) — its size-model index must not
  // touch the shared object either
  class inbb;
    function void iIdxB();
      int ib[b8];
      b8 iv;
      ib[8'h6] = 1;
      iv = 8'h7;
    endfunction
  endclass

endpackage

module top58;
  import pkb::*;
  pkb::b8 t;            // an ordinary module-level user of the shared typespec
  pkb::myint ti;
  oobb h;
  initial begin
    t = 8'h1;
    ti = 2;
    h = new();
    h.mIdxB();
    h.mIdxI();
    h.mUse();
    fIdxB();
    fIdxI();
  end
endmodule
