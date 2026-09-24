// r10v150 arm G — DECLARATION-INITIALISER homes the grids never reach:
// a class MEMBER initialiser, a module variable initialiser, a continuous
// ASSIGN, a module-instance PORT connection, and a package variable.
package gpk;
  class Val7;
    int t = 9;
    function int sc(int n); return t + n; endfunction
  endclass
  class Src7;
    extern static function Val7 os();
  endclass
  function Val7 Src7::os(); Val7 v = new(); return v; endfunction
  function Val7 gfree(); Val7 v = new(); return v; endfunction

  class Memb7;
    int mi = Src7::os().sc(11);      // a CLASS MEMBER initialiser
    int mb = gfree().sc(12);         // ditto, bare root
  endclass
  int pkgv = Src7::os().sc(13);      // a PACKAGE variable initialiser
endpackage

module leafG(input int pin, output int pout);
  assign pout = pin + 1;
endmodule

module TOPG;
  import gpk::*;
  int mv1 = Src7::os().sc(21);       // a MODULE variable initialiser
  int mv2 = gfree().sc(22);
  int aw, bw;
  always_comb aw = Src7::os().sc(31);   // a procedural continuous-ish home
  always_comb bw = gfree().sc(32);
  int po;
  int pw; always_comb pw = Src7::os().sc(41);
  leafG u_leaf(.pin(pw), .pout(po));
  Memb7 mm;
  initial mm = new();
endmodule
