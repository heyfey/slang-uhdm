// r10uvm136 arm B — DECLARATION ORDER / HOME of the typedef relative to the
// class.  The head's own shape is an INCLUDE-ORDER one: `uvm_reg_map_addr_range`
// sits at uvm_reg_model.svh:412, textually BELOW the class's own file line, but
// its file is `include`d FIRST inside `uvm_pkg`, so the name is already in
// scope.  This arm reproduces that shape (a typedef whose declaration LINE is
// larger than the using class's), plus a same-file typedef, a cross-package
// one (qualified and wildcard-imported) and a class-scope one.
package Late7;
  import Early3::*;
  `include "g136_b_order_inc.svh"

  typedef struct packed { bit [1:0] aa; bit [1:0] bb; } fwd_range_ps;

  class UsesLater9;
    inc_range_ps         b01_incLater;  // declared at a LARGER file line
    inc_loose_us         b02_incUs;
    inc_tone_e           b03_incEnum;
    fwd_range_ps         b04_sameFile;
    Early3::PRE_RANGE_PS b05_xpkgQual;
    PRE_RANGE_PS         b06_xpkgWild;
    typedef struct packed { bit [12:0] inA; bit [12:0] inB; } inClass_ps;
    inClass_ps           b07_inClass;
  endclass

  class UsesEarlier4;
    fwd_range_ps b08_before;
    inc_loose_us b09_beforeUs;
  endclass
endpackage

package Early3;
  typedef struct packed { bit [4:0] fst; bit [4:0] snd; } PRE_RANGE_PS;
  class Consumer21;
    PRE_RANGE_PS b10_ownpkg;
  endclass
endpackage

module btop;
  Late7::UsesLater9   u9;
  Late7::UsesEarlier4 u4;
  Early3::Consumer21  c21;
  initial begin u9 = new(); u4 = new(); c21 = new(); end
endmodule
