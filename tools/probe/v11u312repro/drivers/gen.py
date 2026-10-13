#!/usr/bin/env python3
# v11u312 gen.py: writes the fresh attack cases under ../cases/<G>/<name>/dut.sv
# (each case's first line names the law it attacks).  Class cases use r11u312's
# class template (tools/probe/r11u312repro/drivers/mkcase.sh) with three more members.
import os, sys
H = os.path.dirname(os.path.abspath(__file__)); CASES = os.path.join(os.path.dirname(H), 'cases')
PKG = "package p; localparam int N = 1; function automatic int f(int x); return x; endfunction endpackage\n"
TPL = PKG + """typedef struct { int k; int m; } s_t;
typedef enum { EA, EB } e_t;
class item; int f; int g[4]; int k; item nx; function int get(); return f; endfunction function int put(int x); return x; endfunction function void run(); endfunction static function int sget(); return 0; endfunction endclass
class holder; item arr[4]; int idx[4]; int idx2[4][4]; int k; holder hh; logic [7:0] v; string s; int q[$]; endclass
class grid;
  localparam int N2 = 1;
  item iarr[4]; item i2[4][4]; int midx[4]; int i; int j; int r; bit c; bit d; holder h; holder hd; holder harr[4]; int ia[4];
  string sarr[4]; e_t earr[4]; item smap[string]; s_t s; string str; logic [7:0] lv;
  function int fn(int x); return x; endfunction
  static function int sfn(int x); return x; endfunction
  function void probe();
%s
  endfunction
  function int fwd(int x); return x; endfunction
endclass
module top; endmodule
"""
cases = {}
def cls(g, n, law, body, pre=""):
    cases[(g, n)] = "// § %s\n" % law + pre + TPL % body
def raw(g, n, law, text):
    cases[(g, n)] = "// § %s\n" % law + text
T = 'lvIdxThisPathIsRead312'
for n, b in [('vt01_thisarr_tgt', 'this.ia[2] = r;'), ('vt02_thisarr_thisidx', 'this.ia[this.i] = r;'),
             ('vt03_thish_thisidx', 'this.h.idx[this.i] = r;'), ('vt04_thislv_ps', 'this.lv[3:0] = 0;'),
             ('vt05_thislv_ips', 'this.lv[this.i +: 2] = 0;'), ('vt06_callarg', 'ia[fn(this.i)] = r;'),
             ('vt07_incdec_tgt', 'ia[this.i]++;'), ('vt08_nested', 'ia[ia[this.i]] = r;'),
             ('vt09_concat_thisarr', '{this.ia[1], r} = 2;'), ('vt10_foreach', 'foreach (ia[k]) ia[this.i] = k;'),
             ('vt11_rhs_too', 'ia[this.i] = this.i;'), ('vt12_this_tgt_ctl', 'this.i = ia[this.i];'),
             ('vt13_thisarr_in_idx', 'ia[this.ia[this.i]] = r;'), ('vt14_struct_tgt', 'this.s.k = r;'),
             ('vt15_struct_idx', 'ia[this.s.k] = r;'), ('vt16_unary', 'ia[-this.i] = r;'),
             ('vt17_bitsel', 'ia[this.i[1:0]] = r;'), ('vt18_tern', 'ia[this.c ? this.i : 0] = r;'),
             ('vt19_compound', 'ia[this.i] += r;'), ('vt20_preinc_idx', 'ia[++this.i] = r;'),
             ('vt21_postdec_idx', 'ia[this.i--] = r;'), ('vt22_member_root', 'iarr[this.i].f = r;'),
             ('vt23_member_two', 'iarr[this.i].g[this.j] = r;'), ('vt24_syscall', 'ia[$clog2(this.i)] = r;'),
             ('vt25_lvips', 'lv[this.i +: 2] = 0;'), ('vt26_lvps_ctl', 'lv[this.i] = 1;'),
             ('vt27_assoc', 'smap[this.str].f = r;'), ('vt28_ifbody', 'if (c) ia[this.i] = r; else ia[this.j] = r;'),
             ('vt29_cast', 'ia[int\'(this.i)] = r;'), ('vt30_concat_in_idx', 'lv[{this.c, this.d}] = 1;')]:
    cls('VT', n, T, '    ' + b)
