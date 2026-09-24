// r10uvm198 arm A — WHERE THE TYPEDEF IS DECLARED.
// One real Surelog golden decides, in ONE file and BOTH views, whether the
// clone-body local's degradation follows the typedef's DECLARING SCOPE (a
// class) or its KIND (an aggregate), and whether the HOME's own copies stay
// resolved.  Every cell has a control declared beside it in the SAME body —
// § 36's method note ("a control per law, in the same golden, every time").
package quarry198;
  typedef struct { int lode198; string seam198; } pkgSt198;   // CONTROL: package STRUCT
  typedef int pkgInt198;                                       // CONTROL: package INT
  class Adit198;
    typedef struct { int shaft198; string drift198; } clsSt198;  // the LAW's type
    typedef int clsInt198;                                       // class INT
    extern function void winze198(pkgInt198 collar198);
    function void inbody198();                     // NEVER cloned (in-body)
      clsSt198 inbodyCls198;
      inbodyCls198.shaft198 = 1;
    endfunction
  endclass
  function void Adit198::winze198(pkgInt198 collar198);
    clsSt198  tfCls198;        // tf-item local, CLASS-scope struct
    clsInt198 tfClsInt198;     // tf-item local, CLASS-scope int
    pkgSt198  tfPkg198;        // CONTROL: package struct
    pkgInt198 tfPkgInt198;     // CONTROL: package int
    begin
      clsSt198  blkCls198;     // BLOCK-item local, CLASS-scope struct (the head shape)
      clsInt198 blkClsInt198;  // BLOCK-item local, CLASS-scope int
      pkgSt198  blkPkg198;     // CONTROL: package struct
      pkgInt198 blkPkgInt198;  // CONTROL: package int
      blkCls198.shaft198 = collar198;
      blkClsInt198 = 0;
      blkPkg198.lode198 = 0;
      blkPkgInt198 = 0;
    end
    tfCls198.shaft198 = 0;
    tfClsInt198 = 0;
    tfPkg198.lode198 = 0;
    tfPkgInt198 = 0;
  endfunction
endpackage
package sluice198;
  import quarry198::*;
  class Flume198;
    function void race198();
      Adit198 gate198;
      gate198 = null;
    endfunction
  endclass
endpackage
