// r10buvm25 — golden grid for the foreach loop-variable kind law.
// The cell name encodes HOME / CONTAINER / ELEMENT.
package p25;
  class C25;
    int x;
  endclass
  typedef struct packed { logic [3:0] x; } S25;
  typedef union packed { logic [3:0] x; logic [3:0] y; } U25;
  typedef enum logic [1:0] { E25A, E25B } E25;
  typedef int I25;
  typedef C25 CA25;

  C25 pq_cls[$];
  int pq_int[$];
  string pq_str[$];
  S25 pq_st[$];
  U25 pq_un[$];
  E25 pq_en[$];
  I25 pq_ai[$];
  CA25 pq_ac[$];
  byte pq_by[$];
  bit pq_bi[$];
  real pq_re[$];
  time pq_tm[$];
  C25 pd_cls[];
  int pd_int[];
  C25 pf_cls[3];
  int pf_int[3];
  C25 pa_str[string];
  int pa_cls[C25];

  function void pf25();
    foreach (pq_cls[i_qc]) pq_cls[i_qc].x = i_qc;
    foreach (pq_int[i_qi]) pq_int[i_qi] = i_qi;
    foreach (pq_str[i_qs]) pq_str[i_qs] = "";
    foreach (pq_st[i_qt]) pq_st[i_qt].x = i_qt;
    foreach (pq_un[i_qu]) pq_un[i_qu].x = i_qu;
    foreach (pq_en[i_qe]) pq_en[i_qe] = E25A;
    foreach (pq_ai[i_qa]) pq_ai[i_qa] = i_qa;
    foreach (pq_ac[i_qh]) pq_ac[i_qh].x = i_qh;
    foreach (pq_by[i_qy]) pq_by[i_qy] = i_qy;
    foreach (pq_bi[i_qb]) pq_bi[i_qb] = i_qb;
    foreach (pq_re[i_qr]) pq_re[i_qr] = i_qr;
    foreach (pq_tm[i_qm]) pq_tm[i_qm] = i_qm;
    foreach (pd_cls[i_dc]) pd_cls[i_dc].x = i_dc;
    foreach (pd_int[i_di]) pd_int[i_di] = i_di;
    foreach (pf_cls[i_fc]) pf_cls[i_fc].x = i_fc;
    foreach (pf_int[i_fi]) pf_int[i_fi] = i_fi;
    foreach (pa_str[i_as]) pa_str[i_as].x = 0;
    foreach (pa_cls[i_ac]) pa_cls[i_ac] = 0;
  endfunction

  class K25;
    C25 cq_cls[$];
    int cq_int[$];
    function void in25();
      foreach (cq_cls[i_cq]) cq_cls[i_cq].x = i_cq;
      foreach (cq_int[i_ci]) cq_int[i_ci] = i_ci;
    endfunction
    extern function void out25();
  endclass
  function void K25::out25();
    foreach (cq_cls[i_oc]) cq_cls[i_oc].x = i_oc;
  endfunction

  function automatic void formal25(ref C25 fq[$], ref int fa[string]);
    C25 lq[$];
    int ld[];
    foreach (fq[i_fq]) fq[i_fq].x = i_fq;
    foreach (fa[i_fa]) fa[i_fa] = 0;
    foreach (lq[i_lq]) lq[i_lq].x = i_lq;
    foreach (ld[i_ld]) ld[i_ld] = i_ld;
  endfunction
endpackage

module top25;
  import p25::*;
  C25 mq[$];
  C25 ma[string];
  function void mf25();
    foreach (mq[i_mq]) mq[i_mq].x = i_mq;
    foreach (ma[i_ma]) ma[i_ma].x = 0;
  endfunction
endmodule