cls('VT', 'vt31_macro', T, '    ia[`IX] = r;', pre='`define IX this.i\n')
cls('VT', 'vt32_fork', T, '    fork ia[this.i] = r; join_none')
# derived / parameterized class
raw('VT', 'vt33_derived', T, PKG + """class base; int i; int ia[4]; int r; endclass
class grid extends base; function void probe(); ia[this.i] = r; ia[super.i] = r; endfunction endclass
module top; endmodule
""")
raw('VT', 'vt34_paramcls', T, """class grid #(int W = 4); int i; int ia[W]; int r; function void probe(); ia[this.i] = r; endfunction endclass
module top; grid #(8) g; endmodule
""")
raw('VT', 'vt35_task_out', T, PKG + """class grid; int i; int ia[4]; int r; task t(output int o); o = 1; endtask
  task probe(); t(ia[this.i]); endtask endclass
module top; endmodule
""")
C = 'clsLvTrailConcatTarget312'
for n, b in [('vc01_refidx', '{h.idx[i], r} = 2;'), ('vc02_two', '{h.idx[i + 1], h.idx[j]} = 4;'),
             ('vc03_member_ctl', '{h.arr[i].f, r} = 2;'), ('vc04_stream', '{>>{h.idx[i + 1], r}} = 64\'h0;'),
             ('vc05_rvalue_ctl', 'r = {h.idx[i + 1]};'), ('vc06_plain_ctl', '{ia[i + 1], r} = 2;'),
             ('vc07_deep', '{h.hh.idx[i + 1], r} = 2;'), ('vc08_catrhs', '{h.idx[i + 1], r} = {r, r};'),
             ('vc09_foreach', 'foreach (ia[k]) {h.idx[k + 1], r} = 2;'), ('vc10_case', 'case (i) 0: {h.idx[i + 1], r} = 2; default: ; endcase'),
             ('vc11_2d', '{h.idx2[i + 1][j], r} = 2;'), ('vc12_callidx', '{h.idx[fn(i)], r} = 2;'),
             ('vc13_nested3', '{{{h.idx[i + 1]}}, r} = 2;'), ('vc14_sel_in_idx', '{h.idx[ia[i] + 1], r} = 2;'),
             ('vc15_this', '{this.h.idx[i + 1], r} = 2;'), ('vc16_harr', '{harr[j].idx[i + 1], r} = 2;'),
             ('vc17_param', '{h.idx[N2 + i], r} = 2;'), ('vc18_enum', '{h.idx[EB + i], r} = 2;'),
             ('vc19_pkgparam', '{h.idx[p::N + i], r} = 2;'), ('vc20_ternrhs', '{h.idx[i + 1], r} = c ? 2 : 3;')]:
    cls('VC', n, C, '    ' + b)
M = 'modTfLvTrailIdxNamesByChain312'
HOLD = "class item; int f; function int get(); return f; endfunction endclass\nclass holder; int idx[4]; int idx2[4][4]; item arr[4]; holder hh; endclass\n"
def mod(n, body, extra="", law=M, top=None):
    raw('VM', n, law, PKG + HOLD + "typedef enum { EA, EB } e_t;\n" + (top or ("module top;\n  holder h; int r; int k; int ia[4]; localparam int P = 1; wire [1:0] w;\n" + extra + body + "\nendmodule\n")))
