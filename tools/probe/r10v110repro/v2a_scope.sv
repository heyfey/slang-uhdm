// r10v110 arm v2a — SCOPE-QUALIFIED receivers: instance-qualified static
// property, class-scoped static property, package-scoped handle, imported
// handle, plus the undotted controls.
package Wk2;
  class Cellz;
    int   dyn[];
    byte  dyn2[];
    Cellz kidz;
    int   flat;
  endclass
  class Boxz;
    Cellz c1;
    static Cellz STAT2;
  endclass
  Cellz PKG_H2;
  int   PKG_A2[];
endpackage

module v2atop;
  import Wk2::*;
  initial begin
    Boxz bx;
    bx = new(); bx.c1 = new(); Boxz::STAT2 = new(); PKG_H2 = new();
    bx.STAT2.dyn      = new [2];   // v2a01 instance-qualified STATIC prop (in law)
    Boxz::STAT2.dyn2  = new [3];   // v2a02 class-scoped STATIC prop
    Wk2::PKG_H2.dyn   = new [4];   // v2a03 package-scoped handle, dotted
    Wk2::PKG_A2       = new [5];   // v2a04 package-scoped array, UNDOTTED (control)
    PKG_H2.dyn2       = new [6];   // v2a05 imported handle, dotted        (in law)
    PKG_A2            = new [7];   // v2a06 imported array, UNDOTTED       (control)
    bx.c1.kidz        = new ();    // v2a07 class new through a dot        (control)
    bx.c1.flat        = 1;         // v2a08 plain through a dot            (control)
    Boxz::STAT2.flat  = 2;         // v2a09 class-scoped plain             (control)
    Wk2::PKG_H2.flat  = 3;         // v2a10 package-scoped plain           (control)
  end
endmodule
