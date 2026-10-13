# (v11u310) gen.py: writes the fresh case dirs under ../cases (VM, VL, VC, VT, VQ), each first line naming its law
import os, sys
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cases')
PKG = """package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage
"""
CLS = PKG + """typedef struct { int k; int m; } s_t;
typedef enum { EA, EB } e_t;
class item; int f; int g[4]; int k; item nx; function int get(); return f; endfunction function int put(int x); return x; endfunction function void run(); endfunction static function int sget(); return 0; endfunction endclass
class holder; item arr[4]; int idx[4]; int idx2[4][4]; int k; holder hh; logic [7:0] v; string s; int q[$]; endclass
class grid;
  item iarr[4]; item i2[4][4]; int midx[4]; int i; int j; int r; bit c; bit d; holder h; holder hd; holder harr[4]; int ia[4];
  string sarr[4]; e_t earr[4]; item smap[string]; s_t s; string str;
  function int fn(int x); return x; endfunction
  static function int sfn(int x); return x; endfunction
  function void probe();
    BODY
  endfunction
EXTRA
endclass
module top; endmodule
"""
MOD = PKG + """typedef struct packed { logic [1:0] f; logic [1:0] k; } e_t;
typedef struct packed { e_t [3:0] a; logic [1:0] k; } u_t;
module top(input logic clk, input logic [1:0] i, input logic [1:0] j, input logic c, output logic [1:0] r);
  e_t [3:0] sa; u_t u; logic [1:0] midx [4];
  function automatic logic [1:0] fn(logic [1:0] x); return x; endfunction
BODY
endmodule
"""
cases = {}
def C(g, name, law, body, extra='', tmpl=CLS):
    cases[(g, name)] = '// § %s\n' % law + tmpl.replace('BODY', body).replace('EXTRA', extra)
M='methTailIdxNestShape310'
for n,b in [('vm01_strlen','r = sarr[h.k].len();'),('vm02_qsize','r = harr[h.k].q.size();'),('vm03_qpush','harr[h.k].q.push_back(i);'),
 ('vm04_deepnx','r = iarr[h.k].nx.nx.get();'),('vm05_twomem','r = iarr[h.hh.k].get();'),('vm06_memsel','r = iarr[h.idx[i]].get();'),
 ('vm07_twice','r = iarr[h.k].get() + iarr[hd.k].get();'),('vm08_ifcond','if (iarr[h.k].get() > 0) r = 1;'),
 ('vm09_terntrue','r = iarr[c ? h.k : j].get();'),('vm10_ternfalse','r = iarr[c ? j : h.k].get();'),('vm11_callarg','r = iarr[fn(h.k)].get();'),
 ('vm12_voidstmt','iarr[h.k].run();'),('vm13_rand','r = iarr[h.k].randomize();'),('vm14_ctl_field','r = iarr[h.k].g[i];'),
 ('vm19_twod_a','r = i2[h.k][i].get();'),('vm19_twod_b','r = i2[i][h.k].get();'),('vm20_syscall','r = iarr[$clog2(h.k)].get();'),
 ('vm22_this','r = this.iarr[h.k].get();'),('vm23_thisidx','r = iarr[this.h.k].get();'),('vm24_cast','r = iarr[int\'(h.k)].get();'),
 ('vm26_enumname','str = earr[h.k].name();'),('vm28_concat','r = iarr[{h.k}].get();'),('vm29_unary','r = iarr[-h.k].get();'),
 ('vm33_deepsel','r = harr[h.k].arr[hd.k].get();'),('vm34_foreach','foreach (iarr[n]) r = iarr[h.idx[n]].get();'),
 ('vm36_strkey','r = smap[h.s].get();'),('vm39_argpath','r = iarr[h.k].put(hd.k);'),('vm42_macro','`define IX h.k\n    r = iarr[`IX].get();'),
 ('vm43_macrocall','`define CALL(a) iarr[a].get()\n    r = `CALL(h.k);'),('vm52_struct','r = iarr[s.k].get();'),('vm53_structsel','r = iarr[s.idx[i]].get();'),
 ('vm57_noparen','r = iarr[h.k].get;'),('vm58_static','r = iarr[h.k].sget();'),('vm60_fork','fork r = iarr[h.k].get(); join_none'),
 ('vm61_harrsel','r = harr[i].arr[h.k].get();'),('vm62_ctl_harr','r = harr[h.k].arr[i].f;'),('vm63_cmp','r = (iarr[h.k].get() == iarr[i].get());'),
 ('vm64_while','while (iarr[h.k].get() < 3) r++;'),('vm65_ret','r = fn(iarr[h.k].get());'),('vm66_nxsel','r = iarr[h.k].nx.g[i];'),
 ('vm67_rhsidx_lv','ia[iarr[h.k].get()] = r;'),('vm68_case','case (iarr[h.k].get()) 0: r = 1; default: r = 0; endcase'),
 ('vm69_display','$display("%0d", iarr[h.k].get());'),('vm70_dqrev','harr[h.k].q.reverse();'),('vm71_qsum','r = harr[h.k].q.sum();'),
 ('vm72_qfindwith','begin int qq[$]; qq = harr[h.k].q.find_first_index(x) with (x > 0); end'),('vm73_hidx','r = harr[h.k].hh.arr[i].get();')]:
    C('VM', n, M, b)