mod('vm01_task_arg', "  task t(input int i); h.idx[i + 1] = r; endtask")
mod('vm02_modvar_idx', "  task t(); h.idx[k + 1] = r; endtask")
mod('vm03_localparam_idx', "  task t(input int i); h.idx[P + i] = r; endtask")
mod('vm04_enum_idx', "  task t(input int i); h.idx[EB + i] = r; endtask")
mod('vm05_wire_idx', "  task t(); h.idx[w + 1] = r; endtask")
mod('vm06_auto_local', "  function automatic void f(); int i; i = 1; h.idx[i + 1] = 0; endfunction")
mod('vm07_genblk', "  if (1) begin : g\n    task t(input int i); h.idx[i + 1] = r; endtask\n  end")
mod('vm08_nba', "  task t(input int i); h.idx[i + 1] <= r; endtask")
mod('vm09_incdec_ctl', "  task t(input int i); h.idx[i + 1]++; endtask")
mod('vm10_refidx', "  task t(input int i); h.idx[i] = r; endtask")
mod('vm11_member2', "  task t(input int i); h.hh.idx[i + 1] = r; endtask")
mod('vm12_sel_idx', "  task t(input int i); h.idx[ia[i] + 1] = r; endtask")
mod('vm13_selidx_modarr', "  task t(input int i); h.idx[ia[k]] = r; endtask")
mod('vm14_2d', "  task t(input int i); h.idx2[i + 1][k] = r; endtask")
mod('vm15_methidx', "  task t(input int i); h.idx[h.arr[i].get()] = r; endtask")
mod('vm16_proc_ctl', "  always_comb h.idx[k + 1] = r;")
mod('vm17_pkgparam', "  task t(input int i); h.idx[p::N + i] = r; endtask")
mod('vm18_call', "  function int g(int x); return x; endfunction\n  task t(input int i); h.idx[g(i)] = r; endtask")
raw('VM', 'vm19_depth2', M, PKG + HOLD + """module sub; holder h; int r; task t(input int i); h.idx[i + 1] = r; endtask endmodule
module mid; sub u(); endmodule
module top; mid m(); endmodule
""")
raw('VM', 'vm20_iface', M, PKG + HOLD + """interface ifc; holder h; int r; task t(input int i); h.idx[i + 1] = r; endtask endinterface
module top; ifc u(); endmodule
""")
raw('VM', 'vm21_genfor', M, PKG + HOLD + """module top; holder h; int r;
  for (genvar g = 0; g < 2; g++) begin : gl
    task t(input int i); h.idx[i + g] = r; endtask
  end
endmodule
""")
raw('VM', 'vm22_unitfn_ctl', M, PKG + HOLD + """function automatic void uf(holder h, int i); h.idx[i + 1] = 0; endfunction
module top; endmodule
""")
raw('VM', 'vm23_packed', M, PKG + """typedef struct packed { logic [3:0][7:0] idx; } ps_t;
module top; ps_t ps; task t(input int i); ps.idx[i + 1] = 0; endtask endmodule
""")
raw('VM', 'vm24_packed_modvar', M, PKG + """typedef struct packed { logic [3:0][7:0] idx; } ps_t;
module top; ps_t ps; int k; task t(); ps.idx[k + 1] = 0; endtask endmodule
""")
raw('VM', 'vm25_two_inst', M, PKG + HOLD + """module sub; holder h; int r; int k; task t(input int i); h.idx[i + k] = r; endtask endmodule
module top; sub a(); sub b(); endmodule
""")
raw('VM', 'vm26_retvar', M, PKG + HOLD + """module top; holder h; function int f(input int i); h.idx[i + 1] = 0; f = i; endfunction endmodule
""")
raw('VM', 'vm27_static_task', M, PKG + HOLD + """module top; holder h; task static t(input int i); int j; j = i; h.idx[j + 1] = 0; endtask endmodule
""")
raw('VM', 'vm28_nested_task_call', M, PKG + HOLD + """module top; holder h; int r;
  task t(input int i); h.idx[i + 1] = r; endtask
  initial t(1);
endmodule
""")
PK = 'pkgTfLvTrailIdxNamesByChain312'
raw('VK', 'vk01_pkgvar_idx', PK, """package p; """ + HOLD + """ int g; function automatic void f(holder h); h.idx[g + 1] = 0; endfunction endpackage
module top; endmodule
""")
raw('VK', 'vk02_pkgparam_idx', PK, """package p; """ + HOLD + """ localparam int N = 1; function automatic void f(holder h, int i); h.idx[N + i] = 0; endfunction endpackage
module top; endmodule
""")
raw('VK', 'vk03_pkgtask', PK, """package p; """ + HOLD + """ task automatic t(holder h, int i); h.idx[i + 1] = 0; endtask endpackage
module top; endmodule
""")
raw('VK', 'vk04_imported_use', PK, """package p; """ + HOLD + """ function automatic void f(holder h, int i); h.idx[i + 1] = 0; endfunction endpackage
module top; import p::*; holder hh; initial f(hh, 1); endmodule
""")
raw('VK', 'vk05_concat', PK, """package p; """ + HOLD + """ function automatic void f(holder h, int i); int r; {h.idx[i + 1], r} = 2; endfunction endpackage
module top; endmodule
""")
raw('VK', 'vk06_pkgvar_holder_local', PK, """package p; """ + HOLD + """ holder g; function automatic void f(int i); int k; k = i; g.idx[k + 1] = 0; endfunction endpackage
module top; endmodule
""")
raw('VK', 'vk07_pkgclass_ctl', PK, """package p; """ + HOLD + """ class c; holder h; function void f(int i); h.idx[i + 1] = 0; endfunction endclass endpackage
module top; endmodule
""")
raw('VK', 'vk08_pkgfn_selidx', PK, """package p; """ + HOLD + """ int ga[4]; function automatic void f(holder h, int i); h.idx[ga[i] + 1] = 0; endfunction endpackage
module top; endmodule
""")
MI = 'methRecvIdxAtPath312'
for n, b in [('vi01_strlen', 'r = ia[sarr[i].len()];'), ('vi02_strlen_op', 'r = ia[sarr[i + 1].len() - 1];'),
             ('vi03_enumnext', 'r = ia[earr[i].next()];'), ('vi04_fnarg', 'r = ia[fn(iarr[i].get())];'),
             ('vi05_sysarg', 'r = ia[$clog2(iarr[i].get())];'), ('vi06_selrecvidx', 'r = ia[iarr[ia[i]].get()];'),
             ('vi07_deep', 'r = ia[iarr[i].nx.get()];'), ('vi08_member_recv', 'r = ia[h.arr[i].get()];'),
             ('vi09_tern', 'r = ia[c ? iarr[i].get() : 0];'), ('vi10_twocalls', 'r = ia[iarr[i].get() + iarr[j].get()];'),
             ('vi11_putarg', 'r = ia[iarr[i].put(j)];'), ('vi12_assoc', 'r = ia[smap["a"].get()];'),
             ('vi13_ifcond', 'if (ia[iarr[i].get()] == 0) r = 1;'), ('vi14_case', 'case (ia[iarr[i].get()]) 0: r = 1; default: ; endcase'),
             ('vi15_foreach', 'foreach (ia[k]) r += ia[iarr[k].get()];'), ('vi16_2d', 'r = i2[iarr[i].get()][j].f;'),
             ('vi17_sum', 'r = ia[iarr[i].get()] + ia[iarr[j].get()];'), ('vi18_display', '$display("%0d", ia[iarr[i].get()]);'),
             ('vi19_callarg', 'void\'(fn(ia[iarr[i].get()]));'), ('vi20_enumidx', 'r = ia[iarr[EB].get()];'),
             ('vi21_pkgidx', 'r = ia[iarr[p::N].get()];'), ('vi22_lpidx', 'r = ia[iarr[N2].get()];'),
             ('vi23_bitidx', 'r = ia[iarr[c].get()];'), ('vi24_lv_trail', 'ia[iarr[i].get()] = r;'),
             ('vi25_lv_member', 'h.arr[iarr[i].get()].f = r;'), ('vi26_lv_root', 'iarr[iarr[i].get()].g[j] = r;'),
             ('vi27_lips', 'lv[iarr[i].get() +: 2] = 0;'), ('vi28_rips', 'r = lv[iarr[i].get() +: 2];'),
             ('vi29_harr', 'r = ia[harr[i].arr[j].get()];'), ('vi30_cast', 'r = ia[int\'(iarr[i].get())];'),
             ('vi31_dowhile', 'do r--; while (ia[iarr[i].get()] > 0);'), ('vi32_whileloop', 'while (ia[iarr[i].get()] > 0) r--;'),
             ('vi33_selidx_sel', 'r = ia[iarr[midx[i]].get()];'), ('vi34_runcall', 'iarr[ia[iarr[i].get()]].run();')]:
    cls('VI', n, MI, '    ' + b)
