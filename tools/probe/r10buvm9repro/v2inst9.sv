// r10buvm9 v2 — the NESTED-BLOCK local: the shape uvm_pkg's three golden-NULL
// class typedefs are actually written in (`if(..) begin m_verbosity_setting
// setting; end` inside an OUT-OF-BODY method, 41181 / 41272 / 41444).
package q9;

  // b1: struct typedef, block-item local of an `if` block, OUT-OF-BODY method
  class b1;
    typedef struct { int a; } b1_s;
    extern function void f1(int k);
  endclass
  function void b1::f1(int k); if (k) begin b1_s v; v.a = 1; end endfunction

  // b2: same, FOREACH block
  class b2;
    typedef struct { int a; } b2_s;
    int q[$];
    extern function void f2();
  endclass
  function void b2::f2(); foreach (q[i]) begin b2_s v; v.a = i; end endfunction

  // b3: same, FORK block
  class b3;
    typedef struct { int a; } b3_s;
    extern function void f3();
  endclass
  function void b3::f3(); fork begin b3_s v; v.a = 1; end join_none endfunction

  // b4: same as b1 but an IN-BODY method
  class b4;
    typedef struct { int a; } b4_s;
    function void f4(int k); if (k) begin b4_s v; v.a = 1; end endfunction
  endclass

  // b5: ENUM typedef, block-item local of an `if`, out-of-body
  class b5;
    typedef enum { B5X, B5Y } b5_e;
    b5_e m_b5;
    extern function void f5(int k);
  endclass
  function void b5::f5(int k); if (k) begin b5_e v; v = B5X; end endfunction

  // b6: the FULL uvm shape — class-member QUEUE of the struct + a nested-block
  // local of the same type in an out-of-body method
  class b6;
    typedef struct { int a; } b6_s;
    b6_s m_qs[$];
    extern function void f6(int k);
  endclass
  function void b6::f6(int k);
    if (k) begin b6_s v; v.a = 1; m_qs.push_back(v); end
  endfunction

  // b7: struct typedef, PLAIN (unnested) local of an out-of-body method, for
  // the fence: v1 a4 said this cell is clean.
  class b7;
    typedef struct { int a; } b7_s;
    extern function void f7();
  endclass
  function void b7::f7(); b7_s v; v.a = 1; endfunction

  // b8: nested-block local named QUALIFIED, out-of-body
  class b8;
    typedef struct { int a; } b8_s;
    extern function void f8(int k);
  endclass
  function void b8::f8(int k); if (k) begin b8::b8_s v; v.a = 1; end endfunction

  // b9: TWO nesting levels
  class b9;
    typedef struct { int a; } b9_s;
    extern function void f9(int k);
  endclass
  function void b9::f9(int k);
    if (k) begin if (k > 1) begin b9_s v; v.a = 1; end end
  endfunction

endpackage