C('VM','vm47_extern',M,'r = 0;', extra='  extern function void p2();\nendclass\nfunction void grid::p2(); r = iarr[h.k].get(); endfunction\nclass dummy;')
C('VM','vm48_super',M,'r = 0;', extra='endclass\nclass der extends grid; function void p3(); r = super.iarr[h.k].get(); endfunction')
C('VM','vm45_pkgcls',M,'r = iarr[h.k].get();', tmpl=CLS.replace('typedef struct { int k;','package q; import p::*;\ntypedef struct { int k;').replace('endclass\nmodule top','endclass endpackage\nmodule top'))
C('VM','vm46_paramcls',M,'r = iarr[h.k].get();', tmpl=CLS.replace('class grid;','class grid #(int W = 4);').replace('module top; endmodule','module top; grid #(3) g3; endmodule'))
C('VM','vm51_module',M,'', tmpl=PKG+"""class item; int f; function int get(); return f; endfunction endclass
class holder; int k; int idx[4]; endclass
module top; item iarr[4]; holder h; int r; int i;
  initial r = iarr[h.k].get();
  always @(i) r = iarr[h.idx[i]].get();
endmodule
""")
C('VM','vm54_iface',M,'', tmpl=PKG+"""class item; int f; function int get(); return f; endfunction endclass
class holder; int k; endclass
interface ifc; item iarr[4]; holder h; int r; initial r = iarr[h.k].get(); endinterface
module top; ifc u(); endmodule
""")
C('VM','vm55_gen',M,'', tmpl=PKG+"""class item; int f; function int get(); return f; endfunction endclass
typedef struct { int k; } s_t;
module top; item iarr[4]; s_t s; int r;
  for (genvar g = 0; g < 2; g++) begin : gb initial r = iarr[s.k + g].get(); end
  if (1) begin : ib initial r = iarr[s.k].get(); end
endmodule
""")
C('VM','vm56_vif',M,'', tmpl=PKG+"""interface ifc; int k; endinterface
class item; int f; function int get(); return f; endfunction endclass
class grid; virtual ifc vif; item iarr[4]; int r; function void probe(); r = iarr[vif.k].get(); endfunction endclass
module top; ifc u(); endmodule
""")
C('VM','vm59_inc',M,'`include "inc.svh"\n    r = iarr[`IX2].get();')
L='lvNestShapeMidIdxAtSel310'
for n,b in [('vl01_nba','iarr[h.arr[i].f].f <= r;'),('vl02_op','iarr[h.arr[i + 1].f].f = r;'),('vl03_call','iarr[h.arr[fn(i)].f].f = r;'),
 ('vl04_sel','iarr[h.arr[midx[i]].f].f = r;'),('vl05_tail','iarr[h.arr[i].f].g[j] = r;'),('vl06_postinc','iarr[h.arr[i].f].f++;'),
 ('vl07_pathidx','iarr[h.arr[hd.k].f].f = r;'),('vl08_hh','iarr[h.hh.arr[i].f].f = r;'),('vl09_concat','{iarr[h.arr[i].f].f, r} = 2;'),
 ('vl10_compound','iarr[h.arr[i].f].f += r;'),('vl14_nx','iarr[h.arr[i].nx.f].f = r;'),('vl16_const','iarr[h.arr[1].f].f = r;'),
 ('vl17_cast','iarr[h.arr[int\'(i)].f].f = r;'),('vl18_tern','iarr[h.arr[c ? i : j].f].f = r;'),('vl20_both','iarr[h.arr[i].f].f = iarr[h.arr[j].f].f;'),
 ('vl22_foreach','foreach (ia[n]) iarr[h.arr[n].f].f = r;'),('vl23_opover','iarr[h.arr[i].f + 1].f = r;'),('vl24_twosel','iarr[h.arr[i].g[j]].f = r;'),
 ('vl26_preinc','++iarr[h.arr[i].f].f;'),('vl27_harr','harr[h.arr[i].f].k = r;'),('vl28_twonest','iarr[h.arr[i].f + h.arr[j].f].f = r;'),
 ('vl29_mid2','iarr[h.harr_unused_dummy_none].f = r;' if False else 'iarr[h.hh.arr[i].nx.f].f = r;'),('vl30_unarylv','iarr[h.arr[-i].f].f = r;'),
 ('vl31_s','iarr[s.idx[i]].f = r;'),('vl32_this','this.iarr[h.arr[i].f].f = r;')]:
    C('VL', n, L, b)
