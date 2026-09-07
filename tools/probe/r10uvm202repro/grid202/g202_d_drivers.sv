// r10uvm202 arm D — WHICH CLONE DRIVER, AND WHICH IMPORTER.
// `importCopyTsInst` names THREE clone drivers and this law's gate takes only
// one of them (§ clsScopedTdLocalCloneIsClassMethodOnly198v).  This arm puts
// all of them in one golden: the out-of-body CLASS METHOD reached by a package
// WILDCARD import (the law), the same method reached by an EXPLICIT item
// import, a package FREE SUBROUTINE cloned both ways (§ 198v's own residue),
// an IN-BODY class method (never cloned), and MODULE / INTERFACE / PROGRAM
// importers, which share the home subroutine instead of cloning it.
package quarry202d;
  class Plain202d;
    int lode202d;
  endclass
  typedef Plain202d pkgCls202d;
  typedef int       pkgInt202d;      // CONTROL

  class Adit202d;
    extern function void oob202d();
    function void inbody202d();      // NEVER cloned
      pkgCls202d dInbody202d;
      dInbody202d = null;
    endfunction
  endclass

  function void Adit202d::oob202d();
    pkgCls202d dOob202d;             // the LAW's cell
    pkgInt202d dOobInt202d;          // CONTROL
    begin
      pkgCls202d dOobBlk202d;
      dOobBlk202d = null;
    end
    dOob202d = null;
    dOobInt202d = 0;
  endfunction

  function void free202d();          // a package FREE subroutine
    pkgCls202d dFree202d;
    pkgInt202d dFreeInt202d;
    dFree202d = null;
    dFreeInt202d = 0;
  endfunction
endpackage

package pwild202d;                   // WILDCARD importer — the law's driver
  import quarry202d::*;
  class Flume202d;
    function void race202d();
      Adit202d gate202d;
      gate202d = null;
    endfunction
  endclass
endpackage

package pexp202d;                    // EXPLICIT-ITEM importer
  import quarry202d::free202d;
  import quarry202d::Adit202d;
  class Weir202d;
    function void sluice202d();
      Adit202d gate202d;
      gate202d = null;
    endfunction
  endclass
endpackage

module modimp202d;                   // MODULE importer: SHARES, never clones
  import quarry202d::*;
  initial begin
    Adit202d m202d;
    m202d = null;
  end
endmodule

interface ifimp202d;                 // INTERFACE importer
  import quarry202d::*;
  Adit202d i202d;
endinterface

program prgimp202d;                  // PROGRAM importer
  import quarry202d::*;
  initial begin
    Adit202d p202d;
    p202d = null;
  end
endprogram
