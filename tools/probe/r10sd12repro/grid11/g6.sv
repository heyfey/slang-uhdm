// r10sd11 grid cell g6 — WHICH TARGET DEGRADES.  One class `zh6` holds fifteen
// typedefs and one early-sorting user reads thirteen of them, so the target
// shape is walked one axis at a time off a single golden.  `px7::pk_t`'s
// counterpart here is `pkg_td6`, a PACKAGE typedef of `zelem6`, which claims
// that class ahead of every class typedef naming it.
package px6;
  // ORDERING NOTE.  slang refuses `Owner::td` when `Owner` is only
  // forward-declared, so every owner class is written BEFORE its user and the
  // USER class is written LAST.  That costs the cell nothing: Surelog's class
  // pass is LEXICOGRAPHIC (r10sd10 `g8`), and this law's claim order is read
  // off NAMES too, so `auser*` still sorts first and every `z*` owner still
  // sorts after it.

  class zelem6;
    int q;
  endclass

  typedef class zfwd6;             // a target that is only FORWARD-declared here

  class zparm6 #(type T = int);
    T x;
  endclass

  typedef zelem6 pkg_td6;          // the PACKAGE claimant of zelem6

  class zother6;
    typedef zelem6 o_t;
  endclass

  class zh6;
    typedef zelem6           t_cls;
    typedef zfwd6            t_fwd;
    typedef zparm6#(zelem6)  t_parm;
    typedef zelem6           t_q[$];
    typedef zelem6           t_da[];
    typedef zelem6           t_aa[string];
    typedef zelem6           t_fx[4];
    typedef zother6::o_t     t_td;
    typedef pkg_td6          t_ptd;
    typedef t_cls            t_self;
    typedef int              t_iq[$];
    typedef struct { int a; } s6_t;
    typedef s6_t             t_sq[$];
    typedef enum { E6A, E6B } e6_t;
    typedef e6_t             t_eq[$];
  endclass

  class zfwd6;
    int w;
  endclass

  class auser6;
    function void f6();
      zh6::t_cls    v_cls;     // plain class name, pkg_td6 claimed it
      zh6::t_fwd    v_fwd;     // forward-declared class name, UNIQUE claimant
      zh6::t_parm   v_parm;    // parameterised class name, UNIQUE claimant
      zh6::t_q      v_q;       // queue of a claimed class name
      zh6::t_da     v_da;      // dynamic array of a claimed class name
      zh6::t_aa     v_aa;      // assoc array of a claimed class name
      zh6::t_fx     v_fx;      // fixed unpacked array of a claimed class name
      zh6::t_td     v_td;      // typedef of another CLASS-NESTED typedef name
      zh6::t_ptd    v_ptd;     // typedef of a PACKAGE typedef name
      zh6::t_self   v_self;    // typedef of a typedef in the SAME class
      zh6::t_iq     v_iq;      // queue of int          (in place -> resolves)
      zh6::t_sq     v_sq;      // queue of a struct TYPEDEF in the same class
      zh6::t_eq     v_eq;      // queue of an enum TYPEDEF in the same class
    endfunction
  endclass

endpackage

module top6;
  initial begin
    px6::auser6 u = new();
    u.f6();
  end
endmodule