for n,b in [('vl11_ff','  always_ff @(posedge clk) sa[u.a[i].k].f <= 0;'),('vl12_comb','  always_comb sa[u.a[i].k].f = j;'),
 ('vl13_gen','  for (genvar g = 0; g < 2; g++) begin : gb always_ff @(posedge clk) sa[u.a[g].k].f <= j; end'),
 ('vl15_op','  always_ff @(posedge clk) sa[u.a[i + 1].k].f <= 0;'),('vl19_call','  always_ff @(posedge clk) sa[u.a[fn(i)].k].f <= 0;'),
 ('vl21_task','  task automatic t(); sa[u.a[i].k].f = 0; endtask\n  always_ff @(posedge clk) t();'),('vl25_ifgen','  if (1) begin : ig always_comb sa[u.a[j].k].f = i; end'),
 ('vl33_ro','  always_comb r = sa[u.a[i].k].f;')]:
    C('VL', n, L, b, tmpl=MOD)
C('VL','vl34_depth',L,'',tmpl=MOD.replace('module top(','module sub(').replace('endmodule\n','endmodule\nmodule mid(input logic clk, input logic [1:0] i, j, input logic c, output logic [1:0] r); sub s(.*); endmodule\nmodule top2(input logic clk, input logic [1:0] i, j, input logic c, output logic [1:0] r); mid m(.*); endmodule\n').replace('BODY','  always_ff @(posedge clk) sa[u.a[i].k].f <= j;'))
C('VL','vl35_iface',L,'',tmpl=PKG+"""typedef struct packed { logic [1:0] f; logic [1:0] k; } e_t;
typedef struct packed { e_t [3:0] a; } u_t;
interface ifc(input logic clk); e_t [3:0] sa; u_t u; logic [1:0] i; always_ff @(posedge clk) sa[u.a[i].k].f <= 0; endinterface
module top(input logic clk); ifc x(clk); endmodule
""")
C('VL','vl36_implicit',L,'',tmpl=PKG+"""typedef struct packed { logic [1:0] f; logic [1:0] k; } e_t;
typedef struct packed { e_t [3:0] a; } u_t;
module top(input logic clk, input logic [1:0] i); e_t [3:0] sa; u_t u; assign w = i[0];
  always_ff @(posedge clk) sa[u.a[w].k].f <= 0; endmodule
""")
CT='castTsNonTrailIdxByChain310' # placeholder fixed below
CT1='castTsNestSelIdxByChain310'; CT2='castTsLvIdxByChain310'
for n,law,b in [('vc01_byte',CT1,'r = iarr[midx[byte\'(h.k)]].f;'),('vc02_lvnest',CT1,'iarr[midx[int\'(i)]].f = r;'),('vc03_postinc',CT2,'h.idx[int\'(i)]++;'),
 ('vc04_predec',CT2,'--h.idx[int\'(i)];'),('vc05_compound',CT2,'h.arr[int\'(i)].f += r;'),('vc07_op',CT2,'h.arr[int\'(i) + 1].f = r;'),
 ('vc08_tdcast',CT2,'h.arr[myint\'(i)].f = r;'),('vc09_unsigned',CT2,'h.arr[unsigned\'(i)].f = r;'),('vc10_callarg',CT2,'h.arr[fn(int\'(i))].f = r;'),
 ('vc11_trail',CT1,'r = h.arr[1].g[midx[int\'(i)]];'),('vc12_lead',CT1,'r = h.arr[midx[int\'(i)]].g[0];'),('vc13_ctl_direct',CT1,'r = h.arr[i].g[int\'(i)];'),
 ('vc15_lvpath',CT2,'h.arr[int\'(hd.k)].f = r;'),('vc16_nba',CT2,'h.arr[int\'(i)].f <= r;'),('vc17_tern',CT2,'h.arr[c ? int\'(i) : j].f = r;'),
 ('vc18_twocast',CT1,'r = iarr[midx[int\'(i)] + midx[int\'(j)]].f;'),('vc19_sizecast',CT2,'h.arr[2\'(i)].f = r;'),('vc20_signedcast',CT2,'h.arr[signed\'(i)].f = r;'),
 ('vc21_lvtrail',CT2,'h.idx[int\'(i)] = r;'),('vc22_lvconcat',CT2,'{h.idx[int\'(i)], r} = 2;'),('vc23_pkgcast',CT2,'h.idx[p::f(int\'(i))] = r;'),
 ('vc24_nest2',CT1,'r = iarr[midx[midx[int\'(i)]]].f;'),('vc25_rdtrail2',CT1,'r = h.idx[midx[int\'(i)]];'),('vc26_methrecv',CT1,'r = iarr[midx[int\'(i)]].get();')]:
    C('VC', n, law, b, extra='')
