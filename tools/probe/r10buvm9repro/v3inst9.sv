// r10buvm9 v3 — the PACKAGE-scope typedef half.  Our ELAB uvm_pkg listing has
// 9 entries stamped with the DEF package; every one is a package typedef
// REFERENCED from an out-of-body class method (formal, return, body local or
// nested-block local).  The shared object bound by such a reference is the
// ELABORATED listing entry, so the stamp corrupts the elab listing.
package r9;

  typedef struct { int a; } c1_s;   // referenced: out-of-body FORMAL
  typedef struct { int a; } c2_s;   // referenced: out-of-body RETURN
  typedef struct { int a; } c3_s;   // referenced: out-of-body top-level local
  typedef struct { int a; } c4_s;   // referenced: out-of-body NESTED local
  typedef struct { int a; } c5_s;   // referenced: IN-BODY local
  typedef struct { int a; } c6_s;   // referenced: class MEMBER only
  typedef struct { int a; } c7_s;   // referenced: package FUNCTION local
  typedef struct { int a; } c8_s;   // referenced NOWHERE (fence)
  typedef enum { E9X, E9Y } c9_e;   // ENUM, out-of-body nested local
  typedef struct { int a; } c10_s;  // referenced: package function NESTED local

  class k9;
    c6_s m_c6;
    extern function void f1(c1_s v);
    extern function c2_s f2();
    extern function void f3();
    extern function void f4(int k);
    function void f5(); c5_s v; v.a = 1; endfunction
    extern function void f9(int k);
  endclass
  function void k9::f1(c1_s v); endfunction
  function r9::c2_s k9::f2(); c2_s r; r.a = 1; return r; endfunction
  function void k9::f3(); c3_s v; v.a = 1; endfunction
  function void k9::f4(int k); if (k) begin c4_s v; v.a = 1; end endfunction
  function void k9::f9(int k); if (k) begin c9_e v; v = E9X; end endfunction

  function void g7(); c7_s v; v.a = 1; endfunction
  function void g10(int k); if (k) begin c10_s v; v.a = 1; end endfunction

endpackage