cls('VI', 'vi35_return', MI, '    r = 0;\n  endfunction\n  function int rf(); return ia[iarr[i].get()];')
raw('VI', 'vi36_modfn', MI, PKG + """class item; int f; function int get(); return f; endfunction endclass
module top; item iarr[4]; int ia[4]; int r;
  function automatic int g(int i); return ia[iarr[i].get()]; endfunction
endmodule
""")
raw('VI', 'vi37_modtask_lv', MI, PKG + """class item; int f; function int get(); return f; endfunction endclass
class holder; int idx[4]; endclass
module top; item iarr[4]; holder h; int r;
  task t(input int i); h.idx[iarr[i].get()] = r; endtask
endmodule
""")
raw('VI', 'vi38_genblk', MI, PKG + """class item; int f; function int get(); return f; endfunction endclass
module top; item iarr[4]; int ia[4]; int r; int i;
  if (1) begin : g initial r = ia[iarr[i].get()]; end
endmodule
""")
raw('VI', 'vi39_iface', MI, PKG + """class item; int f; function int get(); return f; endfunction endclass
interface ifc; item iarr[4]; int ia[4]; int r; function automatic int g(int i); return ia[iarr[i].get()]; endfunction endinterface
module top; ifc u(); endmodule
""")
raw('VI', 'vi40_pkgfn', MI, """package q; class item; int f; function int get(); return f; endfunction endclass function automatic int g(item iarr[4], int ia[4], int i); return ia[iarr[i].get()]; endfunction endpackage
module top; endmodule
""")
IP = 'ipsBaseSelCallRender312'
for n, b in [('vp01_lpidx', 'h.v[ia[N2] +: 2] = 0;'), ('vp02_enumidx', 'h.v[ia[EB] +: 2] = 0;'),
             ('vp03_pkgidx', 'h.v[ia[p::N] +: 2] = 0;'), ('vp04_constidx', 'h.v[ia[2] +: 2] = 0;'),
             ('vp05_hexidx', 'h.v[ia[\'h2] +: 2] = 0;'), ('vp06_minus', 'h.v[ia[i] -: 2] = 0;'),
             ('vp07_width_lp', 'h.v[ia[i] +: N2] = 0;'), ('vp08_sfn', 'r = h.v[sfn(i) +: 2];'),
             ('vp09_pkgfn', 'r = h.v[p::f(i) +: 2];'), ('vp10_methbase', 'r = h.v[iarr[i].get() +: 2];'),
             ('vp11_clsscope', 'r = h.v[item::sget() +: 2];'), ('vp12_compound', 'h.v[ia[i] +: 2] += 1;'),
             ('vp13_sum', 'r = h.v[ia[i] +: 2] + h.v[ia[j] +: 2];'), ('vp14_deep', 'h.hh.v[ia[i] +: 2] = 0;'),
             ('vp15_nestsel_ctl', 'h.v[ia[ia[i]] +: 2] = 0;'), ('vp16_2d_ctl', 'h.v[i2[i][j].f +: 2] = 0;'),
             ('vp17_strlen', 'h.v[sarr[i].len() +: 2] = 0;'), ('vp18_fnselarg', 'h.v[fn(ia[i]) +: 2] = 0;'),
             ('vp19_rv_selidx', 'r = h.v[ia[i] +: 2];'), ('vp20_harr', 'harr[j].v[ia[i] +: 2] = 0;'),
             ('vp21_noarg_ctl', 'r = h.v[fn(1) +: 2];'), ('vp22_width_pkg', 'h.v[ia[i] +: p::N] = 0;'),
             ('vp23_midx', 'h.v[midx[i] +: 2] = 0;'), ('vp24_cond', 'if (h.v[ia[i] +: 2] == 0) r = 1;'),
             ('vp25_path_base', 'h.v[h.hh.k +: 2] = 0;'), ('vp26_path_base_rv', 'r = h.v[h.hh.k -: 2];')]:
    cls('VP', n, IP, '    ' + b)
