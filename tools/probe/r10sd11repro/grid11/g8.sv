// r10sd11 grid cell g8 — THE DECLARATOR-ARRAY local, which is a SEPARATE
// factory (`makeAssocArrayVar` / `makeQueueDynArrayVar` / the fixed-size
// block-item pair) and therefore a separate site for this law.
//
// `uvm_resource_pool::sort_by_precedence`'s `uvm_resource_types::rsrc_q_t
// all[int];` at uvm_resource.svh:955 is exactly this shape and is the SeqDriver
// head after the three scalar sites are fixed.  The cell puts the DEGRADING
// typedef (`z8::d_t`, pushed out by the package claimant `pk8_t`) beside the
// CLAIMING one (`z8::k_t`, the only typedef naming `zk8`) at all four
// declarator forms, so both the ELEMENT TYPESPEC and the ELEMENT VARIABLE CLASS
// are scored in both directions.
package px8;
  // ORDERING NOTE.  slang refuses `Owner::td` when `Owner` is only
  // forward-declared, so every owner class is written BEFORE its user and the
  // USER class is written LAST.  Surelog's class pass is LEXICOGRAPHIC
  // (r10sd10 `g8`) and this law's claim order is read off NAMES, so `auser8`
  // still sorts first.
  class zel8;
    int q;
  endclass

  class zk8;
    int q;
  endclass

  typedef zel8 pk8_t;          // the PACKAGE claimant of zel8

  class z8;
    typedef zel8 d_t;          // DEGRADES: pk8_t claimed zel8 in the pkg pass
    typedef zk8  k_t;          // CLAIMS  : the only typedef naming zk8
  endclass

  class auser8;
    function void f8();
      z8::d_t  a_aa[int];      // assoc declarator, degrading typedef
      z8::d_t  a_q[$];         // queue declarator, degrading typedef
      z8::d_t  a_da[];         // dynamic declarator, degrading typedef
      z8::d_t  a_fx[4];        // fixed declarator, degrading typedef
      z8::k_t  k_aa[int];      // the same four on a CLAIMING typedef
      z8::k_t  k_q[$];
      z8::k_t  k_da[];
      z8::k_t  k_fx[4];
      a_aa[0] = null;
      k_aa[0] = null;
    endfunction
  endclass

endpackage

module top8;
  initial begin
    px8::auser8 u = new();
    u.f8();
  end
endmodule
