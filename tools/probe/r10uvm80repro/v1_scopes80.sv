// r10uvm80 VERIFIER arm v1 — SCOPE COVERAGE.  The implementer's c1 measured 7
// positions; this measures the ones it did NOT: while / do-while / repeat /
// forever / foreach bodies, case-item and if-branch begins, nested begin-in-
// begin, always_ff / always_comb / final, fork join / join_any (c1 used only
// join_none), a generate-block begin, a program's initial, an interface task,
// and a static-keyword override inside a class method (where slang's SEMANTIC
// lifetime is Automatic).  Every name unique so the dump greps per cell.
package pv1;
  class cv1;
    int m_i;

    // ---- loop bodies ------------------------------------------------------
    task t_loops();
      int n = 0;
      while (n < 2) begin
        automatic int v_whauto = n;     // v1  while body, automatic
        int           v_whplain = n;    // v2  while body, NO kw
        m_i = v_whauto + v_whplain; n++;
      end
      do begin
        automatic int v_dwauto = 1;     // v3  do-while body, automatic
        int           v_dwplain = 2;    // v4  do-while body, NO kw
        m_i = v_dwauto + v_dwplain; n++;
      end while (n < 4);
      repeat (2) begin
        automatic int v_rpauto = 1;     // v5  repeat body, automatic
        int           v_rpplain = 2;    // v6  repeat body, NO kw
        m_i = v_rpauto + v_rpplain;
      end
    endtask

    // ---- foreach body + foreach's own implicit iterator -------------------
    task t_foreach();
      int fa [3];
      foreach (fa[v_fei]) begin        // v7  foreach ITERATOR (implicit, no kw)
        automatic int v_feauto = fa[v_fei];  // v8  foreach body, automatic
        int           v_feplain = 0;         // v9  foreach body, NO kw
        m_i = v_feauto + v_feplain;
      end
    endtask

    // ---- control-flow branch bodies ---------------------------------------
    task t_branch(int sel);
      if (sel == 1) begin
        automatic int v_ifauto = 1;     // v10 if-branch begin, automatic
        int           v_ifplain = 2;    // v11 if-branch begin, NO kw
        m_i = v_ifauto + v_ifplain;
      end
      else begin
        automatic int v_elauto = 3;     // v12 else-branch begin, automatic
        m_i = v_elauto;
      end
      case (sel)
        0: begin
          automatic int v_csauto = 4;   // v13 case-item begin, automatic
          int           v_csplain = 5;  // v14 case-item begin, NO kw
          m_i = v_csauto + v_csplain;
        end
        default: begin
          automatic int v_cdauto = 6;   // v15 case default begin, automatic
          m_i = v_cdauto;
        end
      endcase
    endtask

    // ---- nested begin inside begin ----------------------------------------
    task t_nest();
      begin
        automatic int v_n1auto = 1;     // v16 outer begin, automatic
        begin
          automatic int v_n2auto = 2;   // v17 begin-in-begin, automatic
          int           v_n2plain = 3;  // v18 begin-in-begin, NO kw
          begin : deep80
            automatic int v_n3auto = 4; // v19 named begin depth 3, automatic
            m_i = v_n3auto;
          end
          m_i = v_n2auto + v_n2plain;
        end
        m_i = v_n1auto;
      end
    endtask

    // ---- fork join and join_any (c1 used only join_none) -------------------
    task t_forks();
      fork
        automatic int v_fjauto = 1;     // v20 fork..join arm, automatic
        begin
          int v_fjplain = 2;            // v21 fork..join arm begin, NO kw
          m_i = v_fjplain;
        end
      join
      fork
        automatic int v_fanauto = 1;    // v22 fork..join_any arm, automatic
      join_any
      fork : nfk80
        automatic int v_nfauto = 1;     // v23 NAMED fork arm, automatic
        m_i = v_nfauto;
      join_none
    endtask

    // ---- static keyword inside a class method (semantic lifetime Automatic)
    task t_stat();
      begin
        static int    v_stkw = 1;       // v24 begin, static kw, class method
        automatic int v_stauto = 2;     // v25 same begin, automatic kw
        m_i = v_stkw + v_stauto;
      end
    endtask

    // ---- const / var modifier companions ----------------------------------
    task t_mods();
      begin
        var automatic int v_varauto = 1;   // v26 `var automatic`
        var int           v_varplain = 2;  // v27 `var` alone
        m_i = v_varauto + v_varplain;
      end
    endtask
  endclass
endpackage

interface iv1;
  int ii;
  task t_ifc();
    begin
      automatic int v_ifcauto = 1;      // v28 interface task begin, automatic
      int           v_ifcplain = 2;     // v29 interface task begin, NO kw
      ii = v_ifcauto + v_ifcplain;
    end
  endtask
endinterface

module mv1;
  int mi;
  // ---- always_ff / always_comb / final -----------------------------------
  always_comb begin
    automatic int v_acauto = 1;         // v30 always_comb, automatic
    int           v_acplain = 2;        // v31 always_comb, NO kw
    mi = v_acauto + v_acplain;
  end
  always_latch begin
    automatic int v_alauto = 1;         // v32 always_latch, automatic
    mi = v_alauto;
  end
  final begin
    automatic int v_fnauto = 1;         // v33 final block, automatic
    int           v_fnplain = 2;        // v34 final block, NO kw
    mi = v_fnauto + v_fnplain;
  end
  // ---- generate-block begin ----------------------------------------------
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk80
      initial begin
        automatic int v_gnauto = 1;     // v35 gen-block initial, automatic
        int           v_gnplain = 2;    // v36 gen-block initial, NO kw
        mi = v_gnauto + v_gnplain;
      end
    end
  endgenerate
  // ---- forever inside initial --------------------------------------------
  initial begin
    int c = 0;
    forever begin
      automatic int v_fvauto = 1;       // v37 forever body, automatic
      int           v_fvplain = 2;      // v38 forever body, NO kw
      mi = v_fvauto + v_fvplain;
      c++;
      if (c > 1) break;
    end
  end
endmodule

program pgv1;
  int pi;
  initial begin
    automatic int v_pgauto = 1;         // v39 program initial, automatic
    int           v_pgplain = 2;        // v40 program initial, NO kw
    pi = v_pgauto + v_pgplain;
  end
endprogram
