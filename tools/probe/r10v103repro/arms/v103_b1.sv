// r10v103 arm b1 — RECEIVER SHAPES x COMPONENT COUNT, statement position, one
// axis held constant: the argument goes through an UNSPECIALISED type
// parameter handle, so slang wraps the whole statement in a bad-expression
// shell.  MEASUREMENT ONLY.  LHS is always golden (Surelog).
package Vb1;

  class Leaf1;
    int uu;
    static int su;
    function void put(int aa); uu = aa; endfunction
    function void put3(int aa, int bb, int cc); uu = aa + bb + cc; endfunction
    function void put0(); uu = 1; endfunction
    function int  get(); return uu; endfunction
    static function void sput(int aa); su = aa; endfunction
  endclass

  class Mid1;
    Leaf1 slot;
    Leaf1 farm[4];
    function new(); slot = new(); endfunction
  endclass

  class Top1;
    Mid1 mid;
    function new(); mid = new(); endfunction
  endclass

  class Root1;
    Top1 tp1;
    function new(); tp1 = new(); endfunction
  endclass

  Mid1 gmid;

  class Base1;
    Mid1 bmid;
    function new(); bmid = new(); endfunction
    virtual function void vv(); endfunction
  endclass

  // -------- the shell factory: PT is never specialised --------
  class Shp1 #(type PT = int) extends Base1;
    Leaf1 el;
    Mid1  bo;
    Top1  cr;
    Root1 rt;
    Mid1  marr[4];
    PT    tp;
    int   kk;
    int   idxq[$];
    function new(); super.new(); el = new(); bo = new(); cr = new(); rt = new();
      foreach (marr[i]) marr[i] = new();
    endfunction
    function int ix(); return 1; endfunction

    // ---- component count, plain class-handle receiver ----
    function void C2();  el.put( tp.conv(kk) );                       endfunction
    function void C3();  bo.slot.put( tp.conv(kk) );                  endfunction
    function void C4();  cr.mid.slot.put( tp.conv(kk) );              endfunction
    function void C5();  rt.tp1.mid.slot.put( tp.conv(kk) );          endfunction
    // ---- this. receivers ----
    function void T2();  this.el.put( tp.conv(kk) );                  endfunction
    function void T3();  this.bo.slot.put( tp.conv(kk) );             endfunction
    // ---- super. receivers ----
    function void S3();  super.bmid.slot.put( tp.conv(kk) );          endfunction
    // ---- class static method ----
    function void ST();  Leaf1::sput( tp.conv(kk) );                  endfunction
    // ---- element-select receiver ----
    function void E3();  marr[2].slot.put( tp.conv(kk) );             endfunction
    function void E4();  marr[kk].slot.put( tp.conv(kk) );             endfunction
    // ---- index is itself a call ----
    function void I3();  marr[ix()].slot.put( tp.conv(kk) );          endfunction
    // ---- argument counts ----
    function void A0();  bo.slot.put0();                              endfunction
    function void A3();  bo.slot.put3( 1, tp.conv(kk), 3 );           endfunction
    function void AN();  el.put3( .aa(1), .bb(tp.conv(kk)), .cc(3) ); endfunction
    // ---- void'() cast ----
    function void V3();  void'( bo.slot.get() );                      endfunction
    function void V4();  void'( el.get() );                           endfunction
    // ---- chained call / trailing member ----
    function int  CH();  return bo.slot.get() + tp.conv(kk);          endfunction
  endclass

endpackage
