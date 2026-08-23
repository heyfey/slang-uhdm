// r10v110 arm v7 — the this./super. FENCE under TIMING CONTROLS, in an
// out-of-body method and a constructor, plus a SHADOWED base name and a
// nested-struct receiver.
package Zz7;
  typedef struct { int inner7[]; int t7; } sub7;
  typedef struct { sub7 s7; byte o7[]; } out7;
  class B7;
    byte bb7[];
    B7   bn7;
    int  bs7;
  endclass
  class D7 extends B7;
    byte dd7[];
    D7   dn7;
    out7 st7;
    int  ds7;
    logic ck7;
    function new();
      this.dd7 = new [1];        // v7i01 this. in CONSTRUCTOR      (FENCE)
      dn7 = new();
      dn7.dd7  = new [2];        // v7i02 plain in constructor      (in law)
    endfunction
    task automatic tt7();
      #1 this.dd7    = new [3];  // v7i03 DELAYED this.             (FENCE)
      #1 super.bb7   = new [4];  // v7i04 DELAYED super.            (FENCE)
      #1 dn7.bb7     = new [5];  // v7i05 DELAYED plain             (in law)
      @(posedge ck7) this.dd7 = new [6];   // v7i06 EVENT this.     (FENCE)
      @(posedge ck7) dn7.dd7  = new [7];   // v7i07 EVENT plain     (in law)
      st7.o7         = new [8];  // v7i08 nested-struct member      (in law)
      st7.s7.inner7  = new [9];  // v7i09 struct-in-struct member   (in law)
      this.st7.o7    = new [10]; // v7i10 this. + struct member     (FENCE)
    endtask
    extern task oob7();
  endclass
  task D7::oob7();
    this.dd7  = new [11];        // v7i11 this. OUT-OF-BODY         (FENCE)
    super.bb7 = new [12];        // v7i12 super. OUT-OF-BODY        (FENCE)
    dn7.dd7   = new [13];        // v7i13 plain OUT-OF-BODY         (in law)
  endtask
endpackage

module v7top;
  import Zz7::*;
  D7 shadow7;                    // module-level name
  initial begin
    D7 shadow7;                  // LOCAL shadowing the module-level name
    shadow7 = new();
    shadow7.dd7 = new [14];      // v7i14 SHADOWED base name        (in law)
    shadow7.ds7 = 14;            // v7i15 control
  end
  initial begin
    shadow7 = new();
    shadow7.bb7 = new [15];      // v7i16 module-level base name    (in law)
  end
endmodule
