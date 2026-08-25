// r10v150 arm E — EXOTIC CONTEXTS: a class constructor, a constraint, an
// immediate assert, a foreach bound, a concatenation, an assignment pattern,
// a generate block, named root arguments, and a function called WITHOUT
// parentheses after a root call.
package ep5;
  class Pt5;
    int x = 1;
    rand int rv;
    function int gx(int a);   return x + a; endfunction
    function int g0();        return x;     endfunction
    function int nm(int aa, int bb); return aa*bb + x; endfunction
  endclass
  class Fac5;
    extern static function Pt5 fs();
    extern static function Pt5 fn(int aa, int bb);
  endclass
  function Pt5 Fac5::fs();               Pt5 p = new(); return p; endfunction
  function Pt5 Fac5::fn(int aa, int bb); Pt5 p = new(); p.x = aa+bb; return p; endfunction
  function Pt5 efree(); Pt5 p = new(); return p; endfunction

  class Ctor5;
    int c1, c2;
    function new();                       // a CONSTRUCTOR home
      c1 = Fac5::fs().gx(11);
      c2 = efree().gx(12);
    endfunction
  endclass

  class Cons5;
    rand int rr;
    constraint cc { rr < Fac5::fs().gx(13); }     // a CONSTRAINT home
  endclass
endpackage

module TOPE5;
  import ep5::*;
  int e1,e2,e3,e4,e5,e6;
  int av[3];
  int cat;
  Ctor5 k;
  Cons5 s;
  // named arguments on the ROOT call
  function int x1(); return Fac5::fn(.aa(21), .bb(22)).gx(23); endfunction
  // a function called WITHOUT parentheses after a root call
  function int x2(); return Fac5::fs().g0; endfunction
  // a chain inside a CONCATENATION
  function int x3(); return {Fac5::fs().gx(31), efree().gx(32)}; endfunction
  // a chain as a foreach body operand
  function int x4(); int t = 0; foreach (av[i]) t += Fac5::fs().gx(i); return t; endfunction
  // a chain inside an ASSIGNMENT PATTERN
  function int x5(); int p[2]; p = '{Fac5::fs().gx(41), efree().gx(42)}; return p[0]+p[1]; endfunction
  // a chain inside an immediate ASSERT
  task x6(); assert (Fac5::fs().gx(51) > 0); endtask
  // three-argument named-free root, statement position
  task x7(); Fac5::fn(61,62).gx(63); endtask
  generate                                // a GENERATE-block home
    if (1) begin : gblk
      function int x8(); return Fac5::fs().gx(71); endfunction
    end
  endgenerate
  initial begin
    k = new(); s = new();
    e1 = x1(); e3 = x3(); e4 = x4(); e5 = x5(); x6(); x7(); e6 = gblk.x8();
  end
endmodule
