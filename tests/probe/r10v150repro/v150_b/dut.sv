// r10v150 arm B — MACRO-EXPANDED chain vs the SAME chain written inline, and a
// PARENTHESISED receiver.  If the law is real the macro cell and the inline
// cell must render identically (modulo the macro's own line/col).
package mv2;
  class Bag2;
    int v = 4;
    function int rd(int k); return v + k; endfunction
    function int nil();     return v;     endfunction
  endclass
  class Mk2;
    extern static function Bag2 ob();
  endclass
  function Bag2 Mk2::ob(); Bag2 b = new(); return b; endfunction
  function Bag2 bfree(); Bag2 b = new(); return b; endfunction
  function Bag2 bfree1(int a); Bag2 b = new(); b.v = a; return b; endfunction
endpackage

`define CHAIN(N)  Mk2::ob().rd(N)
`define BCHAIN(N) bfree().rd(N)
`define ROOTONLY  Mk2::ob()

module TOPV2;
  import mv2::*;
  int z1,z2,z3,z4,z5,z6;
  function int m1(); return `CHAIN(11);           endfunction  // macro, scoped root
  function int m2(); return Mk2::ob().rd(11);     endfunction  // inline, same text
  function int m3(); return `BCHAIN(12);          endfunction  // macro, bare root
  function int m4(); return bfree().rd(12);       endfunction  // inline, same text
  function automatic Bag2 m5(); return `ROOTONLY; endfunction  // macro, NO chain (control)
  function int m6(); return bfree1(13).rd(14);    endfunction  // bare root WITH an argument
  function int m7(); return bfree1(15).nil();     endfunction  // bare root, 0-arg method
  initial begin z1=m1(); z2=m2(); z3=m3(); z4=m4(); z5=m6(); z6=m7(); end
endmodule
