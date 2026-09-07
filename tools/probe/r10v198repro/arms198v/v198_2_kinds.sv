// r10v198 arm 2 — KINDS, with a PACKAGE-scope control of the SAME kind beside
// every class-scope cell.  The law claims the DECLARING SCOPE decides and the
// KIND does not; every kind here is a separate opportunity to refute that.
package quarryV2;
  typedef enum { pE0V2, pE1V2 } pkgEnV2;
  typedef union packed { bit [7:0] ua; byte ub; } pkgUnV2;
  typedef string pkgStrV2;
  typedef int pkgIntV2;
  typedef bit [7:0] pkgVecV2;
  typedef real pkgRealV2;
  typedef struct { int za; } pkgStV2;
  class HoistV2;
    typedef enum { cE0V2, cE1V2 } clsEnV2;
    typedef union packed { bit [7:0] ca; byte cb; } clsUnV2;
    typedef string clsStrV2;
    typedef int clsIntV2;
    typedef bit [7:0] clsVecV2;
    typedef real clsRealV2;
    typedef pkgStV2 clsAliasV2;          // alias OF a package typedef
    typedef HoistV2 clsHandleV2;         // class-handle typedef
    typedef clsIntV2 clsChainV2;         // alias of a class typedef
    extern function void liftV2();
  endclass
  function void HoistV2::liftV2();
    clsEnV2     tfEnV2;
    clsUnV2     tfUnV2;
    clsStrV2    tfStrV2;
    clsIntV2    tfIntV2;
    clsVecV2    tfVecV2;
    clsRealV2   tfRealV2;
    clsAliasV2  tfAliasV2;
    clsHandleV2 tfHandleV2;
    clsChainV2  tfChainV2;
    pkgEnV2     tfPkgEnV2;
    pkgUnV2     tfPkgUnV2;
    pkgStrV2    tfPkgStrV2;
    pkgIntV2    tfPkgIntV2;
    pkgVecV2    tfPkgVecV2;
    pkgRealV2   tfPkgRealV2;
    begin
      clsEnV2     blkEnV2;
      clsUnV2     blkUnV2;
      clsStrV2    blkStrV2;
      clsIntV2    blkIntV2;
      clsVecV2    blkVecV2;
      clsRealV2   blkRealV2;
      clsAliasV2  blkAliasV2;
      clsHandleV2 blkHandleV2;
      pkgEnV2     blkPkgEnV2;
      pkgUnV2     blkPkgUnV2;
      pkgStrV2    blkPkgStrV2;
      pkgIntV2    blkPkgIntV2;
      blkEnV2 = cE0V2;      blkUnV2.ca = 0;    blkStrV2 = "x";
      blkIntV2 = 0;         blkVecV2 = 0;      blkRealV2 = 0.0;
      blkAliasV2.za = 0;    blkHandleV2 = null;
      blkPkgEnV2 = pE0V2;   blkPkgUnV2.ua = 0; blkPkgStrV2 = "y";
      blkPkgIntV2 = 0;
    end
    tfEnV2 = cE1V2;     tfUnV2.ca = 0;      tfStrV2 = "a";
    tfIntV2 = 0;        tfVecV2 = 0;        tfRealV2 = 0.0;
    tfAliasV2.za = 0;   tfHandleV2 = null;  tfChainV2 = 0;
    tfPkgEnV2 = pE1V2;  tfPkgUnV2.ua = 0;   tfPkgStrV2 = "b";
    tfPkgIntV2 = 0;     tfPkgVecV2 = 0;     tfPkgRealV2 = 0.0;
  endfunction
endpackage
package sluiceV2;
  import quarryV2::*;
  class ChuteV2;
    function void slideV2();
      HoistV2 hV2;
      hV2 = null;
    endfunction
  endclass
endpackage