def pmod(n, body, decl=""):
    raw('VP', n, IP, PKG + "typedef struct packed { logic [7:0] v; } a_t;\n" + body)
pmod('vp27_mod_comb', "module top; a_t a; int ix[4]; int k; always_comb a.v[ix[k] +: 2] = 0; endmodule\n")
pmod('vp28_mod_assign', "module top; a_t a; localparam int ix[4] = '{0, 1, 2, 3}; assign a.v[ix[1] +: 2] = 2'b0; endmodule\n")
pmod('vp29_mod_depth2', "module sub; a_t a; int ix[4]; int k; always_comb a.v[ix[k] +: 2] = 0; endmodule\nmodule mid; sub u(); endmodule\nmodule top; mid m(); endmodule\n")
pmod('vp30_mod_gen', "module top; a_t a; int ix[4]; int k; if (1) begin : g always_comb a.v[ix[k] +: 2] = 0; end endmodule\n")
pmod('vp31_mod_genfor', "module top; a_t a [2]; int ix[4]; for (genvar g = 0; g < 2; g++) begin : gl always_comb a[g].v[ix[g] +: 2] = 0; end endmodule\n")
pmod('vp32_mod_param', "module top; localparam int P = 1; a_t a; int ix[4]; always_comb a.v[ix[P] +: 2] = 0; endmodule\n")
pmod('vp33_mod_fn', "module top; a_t a; int k; function automatic int g(int x); return x; endfunction always_comb a.v[g(k) +: 2] = 0; endmodule\n")
pmod('vp34_mod_rv', "module top; a_t a; int ix[4]; int k; logic [1:0] o; always_comb o = a.v[ix[k] +: 2]; endmodule\n")
pmod('vp35_mod_ff', "module top; a_t a; int ix[4]; int k; logic clk; always_ff @(posedge clk) a.v[ix[k] -: 2] <= 0; endmodule\n")
pmod('vp36_mod_task', "module top; a_t a; int ix[4]; task t(input int i); a.v[ix[i] +: 2] = 0; endtask endmodule\n")
pmod('vp37_mod_wire_rv', "module top; a_t a; logic [1:0] w [4]; wire [1:0] o; assign o = a.v[w[0] +: 2]; endmodule\n")
S = 'lvRootSelCallNameSpan312'
for n, b in [('vs01_sfn', 'iarr[sfn(i)].f = r;'), ('vs02_clsscope', 'iarr[item::sget()].f = r;'),
             ('vs03_pkgfn', 'iarr[p::f(i)].f = r;'), ('vs04_member2', 'iarr[fn(i)].g[j] = r;'),
             ('vs05_nested', 'iarr[fn(fn(i))].f = r;'), ('vs06_twocalls', 'iarr[fn(i) + fn(j)].f = r;'),
             ('vs07_2d', 'i2[fn(i)][j].f = r;'), ('vs08_postinc', 'iarr[fn(i)].f++;'), ('vs09_preinc', '++iarr[fn(i)].f;'),
             ('vs10_compound', 'iarr[fn(i)].f += r;'), ('vs11_ternfalse', 'iarr[c ? j : fn(i)].f = r;'),
             ('vs12_terntrue', 'iarr[c ? fn(i) : j].f = r;'), ('vs13_sys_ctl', 'iarr[$clog2(i)].f = r;'),
             ('vs14_this', 'this.iarr[fn(i)].f = r;'), ('vs15_fnsel_arg', 'iarr[fn(ia[i])].f = r;'),
             ('vs16_paren', 'iarr[(fn(i))].f = r;'), ('vs17_named', 'iarr[fn(.x(i))].f = r;'),
             ('vs18_cast', 'iarr[int\'(fn(i))].f = r;'), ('vs19_harr_root', 'harr[fn(i)].idx[j] = r;'),
             ('vs20_harr_trail', 'harr[j].idx[fn(i)] = r;')]:
    cls('VS', n, S, '    ' + b)
