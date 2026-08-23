// r10uvm103 arm a3 — ISOLATING THE DISCRIMINATOR.  Every statement below is a
// dotted method call; the only axis that varies is whether an ARGUMENT can be
// bound (a call / a member read through a handle whose type is an
// unspecialised type parameter cannot be).  2, 3 and 4 components each appear
// with a bindable and an unbindable argument.  MEASUREMENT ONLY.
package Rk103;

  class Elm103;
    int uu;
    function void put(int aa); uu = aa; endfunction
    function int  get();       return uu; endfunction
  endclass

  class Box103;
    Elm103 slot;
    function new(); slot = new(); endfunction
    function void bput(int aa); slot.uu = aa; endfunction
  endclass

  class Crate103;
    Box103 bx;
    function new(); bx = new(); endfunction
  endclass

  class Holder103 #(type PT = int);
    Crate103 cr;
    Box103   bo;
    Elm103   el;
    PT       tp;
    int      kk;
    function new(); cr = new(); bo = new(); el = new(); endfunction

    // -- bindable argument --
    function void G2ok();  el.put( 31 );                endfunction
    function void G3ok();  bo.slot.put( 32 );           endfunction
    function void G4ok();  cr.bx.slot.put( 33 );        endfunction
    // -- argument is a CALL on an unspecialised type parameter --
    function void G2bad(); el.put( tp.conv( kk ) );     endfunction
    function void G3bad(); bo.slot.put( tp.conv( kk ) ); endfunction
    function void G4bad(); cr.bx.slot.put( tp.conv( kk ) ); endfunction
    // -- argument is a MEMBER READ through the same handle --
    function void G3mem(); bo.slot.put( tp.fld );       endfunction
    // -- RECEIVER itself goes through the type parameter --
    function void G3rcv(); tp.bx.slot.put( 34 );        endfunction
    // -- bad argument in EXPRESSION position --
    function int  G3exp(); return bo.slot.get() + tp.conv( kk ); endfunction
  endclass

endpackage