for k in list(cases):
    if k[1]=='vc08_tdcast': cases[k]=cases[k].replace('class grid;','typedef int myint;\nclass grid;')
for n,law,b in [('vc06_mod',CT2,'  always_comb sa[int\'(i)].f = j;'),('vc14_modrd',CT1,'  always_comb r = sa[midx[int\'(i)]].f;'),
 ('vc27_modnest',CT1,'  always_comb sa[midx[int\'(i)]].f = j;'),('vc28_modgen',CT2,'  for (genvar g = 0; g < 2; g++) begin : gb always_comb sa[int\'(i) + g].k = j; end'),
 ('vc29_modff',CT2,'  always_ff @(posedge clk) sa[2\'(i)].f <= j;')]:
    C('VC', n, law, b, tmpl=MOD)
T='clsLvTrailIdxNamesByChain310'
for n,b in [('vt01_base','h.idx[i + 1] = r;'),('vt02_ctl_direct','h.idx[i] = r;'),('vt03_deep','h.idx[ia[midx[j]]] = r;'),('vt04_hh','h.hh.idx[i + 1] = r;'),
 ('vt05_this','this.h.idx[i + 1] = r;'),('vt06_nba','h.idx[i + 1] <= r;'),('vt07_inc','h.idx[i + 1]++;'),('vt08_local','begin int k; k = 1; h.idx[k + 1] = r; end'),
 ('vt10_pkgparam','h.idx[p::N + i] = r;'),('vt13_foreach','foreach (ia[n]) h.idx[n + 1] = r;'),('vt15_twod','h.idx2[i + 1][j + 1] = r;'),
 ('vt16_vec','h.v[i + 1] = 1\'b1;'),('vt17_ips','h.v[i +: 2] = 2\'b1;'),('vt20_enumcast','h.idx[e_t\'(i)] = r;'),('vt21_sys','h.idx[$clog2(i)] = r;'),
 ('vt24_struct','s.idx[i + 1] = r;'),('vt27_thispath','h.idx[this.i + 1] = r;'),('vt28_pathop','h.idx[hd.k + 1] = r;'),('vt29_nestsel','h.idx[h.idx[i] + 1] = r;'),
 ('vt30_ternlv','h.idx[c ? i : j] = r;'),('vt31_compound','h.idx[i * 2] -= r;'),('vt32_stat','h.idx[sfn(i)] = r;'),('vt33_harr','harr[i].idx[j + 1] = r;'),
 ('vt34_selroot','harr[i + 1].idx[j] = r;'),('vt35_rhs_ctl','r = h.idx[i + 1];'),('vt36_concat','{h.idx[i + 1], r} = 2;'),('vt37_memfn','h.idx[iarr[i].get()] = r;'),
 ('vt38_globalvar','h.idx[gv + 1] = r;')]:
    C('VT', n, T, b)
for k in list(cases):
    if k[1] in ('vm53_structsel','vt24_struct','vl31_s'): cases[k]=cases[k].replace('typedef struct { int k; int m; } s_t;','typedef struct { int k; int idx[4]; } s_t;')
    if k[1]=='vt38_globalvar': cases[k]=cases[k].replace('class grid;','int gv;\nclass grid;')
