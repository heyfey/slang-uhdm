// v31a2 — KEY x SHAPE x HOME matrix.
package v31p2;
  typedef bit [7:0] k8_t;
  int  ps_dflt0[string]  = '{default: 0};
  int  ps_dfltN[string]  = '{default: 7};
  int  ps_dk[string]     = '{"a": 1, default: 3};
  int  ps_keyed[string]  = '{"a": 1, "b": 2};
  int  pi_dflt[int]      = '{default: 0};
  int  pi_keyed[int]     = '{3: 1, 4: 2};
  int  pk_dflt[k8_t]     = '{default: 0};
  int  pw_dflt[*]        = '{default: 0};
  int  pq_pat[$]         = '{1, 2, 3};
  int  pq_cat[$]         = {1, 2, 3};
  int  pd_pat[]          = '{1, 2, 3};
  int  pd_rep[]          = '{3{2}};
  int  pd_new[]          = new[4];
  int  pf_fix[3]         = '{1, 2, 3};
  int  psc                = 5;

  function automatic int fl_p();
    int lq[$]        = '{1, 2};
    int laa[string]  = '{default: 0};
    int ld[]         = '{4, 5};
    return lq.size() + laa.size() + ld.size();
  endfunction

  class v31pc;
    typedef bit [7:0] ck8_t;
    protected int cs_dflt0[string] = '{default: 0};
    local     int cs_dfltN[string] = '{default: 7};
    static    int cs_stat[string]  = '{default: 1};
    rand      int cq_rand[$]       = '{1, 2};
    const     int cd_const[]       = '{1, 2};
              int ck_int[int]      = '{3: 1};
              int ck_k8[ck8_t]     = '{default: 0};
              int ck_wild[*]       = '{default: 0};
              int cd_rep[]         = '{3{2}};
              int cd_cat[]         = {6, 7, 8};
              int cf_fix[3]        = '{1, 2, 3};
              int cd_new[]         = new[4];
    function int f(); return cs_dflt0.size(); endfunction
  endclass
endpackage

module v31m2;
  typedef bit [7:0] mk8_t;
  int  ms_dflt0[string]  = '{default: 0};
  int  ms_dk[string]     = '{"a": 1, default: 3};
  int  mi_keyed[int]     = '{3: 1, 4: 2};
  int  mk_dflt[mk8_t]    = '{default: 0};
  int  mw_dflt[*]        = '{default: 0};
  int  mq_pat[$]         = '{1, 2, 3};
  int  md_pat[]          = '{1, 2, 3};
  int  md_rep[]          = '{3{2}};
  int  md_cat[]          = {6, 7, 8};
  int  mf_fix[3]         = '{1, 2, 3};

  class v31mc;
    protected int ms2[string] = '{default: 0};
              int md2[]       = '{1, 2};
  endclass

  function automatic int fl_m();
    int lq[$]       = '{1, 2};
    int laa[string] = '{default: 0};
    return lq.size() + laa.size();
  endfunction

  if (1) begin : g1
    int gd_pat[] = '{1, 2, 3};
    int gs_aa[string] = '{default: 0};
  end

  initial begin
    automatic int bq[$]       = '{1, 2};
    automatic int baa[string] = '{default: 0};
    $display(bq.size(), baa.size(), fl_m(), v31p2::fl_p());
  end
endmodule

program v31pg;
  int pgd[] = '{1, 2};
  int pgs[string] = '{default: 0};
  initial $display(pgd.size(), pgs.size());
endprogram

interface v31if;
  int ifd[] = '{1, 2};
  int ifs[string] = '{default: 0};
endinterface
