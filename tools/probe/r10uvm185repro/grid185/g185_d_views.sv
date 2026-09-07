// r10uvm185 grid arm D — THE LISTING/VIEW AXIS.
//
// A package's methods are emitted in MORE than one listing: the package's own
// DEF view, its ELABORATED view, the class's own listing, and — through a
// wildcard import — a CLONE inside the importing package.  This is the axis on
// which § ownNamedAliasRetIsRefVar177 and r10uvm170's R1 both split, so it must
// be scored here rather than assumed: the law must give the SAME answer in
// every listing of one prototype, and must not move a single cell of the
// definition listing in any of them.
//
// Both directions of the ORDER term are present again (`ad185` before
// `du185`, `zd185` after) so a listing that agrees is not mistaken for a
// listing that was never asked.
package pd185;

  class ad185;
    typedef struct { int a; } ad_rec;
    typedef enum { DA0, DA1 } ad_enum;
  endclass

  class zd185;
    typedef struct { int z; } zd_rec;
  endclass

  class du185;
    typedef enum { DO0, DO1 } du_own;
    extern function ad185::ad_rec  d_early_rec();
    extern function ad185::ad_enum d_early_enum();
    extern function zd185::zd_rec  d_late_rec();
    extern function du_own         d_own_bare();
    function ad185::ad_rec         d_inbody_rec(); endfunction
  endclass

  function ad185::ad_rec  du185::d_early_rec();  endfunction
  function ad185::ad_enum du185::d_early_enum(); endfunction
  function zd185::zd_rec  du185::d_late_rec();   endfunction
  function pd185::du185::du_own du185::d_own_bare(); endfunction

endpackage

// a WILDCARD IMPORT: the importing package carries a CLONE of every listing
// above, compiled by a component that is not the home package.
package pd185_imp;
  import pd185::*;
  class dimp185;
    function pd185::du185 mk(); return null; endfunction
  endclass
endpackage

module top185d;
  import pd185::*;
  pd185::du185 u;
  pd185_imp::dimp185 i;
  initial begin
    u = new();
    i = new();
  end
endmodule
