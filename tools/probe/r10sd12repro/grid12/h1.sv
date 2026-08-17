// r10sd12 grid cell h1 — THE DECLARATOR FORMS.  Four declarator shapes
// (associative / queue / dynamic / fixed) over a CLASS-NESTED typedef written
// three ways, all inside ONE IN-BODY class method, so the only axis that moves
// is the SPELLING.  This is r10sd11's `g8` re-scored on the ELEMENT VARIABLE's
// OBJECT CLASS instead of its typespec, which is the half `g8` left as R0.
//
// ORDERING NOTE (carried from g8).  slang refuses `Owner::td` when `Owner` is
// only forward-declared, so every owner class is written BEFORE its user.
// Surelog's class pass and this law's order test read NAMES, not source
// position, and `ph1::auser1` still sorts first.
package ph1;

  class zel1;
    int q;
  endclass

  class zk1;
    int q;
  endclass

  typedef zel1 pk1_t;          // the PACKAGE claimant of zel1

  class z1;
    typedef zel1 d_t;          // typespec DEGRADES (pk1_t claimed zel1)
    typedef zk1  k_t;          // typespec CLAIMS (sole namer of zk1)
    typedef int  i_t;          // a class-nested INT typedef
    typedef struct packed { int f; } st_t;   // target declared IN PLACE
  endclass

  class auser1;
    typedef zel1 b_t;          // the DECLARING class's OWN typedef, for BARE

    function void f1();
      // SCOPED, owner sorts LATE  -> r10sd10 says class_var, all four forms
      z1::d_t  a_aa[int];
      z1::d_t  a_q[$];
      z1::d_t  a_da[];
      z1::d_t  a_fx[4];
      // The SAME four on a CLAIMING typedef: the typespec differs, the
      // VARIABLE CLASS must not.
      z1::k_t  k_aa[int];
      z1::k_t  k_q[$];
      z1::k_t  k_da[];
      z1::k_t  k_fx[4];
      // A class-nested typedef whose target is NOT a class handle: an int and
      // an in-place packed struct, both scoped.
      z1::i_t  n_q[$];
      z1::st_t t_q[$];
      // BARE, the declaring class's OWN typedef, IN-BODY -> owner compiled.
      b_t      s_q[$];
      b_t      s_fx[2];
      a_aa[0] = null;
      k_aa[0] = null;
    endfunction
  endclass

endpackage

module toph1;
  initial begin
    ph1::auser1 u = new();
    u.f1();
  end
endmodule
