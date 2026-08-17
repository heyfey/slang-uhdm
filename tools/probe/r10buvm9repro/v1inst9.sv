// r10buvm9 v1 — the CLASS-SCOPE typedef grid: which of a class's own typedefs
// does golden give a vpiInstance, and which does our emitter stamp with the
// DEF package?  Every cell is one class-scope typedef reached a different way.
package p9;

  // a1: enum typedef, member var only, NO out-of-body method at all
  class a1;
    typedef enum { A1X, A1Y } a1_e;
    a1_e m_a1;
  endclass

  // a2: enum typedef, used as an OUT-OF-BODY method's RETURN type (qualified)
  class a2;
    typedef enum { A2X, A2Y } a2_e;
    a2_e m_a2;
    extern function a2_e f2();
  endclass
  function a2::a2_e a2::f2(); return A2X; endfunction

  // a3: enum typedef, used as an out-of-body method BODY LOCAL, BARE name
  class a3;
    typedef enum { A3X, A3Y } a3_e;
    extern function void f3();
  endclass
  function void a3::f3(); a3_e v; v = A3X; endfunction

  // a4: struct typedef, out-of-body method BODY LOCAL, BARE name
  class a4;
    typedef struct { int a; } a4_s;
    extern function void f4();
  endclass
  function void a4::f4(); a4_s v; v.a = 1; endfunction

  // a5: struct typedef, out-of-body method body local, QUALIFIED name
  class a5;
    typedef struct { int a; } a5_s;
    extern function void f5();
  endclass
  function void a5::f5(); a5::a5_s v; v.a = 1; endfunction

  // a6: struct typedef, IN-BODY method body local, bare name
  class a6;
    typedef struct { int a; } a6_s;
    function void f6(); a6_s v; v.a = 1; endfunction
  endclass

  // a7: enum typedef, in-body method body local, bare name
  class a7;
    typedef enum { A7X } a7_e;
    function void f7(); a7_e v; v = A7X; endfunction
  endclass

  // a8: struct typedef, out-of-body method FORMAL, bare name
  class a8;
    typedef struct { int a; } a8_s;
    extern function void f8(a8_s v);
  endclass
  function void a8::f8(a8_s v); endfunction

  // a9: struct typedef, class member QUEUE of it + out-of-body body local
  class a9;
    typedef struct { int a; } a9_s;
    a9_s m_q[$];
    extern function void f9();
  endclass
  function void a9::f9(); a9_s v; v.a = 1; m_q.push_back(v); endfunction

endpackage
