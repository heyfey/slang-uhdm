// Over-fire check for the package-subroutine rule: is "class declared in the
// SAME design component" the discriminator, or only packages?  Cover MODULE
// subroutines and $unit classes in both hosts, plus a nested block inside a
// package subroutine.
class UnitC;
  int u;
endclass

package pk;
  class PkgC;
    int p;
  endclass
  // A: package function local, class in SAME package (expect UNNAMED)
  function void fSame();
    PkgC a;
    a = new();
  endfunction
  // C: nested block inside a package function, class in SAME package
  function void fBlock();
    begin
      PkgC c;
      c = new();
    end
  endfunction
endpackage

module top;
  import pk::*;
  class ModC;
    int m;
  endclass
  // D: module function local, class in SAME module
  function void gSame();
    ModC d;
    d = new();
  endfunction
  // E: module function local, class in $unit
  function void gUnit();
    UnitC e;
    e = new();
  endfunction
  // F: module function local, class in a PACKAGE via wildcard import
  function void gPkg();
    PkgC f;
    f = new();
  endfunction
  // G: module-scope variable, class in SAME module
  ModC g;
  initial;
endmodule
