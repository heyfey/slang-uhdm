// r10uvm80 VERIFIER arm v3 — LIFETIME INHERITANCE and the TF-ITEM BOUNDARY.
// The law says the enclosing subroutine's lifetime does NOT propagate to a
// block-scope declaration.  This measures that against every carrier of a
// default lifetime SV has: `module automatic` / `module static`,
// `program automatic`, `package` (implicitly static), a class (implicitly
// automatic), `task automatic` / `task static`, `function automatic` /
// `function static`, and the tf-ITEM vs BLOCK-ITEM boundary in each — because
// Surelog runs a DIFFERENT rule (`VpiAutomatic(!is_static)`, CompileStmt:1690)
// on tf items, and a law that leaks across the boundary is a two-law
// regression.
package pv3;                             // package default lifetime = static
  class cv3;                             // class methods default = automatic
    int m_i;
    // subroutine declared automatic — c1 cell c8's twin at every position
    function automatic int f_auto();
      int      y_tfa_item = 1;           // y1  tf item of a `function automatic`
      begin
        int    y_tfa_blk  = 2;           // y2  BLOCK item, same subroutine
        automatic int y_tfa_kw = 3;      // y3  BLOCK item + keyword
        static int    y_tfa_st = 4;      // y4  BLOCK item + static keyword
        m_i = y_tfa_blk + y_tfa_kw + y_tfa_st;
      end
      f_auto = m_i + y_tfa_item;
    endfunction
    // subroutine declared static — ILLEGAL for a class method (slang rejects
    // it: "class methods cannot have static lifetime"), so the static-lifetime
    // subroutine cell lives at PACKAGE scope below (pf_stat).
    function int f_stat();
      int      y_tfs_item = 1;           // y5  tf item of a `function static`
      begin
        int    y_tfs_blk  = 2;           // y6  BLOCK item, static subroutine
        automatic int y_tfs_kw = 3;      // y7  BLOCK item + keyword
        m_i = y_tfs_blk + y_tfs_kw;
      end
      f_stat = m_i + y_tfs_item;
    endfunction
    // subroutine with NO lifetime keyword inside a class (default automatic)
    function int f_none();
      int      y_tfn_item = 1;           // y8  tf item, no subroutine kw
      begin
        int    y_tfn_blk  = 2;           // y9  BLOCK item, no kw anywhere
        automatic int y_tfn_kw = 3;      // y10 BLOCK item + keyword
        m_i = y_tfn_blk + y_tfn_kw;
      end
      f_none = m_i + y_tfn_item;
    endfunction
    task automatic t_auto();
      int      y_tka_item = 1;           // y11 tf item of a `task automatic`
      begin
        int    y_tka_blk  = 2;           // y12 BLOCK item
        automatic int y_tka_kw = 3;      // y13 BLOCK item + keyword
        m_i = y_tka_blk + y_tka_kw;
      end
      m_i += y_tka_item;
    endtask
  endclass

  // PACKAGE-level subroutines (package default lifetime is STATIC)
  int pkg_i;
  function automatic int pf_auto();
    int y_pfa_item = 1;                  // y14 tf item, package `function automatic`
    begin
      int y_pfa_blk = 2;                 // y15 BLOCK item
      automatic int y_pfa_kw = 3;        // y16 BLOCK item + keyword
      pkg_i = y_pfa_blk + y_pfa_kw;
    end
    pf_auto = pkg_i + y_pfa_item;
  endfunction
  function static int pf_stat();
    int y_pss_item = 1;                  // y17b tf item, package `function static`
    begin
      int y_pss_blk = 2;                 // y18b BLOCK item, static subroutine
      automatic int y_pss_kw = 3;        // y19b BLOCK item + keyword
      pkg_i = y_pss_blk + y_pss_kw;
    end
    pf_stat = pkg_i + y_pss_item;
  endfunction
  function int pf_none();
    int y_pfn_item = 1;                  // y17 tf item, package function, no kw
    begin
      int y_pfn_blk = 2;                 // y18 BLOCK item
      automatic int y_pfn_kw = 3;        // y19 BLOCK item + keyword
      pkg_i = y_pfn_blk + y_pfn_kw;
    end
    pf_none = pkg_i + y_pfn_item;
  endfunction
endpackage

// `module automatic` — the whole module's default lifetime is automatic
module automatic mv3a;
  int ai;
  initial begin
    int           z_ma_plain = 1;        // y20 initial body, module automatic, NO kw
    automatic int z_ma_kw    = 2;        // y21 same, keyword written
    static int    z_ma_st    = 3;        // y22 same, static written
    ai = z_ma_plain + z_ma_kw + z_ma_st;
  end
  function int f_ma();
    int z_ma_item = 1;                   // y23 tf item under `module automatic`
    begin
      int           z_ma_blk = 2;        // y24 BLOCK item under module automatic
      automatic int z_ma_bkw = 3;        // y25 BLOCK item + keyword
      ai = z_ma_blk + z_ma_bkw;
    end
    f_ma = ai + z_ma_item;
  endfunction
endmodule

// `module static` — explicit static default
module static mv3s;
  int si;
  initial begin
    int           z_ms_plain = 1;        // y26 initial body, module static, NO kw
    automatic int z_ms_kw    = 2;        // y27 same, keyword written
    si = z_ms_plain + z_ms_kw;
  end
endmodule

// `program automatic`
program automatic pv3p;
  int pi;
  initial begin
    int           z_pa_plain = 1;        // y28 program automatic, NO kw
    automatic int z_pa_kw    = 2;        // y29 program automatic, keyword
    pi = z_pa_plain + z_pa_kw;
  end
endprogram

module mv3top;
  mv3a a1();
  mv3s s1();
endmodule
