// vsd12 cell v9 — THE OUT-OF-BODY ARM at the declarator forms `h2` does not
// carry, plus the STATEMENT-scope shapes none of grid12 reaches: a nested
// `begin` inside an out-of-body body, a `foreach` body, a named block, a
// `do…while` body, and a MODULE-level task (no enclosing class at all, so
// r10sd10's BARE arm returns `Resolved` and its SCOPED arm returns `ClassVar`).
package pv9;

  class zelv9;
    int q;
  endclass

  class zown9;                       // sorts AFTER ahost9
    typedef zelv9 o_t;
  endclass

  class ahost9;
    typedef zelv9                      own_t;
    typedef struct { int a; real b; }  rec_t;

    extern function void ext9();
  endclass

  function void ahost9::ext9();
    zown9::o_t e_aa[int];            // scoped, out-of-body, ASSOC
    zown9::o_t e_da[];               // scoped, out-of-body, DYNAMIC
    zown9::o_t e_m2[2][3];           // scoped, out-of-body, TWO dims
    own_t      e_own_fx[2];          // bare own typedef, out-of-body, FIXED
    rec_t      e_rec_aa[int];
    begin : nb9
      zown9::o_t n_q[$];             // a NESTED block inside an oob body
      own_t      n_own_q[$];
      n_q = {};
    end
    e_da = {};
  endfunction

endpackage

module topv9;
  import pv9::*;

  task automatic t9();
    zown9::o_t m_q[$];               // MODULE task: no enclosing class
    zown9::o_t m_fx[2];
    m_q = {};
  endtask

  initial begin
    int idx9[3];
    foreach (idx9[i]) begin
      zown9::o_t fe_q[$];            // a FOREACH body
      fe_q = {};
    end
    do begin
      zown9::o_t dw_q[$];            // a DO..WHILE body
      dw_q = {};
    end while (0);
    t9();
  end
endmodule
