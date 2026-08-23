// r10v110 arm v2b — SELECTS around the dot: middle fixed / queue / assoc index,
// TRAILING index on the member, index on the base with a further dot, and the
// undotted / element-write controls.
package Sk2;
  class Cz;
    int  dv[];
    byte bv[];
    Cz   kid;
    int  fl;
  endclass
  class Bz;
    Cz   arr3[3];
    Cz   qz[$];
    Cz   mz[string];
    Cz   one;
    int  dd[][];
  endclass
endpackage

module v2btop;
  import Sk2::*;
  int ixv;
  initial begin
    Bz bb; Cz cc;
    bb = new(); cc = new(); ixv = 1;
    bb.arr3[0] = new(); bb.one = new(); bb.one.kid = new();
    bb.arr3[0].dv   = new [2];    // v2b01 middle FIXED index (literal)  (in law)
    bb.arr3[ixv].bv = new [3];    // v2b02 middle FIXED index (variable) (in law)
    bb.qz[0].dv     = new [4];    // v2b03 middle QUEUE index            (in law)
    bb.mz["k"].bv   = new [5];    // v2b04 middle ASSOC index            (in law)
    bb.dd[0]        = new [6];    // v2b05 TRAILING index on the member  (?)
    bb.one.kid.dv   = new [7];    // v2b06 TWO dots, no select           (in law)
    cc.dv           = new [8];    // v2b07 plain one-dot                 (in law)
    cc.dv[0]        = 9;          // v2b08 element write                 (control)
    bb.arr3[0].fl   = 10;         // v2b09 middle index, plain rhs       (control)
    bb.one.kid      = new ();     // v2b10 two dots, class new           (control)
  end
endmodule
