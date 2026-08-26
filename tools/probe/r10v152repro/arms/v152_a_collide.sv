// r10v152 arm A — NAME COLLISION AND LISTING ORDER.  A package that already
// owns a variable of the eaten declaration's name, in both orders, plus two
// constructors eating the SAME name.  Golden decides which copy wins.
package qcol;

  class Bee; int nb; endclass

  Bee shadow_up;                  // real package variable, BEFORE the class

  class Zeta;
    int wz;
    extern function new();
  endclass

  class Yank;
    int wy;
    extern function new();
  endclass

  class Xray;
    int wx;
    extern function new;          // paren-less
  endclass

  function Zeta::new();
    Bee shadow_up;                // EATEN, name collides with the package var
    Bee only_here;                // ordinary local
    shadow_up = null;             // c01
    only_here = null;             // c02
    wz = 1;
  endfunction

  function Yank::new();
    Bee shadow_up;                // EATEN, same name again, SECOND constructor
    Bee shadow_dn;                // ordinary local
    shadow_up = null;             // c03
    shadow_dn = null;             // c04
    wy = 2;
  endfunction

  function Xray::new;
    Bee shadow_dn;                // EATEN (paren-less), collides with qcol var below
    Bee tail_one;                 // ordinary local of a PAREN-LESS constructor
    shadow_dn = null;             // c05
    tail_one  = null;             // c06
    wx = 3;
  endfunction

  Bee shadow_dn;                  // real package variable, AFTER the classes

  function void freefn;           // PAREN-LESS package free function (TF-ITEM)
    Bee tail_one;                 // its local collides with Xray::new's local
    tail_one = null;              // c07  -- § 148 territory, must not move
  endfunction

  function void freefn2();        // PAREN'D free function
    Bee only_here;
    only_here = null;             // c08
  endfunction

endpackage

module mcol;
  import qcol::*;
  Zeta zz; Yank yy; Xray xx;
  initial begin
    zz = new(); yy = new(); xx = new();
    freefn(); freefn2();
  end
endmodule
