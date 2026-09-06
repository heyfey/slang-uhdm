// r10v173 arm P — NAME COLLISION between a PACKAGE name and a CLASS name.
// The patched gate asks "does the written callee name begin with
// <some package of this design>:: ?".  Here `mist` is BOTH a package of this
// design AND a class living in another package, so the written spelling
// `mist::flare(..)` is CLASS-qualified while the string test reads it as
// package-qualified.  Golden decides; this arm records what golden does.
package mist;
  function automatic int drizzle(int q);
    return q + 3;
  endfunction
endpackage

package brume_pkg;
  // A class whose NAME EQUALS the package `mist` above.
  class mist;
    static function int flare(int q);
      return q + 5;
    endfunction
    static function int haze(int q);
      return q + 6;
    endfunction
  endclass

  // Called from brume_pkg's DEF listing: the spelling collides.
  function automatic int veil(int q);
    return mist::flare(q) + 1;                 // CLASS-qualified, name collides
  endfunction

  function automatic int shroud(int q);
    return veil(q) + mist::haze(q);            // bare + colliding-qualified
  endfunction
endpackage

package fog_pkg;
  import mist::*;
  // Genuinely PACKAGE-qualified into the colliding name.
  function automatic int murk(int q);
    return mist::drizzle(q) + 2;
  endfunction
  // ...and unqualified through the wildcard import.
  function automatic int gloom(int q);
    return drizzle(q) + murk(q);
  endfunction
endpackage

module collide_top (output int o1, output int o2, output int o3);
  assign o1 = brume_pkg::veil(4);
  assign o2 = brume_pkg::shroud(7);
  assign o3 = fog_pkg::gloom(9) + fog_pkg::murk(2);
endmodule
