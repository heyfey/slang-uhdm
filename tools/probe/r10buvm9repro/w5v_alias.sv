// vbuvm9 w5 — CLASS-scoped typedefs that ALIAS a package typedef, package
// typedefs that alias a CLASS-scoped one, and alias CHAINS (the R1 family).
package w5p;
  class oc; int a; endclass
  typedef struct { int a; } p_s;      // package base
  typedef enum { PX, PY } p_e;
  typedef oc p_c;

  typedef p_s  p2_s;                  // pkg alias OF a pkg typedef (R1 shape)
  typedef p_e  p2_e;
  typedef p_c  p2_c;
  typedef p2_s p3_s;                  // two hops

  class w5k;
    typedef w5p::p_s  k_s;            // CLASS alias of a PACKAGE typedef
    typedef w5p::p_e  k_e;
    typedef w5p::p_c  k_c;
    typedef struct { int a; } own_s;
    typedef own_s own2_s;             // CLASS alias of a CLASS typedef
    extern function void f1(int k);
    extern function void f2(int k);
    extern function void f3(int k);
    extern function void f4(int k);
    extern function void f5(int k);
    extern function void f6(int k);
    extern function void f7(int k);
    extern function void f8(int k);
    extern function void f9(int k);
  endclass
  function void w5k::f1(int k); if (k) begin k_s v; v.a = 1; end endfunction
  function void w5k::f2(int k); if (k) begin k_e v; v = PX; end endfunction
  function void w5k::f3(int k); if (k) begin k_c v; v = null; end endfunction
  function void w5k::f4(int k); if (k) begin own2_s v; v.a = 1; end endfunction
  function void w5k::f5(int k); if (k) begin p2_s v; v.a = 1; end endfunction
  function void w5k::f6(int k); if (k) begin p2_e v; v = PX; end endfunction
  function void w5k::f7(int k); if (k) begin p2_c v; v = null; end endfunction
  function void w5k::f8(int k); if (k) begin p3_s v; v.a = 1; end endfunction
  function void w5k::f9(int k); if (k) begin own_s v; v.a = 1; end endfunction
endpackage

package w5q;
  class qc;
    typedef struct { int a; } q_s;    // class typedef in another package
  endclass
  typedef qc::q_s q_alias_s;          // PACKAGE alias of a CLASS typedef
  class w5qk;
    extern function void f(int k);
    extern function void g(int k);
  endclass
  function void w5qk::f(int k); if (k) begin q_alias_s v; v.a = 1; end endfunction
  function void w5qk::g(int k); if (k) begin qc::q_s v; v.a = 1; end endfunction
endpackage