L = 'lateCallIdxNameSpan312'
for n, b in [('vl01_lv_root', 'iarr[fwd(i)].f = r;'), ('vl02_plain_ctl', 'r = ia[fwd(i)];'),
             ('vl03_trail', 'r = h.idx[fwd(i)];'), ('vl04_member_nontrail', 'r = h.arr[fwd(i)].f;'),
             ('vl05_root', 'r = iarr[fwd(i)].f;'), ('vl06_terntrue', 'r = iarr[c ? fwd(i) : j].f;'),
             ('vl07_lv_member', 'h.arr[fwd(i)].f = r;'), ('vl08_lv_both', 'iarr[fwd(i)].g[fwd(j)] = r;'),
             ('vl09_recv', 'r = iarr[fwd(i)].get();'), ('vl10_op', 'r = iarr[fwd(i) + 1].f;'),
             ('vl11_nested', 'r = iarr[fwd(fwd(i))].f;'), ('vl12_lv_trail', 'h.idx[fwd(i)] = r;'),
             ('vl13_incdec', 'iarr[fwd(i)].f++;'), ('vl14_ternfalse', 'r = iarr[c ? j : fwd(i)].f;'),
             ('vl15_lv_op', 'iarr[fwd(i) + 1].f = r;'), ('vl16_concat', '{iarr[fwd(i)].f, r} = 2;')]:
    cls('VL', n, L, '    ' + b)
MS = 'memberSelCallIdxParenSpan312'
for n, b in [('vn01_sfn', 'r = h.idx[sfn(i)];'), ('vn02_fn', 'r = h.idx[fn(i)];'), ('vn03_meth', 'r = h.idx[iarr[i].get()];'),
             ('vn04_sys', 'r = h.idx[$clog2(i)];'), ('vn05_lv', 'h.idx[fn(i)] = r;'), ('vn06_member_nt', 'r = h.arr[fn(i)].f;'),
             ('vn07_paren', 'r = h.idx[(fn(i))];'), ('vn08_space', 'r = h.idx[fn (i)];'), ('vn09_trailsp', 'r = h.idx[fn(i) ];'),
             ('vn10_pkgfn', 'r = h.idx[p::f(i)];'), ('vn11_methnoarg_meth', 'r = h.idx[iarr[i].nx.get()];'),
             ('vn12_strlen', 'r = h.idx[str.len()];'), ('vn13_deep', 'r = h.hh.idx[iarr[i].get()];'),
             ('vn14_lv_meth', 'h.idx[iarr[i].get()] = r;'), ('vn15_2d', 'r = h.idx2[fn(i)][j];'),
             ('vn16_2d_last', 'r = h.idx2[j][fn(i)];'), ('vn17_put', 'r = h.idx[iarr[i].put(j)];'),
             ('vn18_multiline', 'r = h.idx[fn(\n      i)];'), ('vn19_argcall', 'r = h.idx[fn(fn(i))];'),
             ('vn20_qsize', 'r = h.idx[h.q.size()];')]:
    cls('VN', n, MS, '    ' + b)
cls('VN', 'vn21_macro', MS, '    r = h.idx[`CALL];', pre='`define CALL fn(i)\n')
raw('VN', 'vn22_mod_packed', MS, PKG + """typedef struct packed { logic [3:0][7:0] idx; } ps_t;
module top; ps_t ps; int k; logic [7:0] o; function automatic int g(int x); return x; endfunction
  always_comb o = ps.idx[g(k)];
endmodule
""")
raw('VN', 'vn23_mod_packed_lv', MS, PKG + """typedef struct packed { logic [3:0][7:0] idx; } ps_t;
module top; ps_t ps; int k; function automatic int g(int x); return x; endfunction
  always_comb ps.idx[g(k)] = 0;
endmodule
""")
LS = 'lvMethPathInIdxNameSpan312'
for n, b in [('vq01_op', 'iarr[iarr[i].get() + 1].f = r;'), ('vq02_member_recv', 'iarr[h.arr[i].get()].f = r;'),
             ('vq03_2d', 'i2[iarr[i].get()][j].f = r;'), ('vq04_member2', 'iarr[iarr[i].get()].g[j] = r;'),
             ('vq05_postinc', 'iarr[iarr[i].get()].f++;'), ('vq06_deep_recv', 'iarr[iarr[i].nx.get()].f = r;'),
             ('vq07_strlen', 'iarr[sarr[i].len()].f = r;'), ('vq08_this', 'iarr[this.iarr[i].get()].f = r;'),
             ('vq09_terntrue', 'iarr[c ? iarr[i].get() : j].f = r;'), ('vq10_ternfalse', 'iarr[c ? j : iarr[i].get()].f = r;'),
             ('vq11_compound', 'iarr[iarr[i].get()].f += r;'), ('vq12_harr', 'harr[iarr[i].get()].idx[j] = r;'),
             ('vq13_put', 'iarr[iarr[i].put(j)].f = r;'), ('vq14_fnwrap', 'iarr[fn(iarr[i].get())].f = r;'),
             ('vq15_cast', 'iarr[int\'(iarr[i].get())].f = r;'), ('vq16_nba_ctl', 'iarr[i].f = iarr[iarr[i].get()].f;')]:
    cls('VQ', n, LS, '    ' + b)
for (g, n), t in cases.items():
    d = os.path.join(CASES, g, n); assert d.startswith('/'); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(t)
