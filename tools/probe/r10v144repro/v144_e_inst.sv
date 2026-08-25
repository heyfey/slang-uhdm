// r10v144 (VERIFIER) arm E — REACHABILITY, INSTANCE COUNT and SPECIALIZATION
// COUNT as candidate distinguishers for BOTH halves of r10uvm144, plus the
// cross-class leakage test for `ctorUnlistedBid144` (which is keyed on a slang
// SYMBOL ADDRESS and is never cleared): eight classes reuse the SAME local
// NAMES, half of them behind an eaten first body element and half not.
package q144e;
  class BE;
    extern static function void si(input int a);
  endclass
  function void BE::si(input int a); endfunction

  // e01/e02 the SAME local name `v`, one eaten (no ports) one not (ports)
  class E01; int w; function new();      int v; BE::si(v); w = 1; endfunction endclass
  class E02; int w; function new(int a); int v; BE::si(v); w = a; endfunction endclass
  // e03/e04 the same again, ordinary methods (never eaten)
  class E03; int w; function void m();   int v; BE::si(v); w = 3; endfunction endclass
  class E04; int w; task t();            int v; BE::si(v); w = 4; endtask endclass
  // e05 a NAMED block local called `v` in an in-body method (must stay BARE)
  class E05; int w; function void m(); begin : nb05 int v; BE::si(v); end w = 5; endfunction endclass
  // e06 an UNNAMED block local called `v` at depth 0 (must BIND)
  class E06; int w; function void m(); begin int v; BE::si(v); end w = 6; endfunction endclass
  // e07 a generic class, TWO explicit specializations, eaten ctor local
  class E07 #(int N = 1); int w; function new(); int v; BE::si(v); w = N; endfunction endclass
  typedef E07#(2) E07b;
  typedef E07#(3) E07c;
  // e08 a class that is never referenced at all
  class E08; int w; function new(); int v; BE::si(v); w = 8; endfunction endclass
endpackage

// ONE instance
module m144e1;
  import q144e::*;
  E01 h1; E07b s1;
  initial begin h1 = new(); s1 = new(); end
endmodule
// THREE instances of the SAME child, which itself holds the head shape
module child144e;
  import q144e::*;
  class CE; int w; function new(); int v; BE::si(v); w = 1; endfunction
    function void m(); begin : cnb int u; BE::si(u); end w = 2; endfunction endclass
  CE c;
  initial begin c = new(); c.m(); end
endmodule
module top144e;
  child144e i0(); child144e i1(); child144e i2();
endmodule
