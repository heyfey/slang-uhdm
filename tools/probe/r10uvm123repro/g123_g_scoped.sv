// r10uvm123 arm G — THE WRITTEN-SPELLING FENCE, from scratch.  ONE typedef,
// cast twice in the same method: once BARE and once PACKAGE-SCOPED.  Golden
// clones the bare one and binds the LISTING OBJECT for the scoped one.
package Gorse123Pkg;
  typedef logic [15:0] thorn_lt;
  typedef bit   [11:0] THORN_BT;
  class Gorse123;
    thorn_lt g_l1, g_l2;
    THORN_BT g_b1, g_b2;
    function int gcast(int x);
      g_l1 = thorn_lt'(x);                 // BARE  -> per-use clone
      g_l2 = Gorse123Pkg::thorn_lt'(x);    // SCOPED-> the listing object
      g_b1 = THORN_BT'(x);                 // BARE
      g_b2 = Gorse123Pkg::THORN_BT'(x);    // SCOPED
      return 3;
    endfunction
  endclass
endpackage

module gorse123_top;
  import Gorse123Pkg::*;
  Gorse123 g;
  initial g = new();
endmodule