print(len(cases))
# ---- VX: module-scope hierarchical shapes (second round)
IFC = "interface ifc; logic [7:0] arr[4]; logic [7:0] v; modport mp(output arr); endinterface\n"
X = 'modTfLvTrailIdxNamesByChain312'
xs = {
 'vx01_iface_inst_task': (X, IFC + "module top; ifc u(); int r; task t(input int i); u.arr[i + 1] = r; endtask endmodule\n"),
 'vx02_iface_inst_proc_ctl': (X, IFC + "module top; ifc u(); int k; always_comb u.arr[k + 1] = 0; endmodule\n"),
 'vx03_iface_port_task': (X, IFC + "module sub(ifc p); task t(input int i); p.arr[i + 1] = 0; endtask endmodule\nmodule top; ifc u(); sub s(u); endmodule\n"),
 'vx04_hier_inst_task': (X, "module leaf; logic [7:0] arr[4]; endmodule\nmodule top; leaf l(); task t(input int i); l.arr[i + 1] = 0; endtask endmodule\n"),
 'vx05_modport_task': (X, IFC + "module sub(ifc.mp p); task t(input int i); p.arr[i + 1] = 0; endtask endmodule\nmodule top; ifc u(); sub s(u); endmodule\n"),
 'vx06_unpacked_struct': (X, "typedef struct { int idx[4]; } us_t;\nmodule top; us_t s; task t(input int i); s.idx[i + 1] = 0; endtask endmodule\n"),
 'vx07_packed_arr': (X, "typedef struct packed { logic [3:0][7:0] idx; } ps_t;\nmodule top; ps_t pa[2]; task t(input int i); pa[1].idx[i + 1] = 0; endtask endmodule\n"),
 'vx08_vif_task': (X, IFC + "module top; ifc u(); virtual ifc vif; task t(input int i); vif.arr[i + 1] = 0; endtask endmodule\n"),
 'vx09_named_blk': (X, HOLD + "module top; holder h; task t(input int i); begin : b int j; j = i; h.idx[j + 1] = 0; end endtask endmodule\n"),
 'vx10_forvar': (X, HOLD + "module top; holder h; function void f(); for (int j = 0; j < 2; j++) h.idx[j + 1] = 0; endfunction endmodule\n"),
 'vx11_foreach': (X, HOLD + "module top; holder h; int ia[4]; task t(); foreach (ia[j]) h.idx[j + 1] = 0; endtask endmodule\n"),
 'vx12_nested_mod': (X, HOLD + "module top; module inner; holder h; task t(input int i); h.idx[i + 1] = 0; endtask endmodule inner n(); endmodule\n"),
 'vx13_param_inst': (X, HOLD + "module sub #(int W = 1); holder h; task t(input int i); h.idx[i + W] = 0; endtask endmodule\nmodule top; sub #(2) a(); sub #(3) b(); endmodule\n"),
 'vx14_ps_modvar_ctl': (X, "typedef struct packed { logic [3:0][7:0] idx; } ps_t;\nmodule top; ps_t ps; int k; always_comb ps.idx[k + 1] = 0; endmodule\n"),
 'vx15_iface_task_own': (X, IFC.replace("endinterface", "task t(input int i); arr[i + 1] = 0; v[i +: 2] = 0; endtask endinterface") + "module top; ifc u(); endmodule\n"),
 'vx16_retval_struct': (X, "typedef struct packed { logic [3:0][7:0] idx; } ps_t;\nmodule top; function automatic ps_t f(input int i); ps_t q; q = 0; q.idx[i + 1] = 8'h1; return q; endfunction endmodule\n"),
 'vx17_rootcall_packedarr': ('lvRootSelCallNameSpan312', "typedef struct packed { logic [3:0][7:0] idx; } ps_t;\nmodule top; ps_t pa[4]; int k; function automatic int g(int x); return x; endfunction always_comb pa[g(k)].idx[0] = 0; endmodule\n"),
 'vx18_rootcall_genff': ('lvRootSelCallNameSpan312', "typedef struct packed { logic b; logic c; } m_t;\nmodule top; m_t m[4]; int k; logic clk; function automatic int g(int x); return x; endfunction if (1) begin : gb always_ff @(posedge clk) m[g(k)].b <= 0; end endmodule\n"),
 'vx19_rootcall_task': ('lvRootSelCallNameSpan312', "typedef struct packed { logic b; logic c; } m_t;\nmodule top; m_t m[4]; function automatic int g(int x); return x; endfunction task t(input int i); m[g(i)].b = 1; endtask endmodule\n"),
 'vx20_rootcall_iface': ('lvRootSelCallNameSpan312', "typedef struct packed { logic b; logic c; } m_t;\ninterface ifc2; m_t m[4]; int k; function automatic int g(int x); return x; endfunction always_comb m[g(k)].b = 0; endinterface\nmodule top; ifc2 u(); endmodule\n"),
 'vx21_rootcall_incdec': ('lvRootSelCallNameSpan312', "typedef struct packed { logic [3:0] b; logic c; } m_t;\nmodule top; m_t m[4]; int k; function automatic int g(int x); return x; endfunction initial m[g(k)].b++; endmodule\n"),
 'vx22_rootcall_depth3': ('lvRootSelCallNameSpan312', "typedef struct packed { logic b; logic c; } m_t;\nmodule c3; m_t m[4]; int k; function automatic int g(int x); return x; endfunction always_comb m[g(k)].b = 0; endmodule\nmodule c2; c3 u(); endmodule\nmodule top; c2 u(); endmodule\n"),
 'vx23_rootcall_implicit': ('lvRootSelCallNameSpan312', "typedef struct packed { logic b; logic c; } m_t;\nmodule top; m_t m[4]; function automatic int g(int x); return x; endfunction assign w = 1'b0; always_comb m[g(w)].b = 0; endmodule\n"),
 'vx24_rootcall_pkgfn': ('lvRootSelCallNameSpan312', PKG + "typedef struct packed { logic b; logic c; } m_t;\nmodule top; m_t m[4]; int k; always_comb m[p::f(k)].b = 0; endmodule\n"),
}
for n, (law, t) in xs.items():
    raw('VX', n, law, t)
