// r10v194 arm A — THE EXPLICIT-IMPORT CLONE AXIS.
//
// r10uvm194's fence reads `pkgImportCloneTfs16`, which TaskFuncEmit.cpp:6682
// populates ONLY under `pkgImportCloneEmit` — the WILDCARD import clone.
// StmtEmit.cpp:3383 says so in as many words ("`pkgImportCloneEmit` covers only
// the WILDCARD ones"), and § localBlockStmtSelBinds122's own clone fence one
// function away is the BROADER `pkgImportCloneEmit || importCloneEmit ||
// importCopyTsInst`.  If an EXPLICIT `import p::C;` clone of an out-of-body
// class method reaches § classRetNameDefViewNoBind37 with a select-bound return
// name, the r10uvm194 exemption fires on a listing the § 122 half fences out.
// This arm scores that against a REAL Surelog golden.
//
// The WILDCARD copy of the identical shape is the in-arm control.
package va194_src;
  class VA194;
    extern function string va_out();
  endclass
  function string VA194::va_out();
    int i; i=0;
    va_out = {va_out," "};
    va_out[i] = 8'h41;
  endfunction
  function string va_free();
    int i; i=0;
    va_free = {va_free," "};
    va_free[i] = 8'h42;
  endfunction
endpackage

// (1) EXPLICIT import of the class only.
package va194_expl;
  import va194_src::VA194;
  function int va_drive1();
    VA194 h = new();
    string a1 = h.va_out();
    return a1.len();
  endfunction
endpackage

// (2) EXPLICIT import of the free function only.
package va194_explf;
  import va194_src::va_free;
  function int va_drive2();
    string a2 = va_free();
    return a2.len();
  endfunction
endpackage

// (3) WILDCARD control — the shape the pass already fenced and measured.
package va194_wild;
  import va194_src::*;
  function int va_drive3();
    VA194 h = new();
    string a3 = h.va_out();
    string a4 = va_free();
    return a3.len() + a4.len();
  endfunction
endpackage

module va194_top;
  import va194_expl::*;
  import va194_explf::*;
  import va194_wild::*;
  int r1, r2, r3;
  initial begin
    r1 = va_drive1();
    r2 = va_drive2();
    r3 = va_drive3();
  end
endmodule
