// r10v143 arm A — THE FORMAL FACE, exhaustively, as a hier_path element INDEX.
// Every method below is written INSIDE the class body (the law's gated side);
// class CooA is the OUT-OF-BODY twin of the same faces (the law's ungated side).
package pkA143v;

  typedef struct { int waiters; int total; } evA_t;
  typedef enum int { EA_ZERO = 0, EA_ONE = 1, EA_TWO = 2 } eA_t;
  typedef struct { int k1; int k2; } keyA_t;
  parameter int PA_K = 3;

  function automatic int defA();
    return 4;
  endfunction

  class HandA;
    int hid;
  endclass

  class CinA;
    evA_t m_ev[int];
    evA_t m_qq[$];
    evA_t m_dy[];
    evA_t m_ua[8];
    evA_t m_st[string];
    evA_t m_en[eA_t];
    evA_t m_hd[HandA];
    evA_t m_kk[keyA_t];

    // --- position of the default -------------------------------------
    function int a_first(int p1 = 0, int p2, int p3);       // FIRST defaulted
      return m_ev[p1].waiters;
    endfunction
    function int a_mid(int q1, int q2 = 1, int q3);         // MIDDLE defaulted
      return m_ev[q2].waiters;
    endfunction
    function int a_last(int r1, int r2, int r3 = 2);        // LAST defaulted
      return m_ev[r3].waiters;
    endfunction
    function int a_many(int s1 = 0, int s2 = 1, int s3 = 2); // SEVERAL defaulted
      return m_ev[s1].waiters + m_ev[s2].total + m_ev[s3].waiters;
    endfunction

    // --- what the default IS -----------------------------------------
    function int a_dnull(HandA h = null);                   // default null
      return m_hd[h].waiters;
    endfunction
    function int a_dlit(int t1 = 7);                        // default literal
      return m_ev[t1].waiters;
    endfunction
    function int a_dparam(int u1 = PA_K);                   // default parameter
      return m_ev[u1].waiters;
    endfunction
    function int a_dcall(int v1 = defA());                  // default call
      return m_ev[v1].waiters;
    endfunction
    function int a_dconcat(int w1 = {8'd1, 8'd2, 16'd3});   // default concat
      return m_ev[w1].waiters;
    endfunction

    // --- directions ----------------------------------------------------
    function int a_in(input int x1);
      return m_ev[x1].waiters;
    endfunction
    function void a_out(output int y1);
      y1 = m_ev[y1].waiters;
    endfunction
    function void a_inout(inout int z1);
      z1 = m_ev[z1].total;
    endfunction
    function int a_ref(ref int c1);
      return m_ev[c1].waiters;
    endfunction

    // --- the TYPE of the formal that indexes ----------------------------
    function int a_tclass(HandA hh = null);
      return m_hd[hh].waiters;
    endfunction
    function int a_tenum(eA_t ee = EA_ONE);
      return m_en[ee].waiters;
    endfunction
    function int a_tstruct(keyA_t kk);
      return m_kk[kk].waiters;
    endfunction
    function int a_tstring(string ss = "z");
      return m_st[ss].waiters;
    endfunction
    function int a_tqueue(int qi[$]);
      return m_qq[qi[0]].waiters;
    endfunction
    function int a_tarray(int ua[4]);
      return m_ua[ua[1]].waiters;
    endfunction
    function int a_tdyn(int dd[]);
      return m_dy[dd[2]].total;
    endfunction

    // --- a TASK, not a function -----------------------------------------
    task a_task(int tt = 5, output int oo);
      oo = m_ev[tt].waiters;
    endtask

    // --- a STATIC method --------------------------------------------------
    static evA_t s_ev[int];
    static function int a_static(int sx = 1);
      return s_ev[sx].waiters;
    endfunction

    // --- a CONSTRUCTOR with defaulted arguments ---------------------------
    function new(int nx = 2, HandA nh = null);
      m_ev[nx].waiters = 1;
      if (nh != null) m_ev[nx].total = m_hd[nh].total;
    endfunction

    // --- a VIRTUAL method whose override repeats / drops the default ------
    virtual function int a_virt(int vx = 9);
      return m_ev[vx].waiters;
    endfunction
  endclass

  class CinA2 extends CinA;
    virtual function int a_virt(int vx = 9);      // default REPEATED
      return m_ev[vx].total;
    endfunction
  endclass

  class CinA3 extends CinA;
    virtual function int a_virt(int vx = 11);     // default RE-SPELLED, different value
      return m_ev[vx].total;
    endfunction
  endclass

  // ================= the OUT-OF-BODY twin ==============================
  class CooA;
    evA_t m_ev[int];
    evA_t m_hd[HandA];
    extern function int b_first(int p1 = 0, int p2, int p3);
    extern function int b_dnull(HandA h = null);
    extern function int b_dparam(int u1 = PA_K);
    extern function void b_out(output int y1);
    extern function int b_ref(ref int c1);
    extern task b_task(int tt = 5, output int oo);
    extern function new(int nx = 2);
    extern virtual function int b_virt(int vx = 9);
  endclass

  function int CooA::b_first(int p1 = 0, int p2, int p3);
    return m_ev[p1].waiters;
  endfunction
  function int CooA::b_dnull(HandA h = null);
    return m_hd[h].waiters;
  endfunction
  function int CooA::b_dparam(int u1 = PA_K);
    return m_ev[u1].waiters;
  endfunction
  function void CooA::b_out(output int y1);
    y1 = m_ev[y1].waiters;
  endfunction
  function int CooA::b_ref(ref int c1);
    return m_ev[c1].waiters;
  endfunction
  task CooA::b_task(int tt = 5, output int oo);
    oo = m_ev[tt].waiters;
  endtask
  function CooA::new(int nx = 2);
    m_ev[nx].waiters = 1;
  endfunction
  function int CooA::b_virt(int vx = 9);
    return m_ev[vx].waiters;
  endfunction

  // a free PACKAGE function/task with the same shapes (pool IS drained)
  evA_t g_ev[int];
  function int free_fn(int p1 = 0);
    return g_ev[p1].waiters;
  endfunction
  task free_tk(int p1 = 0, output int oo);
    oo = g_ev[p1].total;
  endtask

endpackage

module topA143v;
  import pkA143v::*;
  CinA ci;
  CooA co;
  int r;
  initial begin
    ci = new();
    co = new();
    r = ci.a_first(.p2(1), .p3(2));
    r = co.b_first(.p2(1), .p3(2));
    r = free_fn();
  end
endmodule
