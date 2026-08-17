// vbuvm9 w1 — PACKAGE-scope typedef whose object is a class_typespec
// (the PkgClassTs cell the law REMOVES the stamp on), over every reach.
package w1p;
  class pc; int a; endclass
  class pcp #(type T = int); T a; endclass

  typedef pc e1_t;   // oob NESTED-block local
  typedef pc e2_t;   // oob TOP-level body local
  typedef pc e3_t;   // oob RETURN type
  typedef pc e4_t;   // oob FORMAL
  typedef pc e5_t;   // IN-BODY local
  typedef pc e6_t;   // class MEMBER only
  typedef pc e7_t;   // referenced NOWHERE
  typedef pc e8_t;   // package function NESTED local
  typedef pc e9_t;   // package function TOP local
  typedef pc e10_t;  // package-scope VARIABLE only
  typedef pcp#(int) e11_t; // specialization, oob nested local
  typedef pc e12_t;  // oob method formal AND nested local (two reaches)

  e10_t g_v10;

  class w1k;
    e6_t m_e6;
    extern function void f1(int k);
    extern function void f2();
    extern function e3_t f3();
    extern function void f4(e4_t v);
    function void f5(); e5_t v; v = null; endfunction
    extern function void f11(int k);
    extern function void f12(e12_t v, int k);
  endclass
  function void w1k::f1(int k); if (k) begin e1_t v; v = null; end endfunction
  function void w1k::f2(); e2_t v; v = null; endfunction
  function w1p::e3_t w1k::f3(); e3_t r; r = null; return r; endfunction
  function void w1k::f4(e4_t v); endfunction
  function void w1k::f11(int k); if (k) begin e11_t v; v = null; end endfunction
  function void w1k::f12(e12_t v, int k); if (k) begin e12_t w; w = v; end endfunction

  function void g8(int k); if (k) begin e8_t v; v = null; end endfunction
  function void g9(); e9_t v; v = null; endfunction
endpackage

module w1m;
  import w1p::*;
  // a MODULE function's nested-block local of a package class typedef
  function void mf(int k); if (k) begin w1p::e1_t v; v = null; end endfunction
  initial mf(1);
endmodule
