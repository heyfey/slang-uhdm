#!/bin/bash
# r11u312 gen312.sh: writes the grid under ../cases/<GROUP>/<case>/dut.sv through mkcase.sh (each case's first line
# names its law).  cls = pass 310's class template (class grid, method probe()); raw = the whole file.
H=$(cd "$(dirname "$0")" && pwd); C=$H/../cases
c(){ bash "$H/mkcase.sh" "$C/$1" "$2" cls "    $3"; }
r(){ bash "$H/mkcase.sh" "$C/$1" "$T" raw "$(printf "%s\n" "$2" | sed 1d)"; }
T=lvIdxThisPathIsRead312
c TH/th01_direct $T 'h.idx[this.i] = r;'
c TH/th02_op $T 'h.idx[this.i + 1] = r;'
c TH/th03_nontrail $T 'h.arr[this.i].f = r;'
c TH/th04_var $T 'ia[this.i] = r;'
c TH/th05_thisbase_ctl $T 'this.ia[this.i] = r;'
c TH/th06_compound $T 'ia[this.i] += 1;'
c TH/th07_twomem_ctl $T 'h.idx[this.h.k] = r;'
c TH/th08_incdec_ctl $T 'ia[this.i]++;'
c TH/th09_concat $T '{ia[this.i], r} = 2;'
c TH/th10_ternary $T 'h.idx[c ? this.i : j] = r;'
c TH/th11_callarg_ctl $T 'h.idx[fn(this.i)] = r;'
c TH/th12_nestsel $T 'ia[ia[this.i]] = r;'
c TH/th13_nba $T 'h.idx[this.i] <= r;'
c TH/th14_rvalue_ctl $T 'r = ia[this.i];'
c TH/th15_twod $T 'h.idx2[this.i][j] = r;'
c TH/th16_ips $T "h.v[this.i +: 2] = 2'b0;"
c TH/th17_cast $T "ia[int'(this.i)] = r;"
r TH/th18_super_ctl "// § $T
class base; int i; endclass
class grid extends base; int ia[4]; int r; function void probe(); ia[super.i] = r; endfunction endclass
module top; endmodule"
c TH/th19_unary $T 'ia[-this.i] = r;'
c TH/th20_incdec_idx $T 'ia[this.i++] = r;'
r TH/th21_extern "// § $T
class grid; int ia[4]; int i; int r; extern function void probe(); endclass
function void grid::probe(); ia[this.i] = r; endfunction
module top; endmodule"
r TH/th22_paramcls "// § $T
class pc #(int N = 1); int ia[4]; int i; function void probe(); ia[this.i + N] = 1; endfunction endclass
module top; pc #(2) x; initial x = new; endmodule"
r TH/th23_derived "// § $T
class base; int i; endclass
class grid extends base; int ia[4]; int r; function void probe(); ia[this.i] = r; endfunction endclass
module top; endmodule"
mkdir -p $C/TH/th24_macro_inc; printf '`define IX this.i\n' > $C/TH/th24_macro_inc/defs.svh
r TH/th24_macro_inc "// § $T
\`include \"defs.svh\"
class grid; int ia[4]; int i; int r; function void probe(); ia[\`IX] = r; endfunction endclass
module top; endmodule"
r TH/th25_pkgcls "// § $T
package p; class grid; int ia[4]; int i; int r; function void probe(); ia[this.i] = r; endfunction endclass endpackage
module top; endmodule"
r TH/th26_task "// § $T
class grid; int ia[4]; int i; int r; task probe(); ia[this.i] <= r; endtask endclass
module top; endmodule"
r TH/th27_ctor "// § $T
class grid; int ia[4]; int i; function new(); ia[this.i] = 0; endfunction endclass
module top; endmodule"
r TH/th28_static_ctl "// § $T
class grid; static int ia[4]; int i; function void probe(); grid::ia[this.i] = 0; endfunction endclass
module top; endmodule"
T=clsLvTrailConcatTarget312
c CC/cc01_op $T '{h.idx[i + 1], r} = 2;'
c CC/cc02_cast $T "{h.idx[int'(i)], r} = 2;"
c CC/cc03_sel $T '{r, h.idx[midx[i]]} = 2;'
c CC/cc04_two $T '{h.idx[i + 1], h.idx[j]} = 2;'
c CC/cc05_nontrail_ctl $T '{h.arr[i].k, r} = 2;'
c CC/cc06_nested $T '{{h.idx[i + 1]}, r} = 2;'
c CC/cc07_nba $T '{h.idx[i + 1], r} <= 2;'
c CC/cc08_direct_ctl $T '{h.idx[i], r} = 2;'
c CC/cc09_ternary $T '{h.idx[c ? i : j], r} = 2;'
c CC/cc10_call $T '{h.idx[fn(i)], r} = 2;'
c CC/cc11_stream_ctl $T '{>>{h.idx[i + 1], r}} = 64'"'"'h0;'
c CC/cc12_rvalue_ctl $T 'r = {h.idx[i + 1]};'
c CC/cc13_twod $T '{h.idx2[i + 1][j], r} = 2;'
c CC/cc14_deep $T '{h.hh.idx[i + 1], r} = 2;'
c CC/cc15_varsel $T '{h.idx[ia[i] + 1], r} = 2;'
c CC/cc16_unary $T '{h.idx[-i], r} = 2;'
r CC/cc17_modproc_ctl "// § $T
class holder; int idx[4]; endclass
module top; holder h; int i; int r; always_comb {h.idx[i + 1], r} = 2; endmodule"
r CC/cc18_modtask "// § $T
class holder; int idx[4]; endclass
module top; holder h; int i; int r; task t(); {h.idx[i + 1], r} = 2; endtask initial t(); endmodule"
T=modTfLvTrailIdxNamesByChain312
P='class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass'
r MD/md01_task "// § $T
$P
module top; holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask initial t(); endmodule"
r MD/md02_func "// § $T
$P
module top; holder h; int i; int r; function void f(); h.idx[i + 1] = r; endfunction initial f(); endmodule"
r MD/md03_iface "// § $T
$P
interface ifc; holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask endinterface
module top; ifc u(); endmodule"
r MD/md04_sel "// § $T
$P
module top; holder h; int i; int r; int midx[4]; task t(); h.idx[midx[i]] = r; endtask initial t(); endmodule"
r MD/md05_direct_ctl "// § $T
$P
module top; holder h; int i; int r; task t(); h.idx[i] = r; endtask initial t(); endmodule"
r MD/md06_gen "// § $T
$P
module top; for (genvar g = 0; g < 1; g++) begin : gb holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask end endmodule"
r MD/md07_program "// § $T
$P
program pg; holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask initial t(); endprogram"
r MD/md08_formal "// § $T
$P
module top; holder h; int r; task automatic t(int i); h.idx[i + 1] = r; endtask initial t(1); endmodule"
r MD/md09_twoinst "// § $T
$P
module child; holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask endmodule
module top; child c1(); child c2(); endmodule"
r MD/md10_proc_ctl "// § $T
$P
module top; holder h; int i; int r; always_comb h.idx[i + 1] = r; endmodule"
r MD/md11_concat "// § $T
$P
module top; holder h; int i; int r; task t(); {h.idx[i + 1], r} = 2; endtask initial t(); endmodule"
r MD/md12_compound "// § $T
$P
module top; holder h; int i; int r; task t(); h.idx[i + 1] += r; endtask initial t(); endmodule"
r MD/md13_call "// § $T
$P
module top; holder h; int i; int r; function int f(int x); return x; endfunction task t(); h.idx[f(i)] = r; endtask initial t(); endmodule"
r MD/md14_ternary "// § $T
$P
module top; holder h; int i; int j; bit c; int r; task t(); h.idx[c ? i : j] = r; endtask initial t(); endmodule"
r MD/md15_cast "// § $T
$P
module top; holder h; int i; int r; task t(); h.idx[int'(i)] = r; endtask initial t(); endmodule"
r MD/md17_depth3 "// § $T
$P
module leaf; holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask endmodule
module mid; leaf l(); endmodule
module top; mid m(); endmodule"
r MD/md18_gen2 "// § $T
$P
module top; for (genvar g = 0; g < 1; g++) begin : ga if (1) begin : gb holder h; int i; int r; task t(); h.idx[i + 1] = r; endtask end end endmodule"
r MD/md19_packed "// § $T
typedef struct packed { logic [3:0][7:0] idx; } h_t;
module top; h_t h; int i; logic [7:0] r; task t(); h.idx[i + 1] = r; endtask initial t(); endmodule"
r MD/md20_twod "// § $T
$P
module top; holder h; int i; int j; int r; task t(); h.idx2[i + 1][j] = r; endtask initial t(); endmodule"
r MD/md21_deep "// § $T
$P
module top; holder h; int i; int r; task t(); h.hh.idx[i + 1] = r; endtask initial t(); endmodule"
r MD/md22_nba "// § $T
$P
module top; holder h; int i; int r; task t(); h.idx[i + 1] <= r; endtask initial t(); endmodule"
r MD/md23_param "// § $T
$P
module top #(parameter int P = 1); holder h; int i; int r; task t(); h.idx[i + P] = r; endtask initial t(); endmodule"
r MD/md24_local "// § $T
$P
module top; holder h; int r; task t(); int i; h.idx[i + 1] = r; endtask initial t(); endmodule"
T=methRecvIdxAtPath312
c MI/mi01_lvtrail $T 'h.idx[iarr[i].get()] = r;'
c MI/mi02_nontrail $T 'r = iarr[iarr[i].get()].f;'
c MI/mi03_rvtrail $T 'r = h.idx[iarr[i].get()];'
c MI/mi04_lvnontrail $T 'iarr[iarr[i].get()].f = r;'
c MI/mi05_op $T 'r = iarr[iarr[i].get() + 1].f;'
c MI/mi06_tern $T 'r = iarr[c ? iarr[i].get() : j].f;'
c MI/mi07_member $T 'r = h.arr[iarr[i].get()].f;'
c MI/mi08_callarg $T 'r = iarr[fn(iarr[i].get())].f;'
c MI/mi09_opidx $T 'r = iarr[iarr[i + 1].get()].f;'
c MI/mi10_selidx $T 'r = iarr[iarr[midx[i]].get()].f;'
c MI/mi11_pathidx $T 'r = iarr[iarr[h.k].get()].f;'
c MI/mi12_deeprecv $T 'r = iarr[iarr[i].nx.get()].f;'
c MI/mi13_var $T 'r = ia[iarr[i].get()];'
c MI/mi14_lvvar $T 'ia[iarr[i].get()] = r;'
c MI/mi15_methouter $T 'r = iarr[iarr[i].get()].get();'
c MI/mi16_twod $T 'r = iarr[i2[i][j].get()].f;'
c MI/mi17_args $T 'r = iarr[iarr[i].put(j)].f;'
c MI/mi18_top_ctl $T 'r = iarr[i].get();'
c MI/mi19_arg_ctl $T 'r = fn(iarr[i].get());'
c MI/mi20_ips $T "h.v[iarr[i].get() +: 2] = 2'b0;"
c MI/mi21_nba $T 'h.idx[iarr[i].get()] <= r;'
c MI/mi22_compound $T 'h.idx[iarr[i].get()] += r;'
c MI/mi23_concat $T '{h.idx[iarr[i].get()], r} = 2;'
c MI/mi24_cond $T 'if (ia[iarr[i].get()] > 0) r = 1;'
c MI/mi25_twoidx $T 'r = iarr[iarr[i].get() + iarr[j].get()].f;'
c MI/mi26_this $T 'r = iarr[this.iarr[i].get()].f;'
c MI/mi27_constidx $T 'r = iarr[iarr[1].get()].f;'
c MI/mi28_nested2 $T 'r = iarr[iarr[iarr[i].get()].get()].f;'
r MI/mi29_extern "// § $T
class item; int f; function int get(); return f; endfunction endclass
class grid; item iarr[4]; int i; int r; extern function void probe(); endclass
function void grid::probe(); r = iarr[iarr[i].get()].f; endfunction
module top; endmodule"
r MI/mi30_paramcls "// § $T
class item; int f; function int get(); return f; endfunction endclass
class pc #(int N = 1); item iarr[4]; int i; int r; function void probe(); r = iarr[iarr[i].get() + N].f; endfunction endclass
module top; pc #(2) x; initial x = new; endmodule"
r MI/mi31_module "// § $T
class item; int f; function int get(); return f; endfunction endclass
module top; item iarr[4]; int i; int r; int ia[4]; initial r = ia[iarr[i].get()]; endmodule"
r MI/mi32_pkgcls "// § $T
package p; class item; int f; function int get(); return f; endfunction endclass
class grid; item iarr[4]; int i; int r; function void probe(); r = iarr[iarr[i].get()].f; endfunction endclass endpackage
module top; endmodule"
mkdir -p $C/MI/mi33_macro_inc; printf '`define RX iarr[i].get()\n' > $C/MI/mi33_macro_inc/defs.svh
r MI/mi33_macro_inc "// § $T
\`include \"defs.svh\"
class item; int f; function int get(); return f; endfunction endclass
class grid; item iarr[4]; int i; int r; function void probe(); r = iarr[\`RX].f; endfunction endclass
module top; endmodule"
r MI/mi34_pure "// § $T
virtual class vb; pure virtual function int get(); endclass
class grid; vb iarr[4]; int ia[4]; int i; int r; function void probe(); r = ia[iarr[i].get()] + iarr[iarr[i].get()].get(); endfunction endclass
module top; endmodule"
r MI/mi35_static "// § $T
class item; int f; function int get(); return f; endfunction endclass
class grid; static item iarr[4]; static int ia[4]; static function void probe(int i); ia[iarr[i].get()] = 1; endfunction endclass
module top; endmodule"
r MI/mi36_foreach "// § $T
class item; int f; function int get(); return f; endfunction endclass
class grid; item iarr[4]; int ia[4]; int r; function void probe(); foreach (ia[i]) r = iarr[iarr[i].get()].f; endfunction endclass
module top; endmodule"
T=lvMethPathInIdxNameSpan312
c LS/ls01_base $T 'iarr[iarr[i].get()].f = r;'
c LS/ls02_op $T 'iarr[iarr[i].get() + 1].f = r;'
c LS/ls03_tern $T 'iarr[c ? iarr[i].get() : j].f = r;'
c LS/ls04_terfalse $T 'iarr[c ? j : iarr[i].get()].f = r;'
c LS/ls05_member $T 'h.arr[iarr[i].get()].f = r;'
c LS/ls06_nba $T 'iarr[iarr[i].get()].f <= r;'
c LS/ls07_compound $T 'iarr[iarr[i].get()].f += r;'
c LS/ls08_incdec $T 'iarr[iarr[i].get()].f++;'
c LS/ls09_trail_ctl $T 'h.idx[iarr[i].get()] = r;'
c LS/ls10_rvalue_ctl $T 'r = iarr[iarr[i].get()].f;'
c LS/ls11_callarg $T 'iarr[fn(iarr[i].get())].f = r;'
c LS/ls12_deep $T 'h.arr[iarr[i].get()].nx.f = r;'
c LS/ls13_concat $T '{iarr[iarr[i].get()].f, r} = 2;'
c LS/ls14_args $T 'iarr[iarr[i].put(j)].f = r;'
c LS/ls15_selidx $T 'iarr[iarr[midx[i]].get()].f = r;'
c LS/ls16_var_ctl $T 'ia[iarr[i].get()] = r;'
T=lvIpsNameFollowsHpRender312
c IP/ip01_path $T "h.v[h.k +: 2] = 2'b0;"
c IP/ip02_methpath $T "h.v[iarr[i].f +: 2] = 2'b0;"
c IP/ip03_this $T "h.v[this.i +: 2] = 2'b0;"
c IP/ip04_meth $T "h.v[iarr[i].get() +: 2] = 2'b0;"
c IP/ip05_down $T "h.v[h.k -: 2] = 2'b0;"
c IP/ip06_rvalue_ctl $T "r = h.v[h.k +: 2];"
c IP/ip07_ref_ctl $T "h.v[i +: 2] = 2'b0;"
c IP/ip08_op_ctl $T "h.v[i + 1 +: 2] = 2'b0;"
c IP/ip09_nba $T "h.v[h.k +: 2] <= 2'b0;"
c IP/ip10_deep $T "h.hh.v[h.k +: 2] = 2'b0;"
c IP/ip11_widthref $T "h.v[h.k +: p::N] = 1'b0;"
r IP/ip12_module "// § $T
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; s_t b; always_comb a.v[b.k +: 2] = 2'b0; endmodule"
r IP/ip13_modrv_ctl "// § $T
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; s_t b; logic [1:0] o; assign o = a.v[b.k +: 2]; endmodule"
r IP/ip14_modtask "// § $T
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; s_t b; task t(); a.v[b.k +: 2] = 2'b0; endtask initial t(); endmodule"
T=ipsBaseSelCallRender312
c IP/ip20_sel $T "h.v[ia[i] +: 2] = 2'b0;"
c IP/ip21_call $T "h.v[fn(i) +: 2] = 2'b0;"
c IP/ip22_selconst $T "h.v[ia[1] +: 2] = 2'b0;"
c IP/ip23_rvsel $T "r = h.v[ia[i] +: 2];"
c IP/ip24_rvcall $T "r = h.v[fn(i) +: 2];"
c IP/ip25_selop_ctl $T "h.v[ia[i + 1] +: 2] = 2'b0;"
c IP/ip26_sys_ctl $T "h.v[\$clog2(i) +: 2] = 2'b0;"
c IP/ip27_static $T "h.v[sfn(i) +: 2] = 2'b0;"
c IP/ip28_pkgcall $T "h.v[p::f(i) +: 2] = 2'b0;"
r IP/ip29_module "// § $T
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; logic [3:0] ix [4]; int i; always_comb a.v[ix[i] +: 2] = 2'b0; endmodule"
r IP/ip30_modcall "// § $T
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; int i; function automatic int f(int x); return x; endfunction always_comb a.v[f(i) +: 2] = 2'b0; endmodule"
r IP/ip31_modrv "// § $T
typedef struct packed { logic [3:0] k; logic [15:0] v; } s_t;
module top; s_t a; logic [3:0] ix [4]; int i; logic [1:0] o; assign o = a.v[ix[i] +: 2]; endmodule"
T=lvIdxThisPathIsRead312
c TH/th29_preinc $T 'ia[++this.i] = r;'
c TH/th30_postdec_op $T 'ia[this.i-- + 1] = r;'
T=lateCallIdxNameSpan312
B='class item; int f; item nx; function int get(); return f; endfunction endclass
class holder; int k; int idx[4]; endclass
class grid; item iarr[4]; int ia[4]; holder h; int i; int j; bit c; int r;'
E='function int fwd(int y); return y; endfunction endclass
module top; endmodule'
r LC/lc01_recv "// § $T
$B function void probe(); r = iarr[fwd(h.k)].get(); endfunction $E"
r LC/lc02_named "// § $T
$B function void probe(); r = iarr[fwd(.y(h.k))].get(); endfunction $E"
r LC/lc03_path "// § $T
$B function void probe(); r = iarr[fwd(i)].f; endfunction $E"
r LC/lc04_op "// § $T
$B function void probe(); r = iarr[fwd(i) + 1].f; endfunction $E"
r LC/lc05_tern "// § $T
$B function void probe(); r = iarr[c ? fwd(i) : j].f; endfunction $E"
r LC/lc06_trail_ctl "// § $T
$B function void probe(); r = h.idx[fwd(i)]; endfunction $E"
r LC/lc07_var_ctl "// § $T
$B function void probe(); r = ia[fwd(i)]; endfunction $E"
r LC/lc08_lv "// § $T
$B function void probe(); iarr[fwd(i)].f = r; endfunction $E"
r LC/lc09_above_ctl "// § $T
$B function int fwd0(int y); return y; endfunction function void probe(); r = iarr[fwd0(i)].f; endfunction $E"
r LC/lc10_deep "// § $T
$B function void probe(); r = iarr[fwd(i)].nx.f; endfunction $E"
r LC/lc11_terfalse "// § $T
$B function void probe(); r = iarr[c ? j : fwd(i)].f; endfunction $E"
r LC/lc12_nested "// § $T
$B function void probe(); r = iarr[ia[fwd(i)]].f; endfunction $E"
r LC/lc13_arg_ctl "// § $T
$B function void probe(); r = fwd(iarr[i].f); endfunction $E"
r LC/lc14_task "// § $T
$B task probe(); r = iarr[fwd(i)].f; endtask $E"
T=lvRootSelCallNameSpan312
c LR/lr01_cls $T 'iarr[fn(i)].f = r;'
c LR/lr02_member_ctl $T 'h.arr[fn(i)].f = r;'
c LR/lr03_trail_ctl $T 'h.idx[fn(i)] = r;'
c LR/lr04_var_ctl $T 'ia[fn(i)] = r;'
c LR/lr05_op $T 'iarr[fn(i) + 1].f = r;'
c LR/lr06_tern_ctl $T 'iarr[c ? fn(i) : j].f = r;'
c LR/lr07_static $T 'iarr[sfn(i)].f = r;'
c LR/lr08_pkg_ctl $T 'iarr[p::f(i)].f = r;'
c LR/lr09_nba $T 'iarr[fn(i)].f <= r;'
c LR/lr10_compound $T 'iarr[fn(i)].f += r;'
c LR/lr11_terfalse $T 'iarr[c ? j : fn(i)].f = r;'
c LR/lr12_nested $T 'iarr[ia[fn(i)]].f = r;'
c LR/lr13_deep $T 'iarr[fn(i)].nx.f = r;'
c LR/lr14_concat $T '{iarr[fn(i)].f, r} = 2;'
c LR/lr15_rvalue_ctl $T 'r = iarr[fn(i)].f;'
c LR/lr16_twoarg $T 'iarr[fn(fn(i))].f = r;'
r LR/lr17_modproc "// § $T
typedef struct packed { logic [3:0] b; } s_t;
module top; s_t m [4]; int i; function automatic int fn(int x); return x; endfunction always_comb m[fn(i)].b = 0; endmodule"
r LR/lr18_modtask "// § $T
typedef struct packed { logic [3:0] b; } s_t;
module top; s_t m [4]; int i; function automatic int fn(int x); return x; endfunction task t(); m[fn(i)].b = 0; endtask endmodule"
r LR/lr19_modmember_ctl "// § $T
typedef struct packed { logic [3:0] b; } s_t;
typedef struct packed { s_t [3:0] a; } t_t;
module top; t_t m; int i; function automatic int fn(int x); return x; endfunction always_comb m.a[fn(i)].b = 0; endmodule"
r LR/lr20_modff "// § $T
typedef struct packed { logic [3:0] b; } s_t;
module top; s_t m [4]; int i; logic clk; function automatic int fn(int x); return x; endfunction always_ff @(posedge clk) m[fn(i)].b <= 0; endmodule"
r LR/lr21_gen "// § $T
typedef struct packed { logic [3:0] b; } s_t;
module top; for (genvar g = 0; g < 1; g++) begin : gb s_t m [4]; int i; always_comb m[fn(i)].b = 0; end function automatic int fn(int x); return x; endfunction endmodule"
r LR/lr22_iface "// § $T
typedef struct packed { logic [3:0] b; } s_t;
interface ifc; s_t m [4]; int i; function automatic int fn(int x); return x; endfunction always_comb m[fn(i)].b = 0; endinterface
module top; ifc u(); endmodule"
r LR/lr23_cont_ctl "// § $T
typedef struct packed { logic [3:0] b; } s_t;
module top; s_t m [4]; function automatic int fn(int x); return x; endfunction assign m[fn(1)].b = 0; endmodule"
r LR/lr24_sys_ctl "// § $T
typedef struct packed { logic [3:0] b; } s_t;
module top; s_t m [4]; int i; always_comb m[\$clog2(i)].b = 0; endmodule"
r LR/lr25_late "// § $T
class item; int f; endclass
class grid; item iarr[4]; int i; int r; function void probe(); iarr[fwd(i)].f = r; endfunction function int fwd(int y); return y; endfunction endclass
module top; endmodule"
T=memberSelCallIdxParenSpan312
c MS/ms01_meth $T 'r = h.idx[iarr[i].get()];'
c MS/ms02_noarg $T 'r = h.idx[item::sget()];'
c MS/ms03_methargs $T 'r = h.idx[iarr[i].put(j)];'
c MS/ms04_args_ctl $T 'r = h.idx[fn(i)];'
c MS/ms05_path_ctl $T 'r = h.idx[h.hh.k];'
c MS/ms06_deep $T 'r = h.hh.idx[iarr[i].get()];'
c MS/ms07_op_ctl $T 'r = h.idx[iarr[i].get() + 1];'
c MS/ms08_paren $T 'r = h.idx[(iarr[i].get())];'
c MS/ms09_chain $T 'r = h.idx[iarr[i].nx.get()];'
r MS/ms10_module "// § $T
typedef struct packed { logic [3:0][7:0] f; } s_t;
module top; s_t s; logic [7:0] o; function automatic int fn(); return 1; endfunction always_comb o = s.f[fn()]; endmodule"
r MS/ms11_modargs_ctl "// § $T
typedef struct packed { logic [3:0][7:0] f; } s_t;
module top; s_t s; logic [7:0] o; function automatic int fn(int x); return x; endfunction always_comb o = s.f[fn(1)]; endmodule"
r MS/ms12_cont "// § $T
typedef struct packed { logic [3:0][7:0] f; } s_t;
module top; s_t s; logic [7:0] o; function automatic int fn(); return 1; endfunction assign o = s.f[fn()]; endmodule"
T=methRecvIdxAtPath312
c MI/mi37_methargs_ctl $T 'str = h.s.substr(1, j - iarr[i].get());'
c MI/mi38_methofmeth_ctl $T 'r = iarr[i].put(iarr[j].get());'
c MI/mi39_methargidx $T 'r = iarr[i].put(ia[iarr[j].get()]);'
T=lvRootSelCallNameSpan312
c LR/lr26_named $T 'iarr[fn(.x(i))].f = r;'
r LR/lr27_implicit "// § $T
typedef struct packed { logic [3:0] b; } s_t;
module top; s_t m [4]; function automatic int fn(int x); return x; endfunction assign w = 1'b1; always_comb m[fn(w)].b = 0; endmodule"
r LR/lr28_extern_below "// § $T
class item; int f; endclass
class grid; item iarr[4]; int i; int r; extern function int fn(int x); function void probe(); iarr[fn(i)].f = r; endfunction endclass
function int grid::fn(int x); return x; endfunction
module top; endmodule"
T=methRecvIdxAtPath312
c MI/mi40_named $T 'r = iarr[iarr[i].put(.x(j))].f;'
r MI/mi41_iface "// § $T
class item; int f; function int get(); return f; endfunction endclass
interface ifc; item iarr[4]; int i; int r; int ia[4]; initial r = ia[iarr[i].get()] + iarr[iarr[i].get()].f; endinterface
module top; ifc u(); endmodule"
T=pkgTfLvTrailIdxNamesByChain312
Q='class holder; int idx[4]; int idx2[4][4]; int k; holder hh; endclass'
r PK/pk01_func "// § $T
package p; $Q function automatic void f(holder h, int i); h.idx[i + 1] = 0; endfunction endpackage
module top; endmodule"
r PK/pk02_task "// § $T
package p; $Q task automatic t(holder h, int i); h.idx[i + 1] = 0; endtask endpackage
module top; endmodule"
r PK/pk03_concat "// § $T
package p; $Q function automatic void f(holder h, int i, output int r); {h.idx[i + 1], r} = 2; endfunction endpackage
module top; endmodule"
r PK/pk04_sel "// § $T
package p; $Q function automatic void f(holder h, int i, int m[4]); h.idx[m[i]] = 0; endfunction endpackage
module top; endmodule"
r PK/pk05_call "// § $T
package p; $Q function automatic int g(int x); return x; endfunction function automatic void f(holder h, int i); h.idx[g(i)] = 0; endfunction endpackage
module top; endmodule"
r PK/pk06_direct_ctl "// § $T
package p; $Q function automatic void f(holder h, int i); h.idx[i] = 0; endfunction endpackage
module top; endmodule"
r PK/pk07_pkgvar "// § $T
package p; $Q holder g; int k; function automatic void f(); g.idx[k + 1] = 0; endfunction endpackage
module top; endmodule"
r PK/pk08_packed "// § $T
package p; typedef struct packed { logic [3:0][7:0] idx; } h_t; h_t s; int k; function automatic void f(); s.idx[k + 1] = 0; endfunction endpackage
module top; endmodule"
r PK/pk09_cls_ctl "// § $T
package p; $Q class c; holder h; int i; function void f(); h.idx[i + 1] = 0; endfunction endclass endpackage
module top; endmodule"
r PK/pk10_called "// § $T
package p; $Q function automatic void f(holder h, int i); h.idx[i + 1] += 1; endfunction endpackage
module top; import p::*; holder hh; initial f(hh, 1); endmodule"
r PK/pk11_nba_ternary "// § $T
package p; $Q function automatic void f(holder h, int i, int j, bit c); h.idx[c ? i : j] = 0; endfunction endpackage
module top; endmodule"
r PK/pk12_cast "// § $T
package p; $Q function automatic void f(holder h, int i); h.idx[int'(i)] = 0; endfunction endpackage
module top; endmodule"