for (g, n), t in cases.items():
    if g != 'VX': continue
    d = os.path.join(CASES, g, n); assert d.startswith('/'); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(t)
# ---- VF: functions declared BELOW their use in modules, interfaces and classes (§ lateCallIdxNameSpan312's branch)
LC = 'lateCallIdxNameSpan312'
MT = "typedef struct packed { logic b; logic c; } m_t;\n"
vf = {
 'vf01_mod_ca_root': MT + "module top; m_t m[4]; assign m[g(1)].b = 1'b0; function automatic int g(int x); return x; endfunction endmodule\n",
 'vf02_mod_comb_root': MT + "module top; m_t m[4]; int k; always_comb m[g(k)].b = 0; function automatic int g(int x); return x; endfunction endmodule\n",
 'vf03_mod_ca_rv': MT + "module top; m_t m[4]; wire o; assign o = m[g(1)].b; function automatic int g(int x); return x; endfunction endmodule\n",
 'vf04_mod_comb_rv': MT + "module top; m_t m[4]; int k; logic o; always_comb o = m[g(k)].b; function automatic int g(int x); return x; endfunction endmodule\n",
 'vf05_mod_ca_trail': "typedef struct packed { logic [3:0] v; } t_t;\nmodule top; t_t s; wire o; assign o = s.v[g(1)]; function automatic int g(int x); return x; endfunction endmodule\n",
 'vf06_mod_ff_root': MT + "module top; m_t m[4]; int k; logic clk; always_ff @(posedge clk) m[g(k)].b <= 0; function automatic int g(int x); return x; endfunction endmodule\n",
 'vf07_mod_gen_ca': MT + "module top; m_t m[4]; if (1) begin : gb assign m[g(2)].b = 1'b0; end function automatic int g(int x); return x; endfunction endmodule\n",
 'vf08_iface_comb': MT + "interface ifc2; m_t m[4]; int k; always_comb m[g(k)].b = 0; function automatic int g(int x); return x; endfunction endinterface\nmodule top; ifc2 u(); endmodule\n",
 'vf09_mod_task_root': MT + "module top; m_t m[4]; task t(input int i); m[g(i)].b = 1; endtask function automatic int g(int x); return x; endfunction endmodule\n",
 'vf10_mod_ca_op': MT + "module top; m_t m[4]; assign m[g(1) + 1].b = 1'b0; function automatic int g(int x); return x; endfunction endmodule\n",
 'vf12_mod_netdecl': MT + "module top; m_t m[4]; wire o = m[g(1)].c; function automatic int g(int x); return x; endfunction endmodule\n",
}
for n, t in vf.items():
    raw('VF', n, LC, t)
for n, b in [('vf13_cls_nba_ctl', 'iarr[fwd(i)].f <= r;'), ('vf14_cls_member_idx', 'iarr[j].g[fwd(i)] = r;'),
             ('vf15_cls_harr_both', 'harr[fwd(i)].arr[fwd(j)].f = r;'), ('vf16_cls_ips', 'h.v[fwd(i) +: 2] = 0;'),
             ('vf17_cls_rv_ips', 'r = h.v[fwd(i) +: 2];'), ('vf18_cls_lv_twocalls', 'iarr[fwd(i) + fn(j)].f = r;')]:
    cls('VF', n, LC, '    ' + b)
for n, b in [('vp38_lvbase', 'h.v[lv[i] +: 2] = 0;'), ('vp39_strbase', 'h.v[str[i] +: 2] = 0;'), ('vp40_earrbase', 'h.v[earr[i] +: 2] = 0;'),
             ('vp41_psbase_ctl', 'h.v[lv[3:0] +: 2] = 0;'), ('vp42_fnfn', 'h.v[fn(fn(i)) +: 2] = 0;'), ('vp43_fn_noarg_path', 'h.v[h.hh.idx[i] +: 2] = 0;')]:
    cls('VP2', n, 'ipsBaseSelCallRender312', '    ' + b)
for (g, n), t in cases.items():
    if g not in ('VF', 'VP2'): continue
    d = os.path.join(CASES, g, n); assert d.startswith('/'); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(t)
