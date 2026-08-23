// r10uvm113 / g113_b.sv — THE DECLARATION-ORDER DISCRIMINATOR for
// § classOwnLateMethodBindsPkgFn113.  Purpose-built golden: Surelog is the
// reference, our emitter must reproduce every cell.
//
// The one question: inside a class method, does a bare call to a name that is
// BOTH a method of the caller's OWN class and a free subroutine of the
// enclosing package bind the class method or the package function?  The answer
// is DECLARATION ORDER — Surelog compiles a class single-pass, so the class
// listing holds only what was written ABOVE the call.
//
// Names are deliberately UNRELATED to the law (alpha/beta/gamma, upper/lower,
// Kw/Kx) and the orders differ per class, so an arm cannot agree by accident.
package pb;
  function int alpha(int x); return x + 1; endfunction
  function int beta (int x); return x + 2; endfunction
  function int gamma(int x); return x + 3; endfunction
  function int delta(int x); return x + 4; endfunction

  class Kw;
    // written ABOVE Kw::alpha -> the class scan misses -> pb::alpha
    function int upper(); return alpha(1); endfunction
    function int alpha(int x); return x + 10; endfunction
    // written BELOW Kw::alpha -> Kw::alpha
    function int lower(); return alpha(2); endfunction
    // `beta` is not a method of Kw at all -> pb::beta from either side
    function int noCollide(); return beta(3); endfunction
  endclass

  class Kx;
    // three callers above the collision, one below, and a TASK caller
    function int c1(); return gamma(1); endfunction
    function int c2(); return gamma(2) + delta(9); endfunction
    function int gamma(int x); return x + 20; endfunction
    function int c3(); return gamma(3); endfunction
  endclass

  // A method of Kw declared BELOW an OUT-OF-BODY definition that calls it.
  class Ky;
    extern function int oob();
    function int delta(int x); return x + 30; endfunction
  endclass
  function int Ky::oob(); return delta(4); endfunction

  // NO package free function of this name exists: the late own-class method
  // must stay UNBOUND on both sides (the law's negative cell).
  class Kz;
    function int early(); return onlyHere(5); endfunction
    function int onlyHere(int x); return x + 40; endfunction
  endclass
endpackage

module tb_b;
  import pb::*;
  Kw kw; Kx kx; Ky ky; Kz kz;
  initial begin
    kw = new(); kx = new(); ky = new(); kz = new();
  end
endmodule
