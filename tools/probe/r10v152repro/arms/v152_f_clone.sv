// r10v152 arm F — THE WILDCARD-IMPORT CLONE.  Package `donor` owns a class
// whose out-of-body constructor eats its first body element; package `taker`
// wildcard-imports it, so Surelog materialises a COPY of the subroutine and a
// CLONE of the collected package variable.  § 81's arm c8 says a formal
// SURVIVES in such a copy; this arm asks what the EATEN name does.
package donor;
  class Rod; int rr; endclass
  class Barrel;
    int bz;
    extern function new();
  endclass
  function Barrel::new();
    Rod eaten_rod;                 // f01 EATEN
    Rod kept_rod;                  // f02 ordinary local
    eaten_rod = null;
    kept_rod  = null;
    bz = 1;
  endfunction
  function void donor_fn(Rod eaten_rod);
    bz_helper(eaten_rod);          // f03 a FORMAL of the same name
  endfunction
  function void bz_helper(Rod r);
  endfunction
endpackage

package taker;
  import donor::*;
  class Crate;
    int cz;
    extern function new();
  endclass
  function Crate::new();
    Rod taker_eat;                 // f04 EATEN in the IMPORTING package
    Rod taker_keep;                // f05
    taker_eat  = null;
    taker_keep = null;
    cz = 2;
  endfunction
endpackage

module mclone;
  import taker::*;
  Barrel bb; Crate cc;
  initial begin
    bb = new(); cc = new();
  end
endmodule