C('VT','vt09_formal',T,'r = 0;',extra='  function void p2(int x); h.idx[x + 1] = r; endfunction')
C('VT','vt12_task',T,'r = 0;',extra='  task t2(); h.idx[i + 1] = r; endtask')
C('VT','vt11_clsparam',T,'h.idx[W + i] = r;',tmpl=CLS.replace('class grid;','class grid #(int W = 1);').replace('module top; endmodule','module top; grid #(2) g; endmodule'))
C('VT','vt14_nested',T,'r = 0;',extra='  class inner; holder h; int i; int r; function void p4(); h.idx[i + 1] = r; endfunction endclass')
C('VT','vt25_extern',T,'r = 0;',extra='  extern function void p2();\nendclass\nfunction void grid::p2(); h.idx[i + 1] = r; endfunction\nclass dummy;')
C('VT','vt26_pkgcls',T,'h.idx[i + 1] = r;',tmpl=CLS.replace('typedef struct { int k;','package q; import p::*;\ntypedef struct { int k;').replace('endclass\nmodule top','endclass endpackage\nmodule top'))
C('VT','vt18_modtask_ctl',T,'',tmpl=PKG+"""typedef struct { int idx[4]; } h_t;
module top; h_t h; int i; int r; task t(); h.idx[i + 1] = r; endtask initial t(); endmodule
""")
C('VT','vt39_derived',T,'r = 0;',extra='endclass\nclass der extends grid; function void p3(); h.idx[i + 1] = r; super.h.idx[i + 1] = r; endfunction')
Q1='idxCallTernTrueKeepsSpan310'; Q2='idxQualCallNameSpan310'; MP='methPathInIdxNameSpan310'
for n,law,b in [('vq01_tern',Q1,'r = iarr[c ? fn(i) : j].f;'),('vq02_nested',Q1,'r = iarr[c ? (d ? j : fn(i)) : j].f;'),('vq03_ternop',Q1,'r = iarr[(c ? fn(i) : j) + 1].f;'),
 ('vq04_callarg',Q1,'r = iarr[fn(c ? i : j)].f;'),('vq05_false',Q1,'r = iarr[c ? j : fn(i)].f;'),('vq06_cond',Q1,'r = iarr[fn(i) ? j : i].f;'),
 ('vq07_lv',Q1,'iarr[c ? fn(i) : j].f = r;'),('vq08_qualtern',Q2,'r = iarr[c ? p::f(i) : j].f;'),('vq09_qualop',Q2,'r = iarr[p::f(i) + 1].f;'),
 ('vq10_quallvop',Q2,'iarr[p::f(i) + 1].f = r;'),('vq11_qualnest',Q2,'r = iarr[midx[p::f(i)]].f;'),('vq12_qualtrail',Q2,'r = h.idx[p::f(i)];'),
 ('vq15_qualqual',Q2,'r = iarr[p::f(p::f(i))].f;'),('vq16_pkgparam_ctl',Q2,'r = iarr[p::N + i].f;'),('vq17_clsscope',Q2,'r = iarr[grid::sfn(i)].f;'),
 ('vq19_macro',Q2,'`define PF p::f\n    r = iarr[`PF(i)].f;'),('vq20_import_ctl',Q2,'r = iarr[f(i)].f;'),('vq21_blanks',Q2,'r = iarr[ p::f( i ) ].f;'),
 ('vq24_bothcalls',Q1,'r = iarr[c ? fn(i) : fn(j)].f;'),('vq25_meth_tern',MP,'r = iarr[c ? iarr[i].get() : j].f;'),('vq26_meth_op',MP,'r = iarr[iarr[i].get() + 1].f;'),
 ('vq27_meth_lv',MP,'iarr[iarr[i].get()].f = r;'),('vq28_meth_mem',MP,'r = h.arr[iarr[i].get()].f;'),('vq29_meth_trail',MP,'r = h.idx[iarr[i].get()];'),
 ('vq30_qualrecv',Q2,'r = iarr[p::f(i)].get();'),('vq31_qualincdec',Q2,'iarr[p::f(i)].f++;'),('vq32_qualnb',Q2,'iarr[p::f(i)].f <= r;'),
 ('vq33_ternrecv',Q1,'r = iarr[c ? fn(i) : j].get();'),('vq34_ternlvnest',Q1,'iarr[midx[c ? fn(i) : j]].f = r;'),('vq35_qualcallnest',Q2,'r = iarr[fn(p::f(i))].f;')]:
    C('VQ', n, law, b, extra='')
for k in list(cases):
    if k[1]=='vq20_import_ctl': cases[k]=cases[k].replace('class grid;','import p::*;\nclass grid;').replace('function int fn(int x)','function int fn0(int x)')
