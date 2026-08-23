// r10uvm110 arm a3 — THE FENCES.  Shapes the law must DECLINE, plus the
// hierarchical / package receivers it was never measured on.
package pkg110C;
  typedef int iv110[];
  int GLOBALARR110[];
  class Cell110;
    iv110 v;
    Cell110 kid;
    int    z;
  endclass
  Cell110 PKGH110;
endpackage

module deep110;
  import pkg110C::*;
  Cell110 dh;
  int      w9;
  initial begin
    dh = new();
    w9 = 3;
    dh.v            = new [w9];    // f01 in-module class member (in law)
    pkg110C::GLOBALARR110 = new [2]; // f02 package var, UNDOTTED (control)
    PKGH110         = new ();      // f03 package handle class new (control)
    dh.kid          = new ();      // f04 dotted class new (control)
    dh.z            = w9;          // f05 dotted plain (control)
  end
endmodule

module hier110;
  deep110 D();
  int hv110[];
  initial begin
    hv110       = new [4];         // f06 UNDOTTED local (control)
    D.dh.v      = new [5];         // f07 CROSS-INSTANCE hierarchical receiver
    D.w9        = 6;               // f08 hierarchical plain (control)
  end
endmodule

// this/super fences, in a class hierarchy, in several homes
package pkg110D;
  class Base110;
    byte bb[];
    Base110 nx;
    function void inbase(int q);
      bb      = new [q];           // f09 IMPLICIT this (bare property) — in law? (undotted)
      nx      = new ();            // f10 bare handle class new (control)
    endfunction
  endclass
  class Der110 extends Base110;
    byte cc[];
    Der110 dn;
    function void inder(int q);
      this.cc      = new [q];      // f11 this.<prop> new[]  (FENCE)
      super.bb     = new [q];      // f12 super.<prop> new[] (FENCE)
      this.dn      = new ();       // f13 this.<handle> class new (FENCE)
      dn = new(); dn.cc = new [2]; // f14 plain dotted (in law)
      this.dn.cc   = new [3];      // f15 this.<a>.<b> new[] (FENCE)
      this.z110    = q;            // f16 this.<scalar> plain (control)
    endfunction
    int z110;
  endclass
endpackage
