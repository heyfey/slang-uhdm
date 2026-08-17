// r10uvm80 VERIFIER arm v4 — WHERE THE UNPACKED DIMENSIONS ARE WRITTEN.
// Arm v2 found a counterexample to RF-2's blanket "golden stamps the ELEMENT,
// never the array_var": for `typedef int t[4]; automatic t x;` golden emits a
// SINGLE array_var and stamps IT.  This arm separates the two carriers of the
// unpacked dimension — the DECLARATOR (`automatic int x [4];`) versus the
// TYPEDEF (`typedef int t [4]; automatic t x;`) — across fixed / queue /
// dynamic / associative, at block scope and at module scope, with and without
// the keyword.
package pv4;
  typedef int   tfix_t [4];        // dims on the TYPEDEF, fixed
  typedef int   tque_t [$];        // dims on the TYPEDEF, queue
  typedef int   tdyn_t [];         // dims on the TYPEDEF, dynamic
  typedef int   tasc_t [string];   // dims on the TYPEDEF, associative
  typedef logic [3:0] tpk_t;       // PACKED dims on the typedef (not unpacked)
  typedef struct { int a; } ts_t;

  class cv4;
    int m_i;
    task t_dims();
      begin
        // ---- dimensions on the DECLARATOR ------------------------------
        automatic int    d_fix [4];       // x1  declarator dims, fixed, kw
        automatic int    d_que [$];       // x2  declarator dims, queue, kw
        automatic int    d_dyn [];        // x3  declarator dims, dynamic, kw
        automatic int    d_asc [string];  // x4  declarator dims, assoc, kw
        int              d_fixp [4];      // x5  declarator dims, fixed, NO kw
        // ---- dimensions on the TYPEDEF ---------------------------------
        automatic tfix_t t_fix;           // x6  typedef dims, fixed, kw
        automatic tque_t t_que;           // x7  typedef dims, queue, kw
        automatic tdyn_t t_dyn;           // x8  typedef dims, dynamic, kw
        automatic tasc_t t_asc;           // x9  typedef dims, assoc, kw
        tfix_t           t_fixp;          // x10 typedef dims, fixed, NO kw
        // ---- packed dims on a typedef (NOT an unpacked array) -----------
        automatic tpk_t  p_pk = 4'h3;     // x11 packed typedef, kw
        // ---- typedef dims PLUS declarator dims --------------------------
        automatic tfix_t b_both [2];      // x12 BOTH carriers, kw
        // ---- struct element -------------------------------------------
        automatic ts_t   s_arr [2];       // x13 declarator dims, struct elem, kw
        m_i = d_fix[0] + d_fixp[0] + t_fix[0] + t_fixp[0] + p_pk;
        m_i += b_both[0][0] + s_arr[0].a + d_asc["k"] + t_asc["k"];
        d_que.push_back(1); t_que.push_back(1);
        d_dyn = new[2]; t_dyn = new[2];
        m_i += d_que.size() + t_que.size() + d_dyn.size() + t_dyn.size();
      end
    endtask
  endclass
endpackage

module mv4;
  import pv4::*;
  int mi;
  initial begin
    automatic int    n_fix [4];           // x14 module scope, declarator dims
    automatic tfix_t n_tfix;              // x15 module scope, typedef dims
    tfix_t           n_tfixp;             // x16 module scope, typedef, NO kw
    mi = n_fix[0] + n_tfix[0] + n_tfixp[0];
  end
endmodule
