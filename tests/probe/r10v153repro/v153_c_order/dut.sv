// r10v153 arm C — TWO listing entries of the SAME NAME, in BOTH orders: a
// hoisted constructor local BEFORE the real package variable, and one AFTER.
// Surelog `break`s on the FIRST match, so the order decides.  LHS is golden.
package pvc153;

  class Donc153;
    extern function new(int q);
  endclass
  function Donc153::new(int q);
    int x_early;                  // hoisted copy, EARLY in the listing
    x_early = q;
  endfunction

  int    x_early;                 // the real package variable, LATER
  string x_late;                  // the real package variable, EARLIER

  class Dondc153;
    extern function new(int q);
  endclass
  function Dondc153::new(int q);
    string x_late;                // hoisted copy, LATER in the listing
    x_late = "a";
  endfunction

  class Cvc153;
    int    x_early;
    string x_late;
    extern function void mc153(int p);
  endclass

  function void Cvc153::mc153(int p);
    x_early = p;
    x_late  = "z";
  endfunction

endpackage