for n,law,b in [('vq13_mod',Q2,'  always_comb r = sa[p::f(i)].f;'),('vq14_modff',Q2,'  always_ff @(posedge clk) r <= sa[p::f(i) + 1].f;'),
 ('vq18_modtern',Q1,'  always_comb r = sa[c ? fn(i) : j].f;'),('vq22_modgen',Q2,'  for (genvar g = 0; g < 2; g++) begin : gb always_comb sa[p::f(g)].k = j; end'),
 ('vq23_modlv',Q2,'  always_comb sa[p::f(i)].f = j;'),('vq36_modternfalse',Q1,'  always_comb r = sa[c ? j : fn(i)].f;'),('vq37_modtrail_ctl',Q2,'  always_comb r = sa[0].a[p::f(i)].f;' if False else '  always_comb r = midx[p::f(i)];'),
 ('vq38_modassign',Q2,'  assign r = sa[p::f(i)].f;'),('vq39_modnested',Q1,'  always_comb r = sa[c ? (i[0] ? fn(i) : j) : j].f;')]:
    C('VQ', n, law, b, tmpl=MOD)

for n,b in [('vm74_randwith','r = iarr[h.k].randomize() with { f > 0; };'),('vm75_inwith','begin int qq[$]; qq = ia.find(x) with (x == iarr[h.k].get()); end'),
 ('vm76_midsel','r = iarr[h.arr[i].k].get();'),('vm77_callnest','r = iarr[fn(iarr[h.k].f)].get();'),('vm78_ternmeth','r = c ? iarr[h.k].get() : iarr[hd.k].get();'),
 ('vm79_idxops','r = iarr[h.k * 2 - hd.k].get();'),('vm80_recvlv','iarr[h.k].f = iarr[hd.k].get();')]:
    C('VM', n, M, b)
C('VC','vc30_ifacefn',CT2,'',tmpl=PKG+"""typedef struct { int f; int g[4]; } e_t;
interface ifc; e_t sa[4]; int i; function void t(); sa[int'(i)].f = 1; sa[1].g[int'(i)]++; endfunction endinterface
module top; ifc u(); endmodule
""")
C('VT','vt40_ifacefn',T,'',tmpl=PKG+"""typedef struct { int idx[4]; } h_t;
interface ifc; h_t h; int i; int r; function void t(); h.idx[i + 1] = r; endfunction endinterface
module top; ifc u(); endmodule
""")
C('VL','vl37_thisbase',L,'this.iarr[this.h.arr[i].f].f = r;')

for n,b in [('vm81_rangeidx','r = iarr[h.v[1:0]].get();'),('vm82_cum1','r = harr[i].arr[midx[j]].get();'),('vm83_cum2','r = harr[midx[i]].arr[j].get();'),
 ('vm84_cum3','r = h.hh.arr[fn(i)].get();'),('vm85_cum4','r = harr[fn(i)].hh.arr[hd.k].get();'),('vm87_argrecv','r = iarr[h.k].put(iarr[hd.k].get());')]:
    C('VM', n, M, b)
for n,b in [('vq40_qualcast','r = iarr[int\'(p::f(i))].f;'),('vq41_qualsys','r = iarr[$unsigned(p::f(i))].f;'),('vq42_qualcond','r = iarr[p::f(i) ? j : i].f;'),
 ('vq43_qualfalse','r = iarr[c ? j : p::f(i)].f;'),('vq44_qualconcat','r = iarr[{p::f(i)}].f;')]:
    C('VQ', n, Q2, b)

for n,b in [('vq45_terncondcall','r = iarr[c ? (fn(i) ? j : i) : j].f;'),('vq46_terntrueop','r = iarr[c ? fn(i) + 1 : j].f;'),('vq47_ternmidsel','r = iarr[midx[c ? fn(i) : j]].f;'),
 ('vq48_terntrail_ctl','r = h.idx[c ? fn(i) : j];')]:
    C('VQ', n, Q1, b)
for n,b in [('vq49_modterncond','  always_comb r = sa[c ? (fn(i) ? j : i) : j].f;'),('vq50_modternop','  always_comb r = sa[c ? fn(i) + 1 : j].f;'),
 ('vq51_modgentern','  for (genvar g = 0; g < 2; g++) begin : gb always_comb sa[c ? fn(i) : g].k = j; end')]:
    C('VQ', n, Q1, b, tmpl=MOD)
for (g,n),t in cases.items():
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(t)
    if n=='vm59_inc': open(os.path.join(d,'inc.svh'),'w').write('`define IX2 h.k\n')
print(len(cases))
