// r10v110 arm v2d — the this./super. FENCES carrying SELECTS and deeper chains,
// against the implicit-this cells that must stay in law.
package Tk2;
  class Bse;
    Bse  barr[2];
    Bse  bh;
    byte bdyn[];
    int  bs;
  endclass
  class Drv extends Bse;
    Bse  dh;
    Bse  darr[2];
    byte ddyn[];
    int  ds;
    function void f2(int q);
      dh = new(); dh.bh = new(); darr[0] = new(); darr[1] = new();
      barr[0] = new(); barr[1] = new();
      this.darr[0].bdyn  = new [q];   // v2d01 this.<sel>.<m>   (FENCE)
      super.barr[1].bdyn = new [q];   // v2d02 super.<sel>.<m>  (FENCE)
      this.ddyn          = new [q];   // v2d03 this.<prop>      (FENCE)
      super.bdyn         = new [q];   // v2d04 super.<prop>     (FENCE)
      darr[1].bdyn       = new [q];   // v2d05 implicit-this sel (in law)
      ddyn               = new [q];   // v2d06 implicit-this undotted (control)
      dh.bh              = new ();    // v2d07 class new         (control)
      dh.bh.bdyn         = new [q];   // v2d08 TWO dots          (in law)
      this.dh.bh.bdyn    = new [q];   // v2d09 this. + two dots  (FENCE)
      this.ds            = q;         // v2d10 this.<scalar>     (control)
      super.bs           = q;         // v2d11 super.<scalar>    (control)
    endfunction
  endclass
endpackage
module v2dtop;
  import Tk2::*;
  Drv dv2;
  initial begin dv2 = new(); dv2.f2(3); end
endmodule
