// r10uvm80 arm c1 — WHEN does Surelog stamp vpiAutomatic on a variable?
// One cell per DECLARATION POSITION x WRITTEN LIFETIME KEYWORD.  Every name is
// unique so the dump can be grepped per cell.
package p80;
  class c80;
    int m_i;

    // --- fork arm (the corpus head's shape: `automatic int k = i;`) ----------
    task t_fork();
      int i;
      for (i = 0; i < 2; i++) begin
        fork
          automatic int a_fkauto = i;   // c1  fork arm, automatic kw, init
          begin
            m_i = a_fkauto;
          end
        join_none
      end
      fork
        int a_fkplain = 1;              // c2  fork arm, NO kw, init
        begin
          m_i = a_fkplain;
        end
      join_none
    endtask

    // --- sequential begin inside a class task -------------------------------
    task t_beg();
      begin
        automatic int b_bgauto = 1;     // c3  begin, automatic kw, init
        int           c_bgplain = 2;    // c4  begin, NO kw, init
        static int    d_bgstat = 3;     // c5  begin, static kw, init
        automatic int e_bgnoinit;       // c6  begin, automatic kw, NO init
        int           f_bgplainni;      // c7  begin, NO kw, NO init
        m_i = b_bgauto + c_bgplain + d_bgstat + e_bgnoinit + f_bgplainni;
      end
    endtask

    // --- a subroutine DECLARED automatic ------------------------------------
    function automatic void f_auto();
      begin
        int g_inautofn = 1;             // c8  begin inside `function automatic`
        m_i = g_inautofn;
      end
    endfunction

    // --- tf ITEM declarations (before the first statement) ------------------
    task t_items();
      int           h_tfitem = 0;       // c9   tf item, NO kw
      static int    k_tfstat = 0;       // c10  tf item, static kw
      automatic int l_tfauto = 0;       // c11  tf item, automatic kw
      m_i = h_tfitem + k_tfstat + l_tfauto;
    endtask

    // --- NAMED begin ---------------------------------------------------------
    task t_named();
      begin : nb80
        automatic int n_nbauto = 4;     // c12  named begin, automatic kw
        int           o_nbplain = 5;    // c13  named begin, NO kw
        m_i = n_nbauto + o_nbplain;
      end
    endtask
  endclass
endpackage

module m80;
  int mi;
  initial begin
    automatic int p_iniauto = 1;        // c14  module initial, automatic kw
    int           q_iniplain = 2;       // c15  module initial, NO kw
    static int    r_inistat = 3;        // c16  module initial, static kw
    mi = p_iniauto + q_iniplain + r_inistat;
  end
  always @(*) begin
    automatic int s_alwauto = 1;        // c17  always body, automatic kw
    int           t_alwplain = 2;       // c18  always body, NO kw
    mi = s_alwauto + t_alwplain;
  end
  task t_mod();
    begin
      automatic int u_mtauto = 1;       // c19  module task begin, automatic kw
      int           v_mtplain = 2;      // c20  module task begin, NO kw
      mi = u_mtauto + v_mtplain;
    end
  endtask
  function int f_mod();
    for (int w_forinit = 0; w_forinit < 2; w_forinit++) begin  // c21 for-init var
      automatic int x_fbauto = w_forinit;   // c22  for-body begin, automatic kw
      int           y_fbplain = 1;          // c23  for-body begin, NO kw
      mi = x_fbauto + y_fbplain;
    end
    f_mod = mi;
  endfunction
endmodule
