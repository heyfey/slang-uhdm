// r10vbuvm21repro/v3operand.sv — ADVERSARIAL OPERAND-SHAPE arm: every reference
// position inside an inc/dec statement's operand.  Array kinds (assoc by
// enum/int/string/class-handle, queue, dynamic, fixed, 2-D), nested selects,
// arithmetic and call indices, part-selects, member paths, handle bases, a
// package-variable base, a formal used as the base, and $unit homes.
typedef enum { UA3, UB3 } uve3;
int u3_arr[uve3];
function void u3_free(uve3 s);            u3_arr[s]++;              endfunction
class u3cls;
  int uaa[uve3];
  function void u3_inc(uve3 s);           uaa[s]++;                 endfunction
  function void u3_loc(uve3 s);           int lq[$]; lq[0]++;       endfunction
endclass

package vp3;
  typedef enum { A3, B3 } ve3;
  class hd3;
    int harr[ve3];
  endclass
  int vp3_arr[ve3];
  class vc3;
    int aa[ve3];
    int ai[int];
    int as[string];
    int ac[hd3];
    int aq[$];
    int ad[];
    int af[4];
    int a2[ve3][ve3];
    bit [15:0] pvec;
    hd3 h;
    typedef struct packed { int a; int b; } sp3;
    sp3 pst;
    sp3 sarr[ve3];
    function int fx(int k);                 return k;               endfunction
    // array KINDS
    function void k_int(int k);             ai[k]++;                endfunction
    function void k_str(string k);          as[k]++;                endfunction
    function void k_cls(hd3 k);             ac[k]++;                endfunction
    function void k_q(int k);               aq[k]++;                endfunction
    function void k_dyn(int k);             ad[k]++;                endfunction
    function void k_fix(int k);             af[k]++;                endfunction
    function void k_2d(ve3 s, ve3 t);       a2[s][t]++;             endfunction
    // INDEX shapes
    function void x_nested(int k);          af[ai[k]]++;            endfunction
    function void x_arith(int k);           af[k+1]++;              endfunction
    function void x_call(int k);            af[fx(k)]++;            endfunction
    function void x_lit(int k);             af[2]++;                endfunction
    // PART-SELECT carriers
    function void p_ips(int k);             pvec[k+:2]++;           endfunction
    function void p_const(int k);           pvec[3:2]++;            endfunction
    // BASE shapes
    function void b_this(ve3 s);            this.aa[s]++;           endfunction
    function void b_hnd(ve3 s);             h.harr[s]++;            endfunction
    function void b_lochnd(ve3 s);          hd3 lh; lh = new(); lh.harr[s]++; endfunction
    function void b_pkgvar(ve3 s);          vp3_arr[s]++;           endfunction
    function void b_formalarr(ref int fa[ve3], ve3 s); fa[s]++;     endfunction
    function void b_formalq(ref int fq[$], int k);     fq[k]++;     endfunction
    // MEMBER paths on the operand
    function void m_prop();                 pst.a++;                endfunction
    function void m_formalst(sp3 fs);       fs.a++;                 endfunction
    function void m_arrmem(ve3 s);          sarr[s].a++;            endfunction
    // the operand is the formal itself, every direction
    function void o_bare(int s);            s++;                    endfunction
    function void o_ref(ref int s);         s++;                    endfunction
    function void o_inout(inout int s);     s++;                    endfunction
    function void o_out(output int s);      s = 0; s++;             endfunction
    // scoping: a nested-block local, a NAMED-block local, and a local declared
    // in an unnamed block INSIDE a named block (the law's symbol predicate)
    function void s_blkloc(ve3 s);          begin int bl; bl++; aa[s]++; end endfunction
    function void s_namedloc(ve3 s);        begin : nb3 int nl; nl++; aa[s]++; end endfunction
    function void s_nestedloc(ve3 s);       begin : nb4 begin int xl; xl++; end end endfunction
    function void s_forkloc(ve3 s);         begin int fl; fl++; end  endfunction
  endclass
endpackage
