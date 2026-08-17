// r10sd11 grid cell g7 — THE CLAIM ORDER, across containers and across
// specialisations.
//
// g1 showed that of THREE typedefs in ONE class naming the same target class,
// only the FIRST BY NAME keeps a real typespec.  This cell asks the three
// questions that decide how far that rule reaches:
//   (a) does the claim cross CONTAINERS?  `n7::a_t` and `x7::b_t` both name
//       `zel7`; `n7` sorts before `x7`.
//   (b) does the claim group two DIFFERENT SPECIALISATIONS of one generic
//       class?  `n7::p_a` is `zg7#(int)` and `x7::p_b` is `zg7#(byte)`.
//   (c) does a PACKAGE typedef of the same target claim ahead of every class
//       typedef?  `pk_t` names `zel2_7`, and `n7::c_t` / `x7::d_t` name it too.
package px7;
  // ORDERING NOTE.  slang refuses `Owner::td` when `Owner` is only
  // forward-declared, so every owner class is written BEFORE its user and the
  // USER class is written LAST.  That costs the cell nothing: Surelog's class
  // pass is LEXICOGRAPHIC (r10sd10 `g8`), and this law's claim order is read
  // off NAMES too, so `auser*` still sorts first and every `z*` owner still
  // sorts after it.

  class zel7;
    int q;
  endclass

  class zel2_7;
    int q;
  endclass

  class zel3_7;
    int q;
  endclass

  class zg7 #(type T = int);
    T x;
  endclass

  typedef zel2_7 pk_t;

  class n7;
    typedef zel7  a_t;
    typedef zg7#(int) p_a;
    typedef zel2_7 c_t;
    typedef zel3_7 u_t;
  endclass

  class x7;
    typedef zel7  b_t;
    typedef zg7#(byte) p_b;
    typedef zel2_7 d_t;
  endclass

  class auser7;
    function void f7();
      n7::a_t   v_a;     // first-by-container typedef of zel7
      x7::b_t   v_b;     // second-by-container typedef of zel7
      n7::p_a   v_pa;    // zg7#(int)
      x7::p_b   v_pb;    // zg7#(byte)
      n7::c_t   v_c;     // zel2_7, but px7::pk_t claimed it in the PACKAGE pass
      x7::d_t   v_d;     // zel2_7 as well
      n7::u_t   v_u;     // the ONLY typedef naming zel3_7
    endfunction
  endclass

endpackage

module top7;
  initial begin
    px7::auser7 u = new();
    u.f7();
  end
endmodule
