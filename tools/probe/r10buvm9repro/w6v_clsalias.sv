// vbuvm9 w6 — the OVER-FIRE hunt: CLASS-scope typedefs that golden STAMPS.
// w5 showed golden gives a class-scope ALIAS OF A PACKAGE typedef the ELAB
// package.  Enumerate that shape over all four reference sites plus the
// fences, looking for any cell where PRISTINE already equals golden.
package w6p;
  class oc; int a; endclass
  typedef struct { int a; } b_s;
  typedef enum { WX, WY } b_e;
  typedef oc b_c;

  class w6k;
    typedef w6p::b_s n1_s;   // oob NESTED-block local
    typedef w6p::b_s n2_s;   // oob TOP-level body local
    typedef w6p::b_s n3_s;   // oob RETURN
    typedef w6p::b_s n4_s;   // oob FORMAL
    typedef w6p::b_s n5_s;   // IN-BODY local
    typedef w6p::b_s n6_s;   // class MEMBER only
    typedef w6p::b_s n7_s;   // referenced NOWHERE
    typedef w6p::b_e n8_e;   // enum, oob nested local
    typedef w6p::b_c n9_c;   // class, oob nested local
    typedef w6p::b_s n10_s;  // package-function nested local
    n6_s m_n6;
    extern function void f1(int k);
    extern function void f2();
    extern function n3_s f3();
    extern function void f4(n4_s v);
    function void f5(); n5_s v; v.a = 1; endfunction
    extern function void f8(int k);
    extern function void f9(int k);
  endclass
  function void w6k::f1(int k); if (k) begin n1_s v; v.a = 1; end endfunction
  function void w6k::f2(); n2_s v; v.a = 1; endfunction
  function w6k::n3_s w6k::f3(); n3_s r; r.a = 1; return r; endfunction
  function void w6k::f4(n4_s v); endfunction
  function void w6k::f8(int k); if (k) begin n8_e v; v = WX; end endfunction
  function void w6k::f9(int k); if (k) begin n9_c v; v = null; end endfunction
  function void g10(int k); if (k) begin w6k::n10_s v; v.a = 1; end endfunction
endpackage
