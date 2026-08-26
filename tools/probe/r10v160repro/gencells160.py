#!/usr/bin/env python3
"""r10v160repro/gencells160.py — one .sv per CELL.

The judge names only the FIRST differing object, so a multi-cell arm hides
every cell behind its head.  Each cell here is its own database: the pristine
and the patched binary are judged against the SAME golden independently, so
"pristine right -> patched wrong" is decidable cell by cell.
MEASUREMENT ONLY; LHS is always golden."""
import os, sys

OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)

# (name, extra package-level decls, class header, class body)
CELLS = []
def C(name, body, hdr='#(type T=int)', pre='', post='', top='  initial $display("hi");'):
    CELLS.append((name, pre, hdr, body, post, top))

B = 'string s = "";'
# ---- literal shapes -------------------------------------------------
C('l01_escquote',  'function void m(); T t; s = {"a\\"b", t.gt()}; endfunction')
C('l02_escnl',     'function void m(); T t; s = {"a\\nb", t.gt()}; endfunction')
C('l03_escbs',     'function void m(); T t; s = {"a\\\\b", t.gt()}; endfunction')
C('l04_empty',     'function void m(); T t; s = {"", t.gt()}; endfunction')
C('l05_colons',    'function void m(); T t; s = {"p::q.r", t.gt()}; endfunction')
C('l06_esctab',    'function void m(); T t; s = {"a\\tb", t.gt()}; endfunction')
C('l07_space',     'function void m(); T t; s = {"a b ", t.gt()}; endfunction')
C('l08_pct',       'function void m(); T t; s = {"%0d %s", t.gt()}; endfunction')
# accepted twins (oracles) -------------------------------------------
C('k01_escquote',  'string p; function void m(); s = {"a\\"b", p}; endfunction')
C('k02_escnl',     'string p; function void m(); s = {"a\\nb", p}; endfunction')
C('k03_escbs',     'string p; function void m(); s = {"a\\\\b", p}; endfunction')
C('k04_empty',     'string p; function void m(); s = {"", p}; endfunction')
C('k06_esctab',    'string p; function void m(); s = {"a\\tb", p}; endfunction')
# ---- identifier operand homes ---------------------------------------
C('i01_formal',    'function void m(string a); T t; s = {a, t.gt()}; endfunction')
C('i02_local',     'function void m(); T t; string lv="v"; s = {lv, t.gt()}; endfunction')
C('i03_prop',      'string p; function void m(); T t; s = {p, t.gt()}; endfunction')
C('i04_static',    'static string sp = "z"; function void m(); T t; s = {sp, t.gt()}; endfunction')
C('i05_lparam',    'localparam string LP="lp"; function void m(); T t; s = {LP, t.gt()}; endfunction')
C('i06_typeparam', 'function void m(); T t; s = {FLD, t.gt()}; endfunction', hdr='#(type T=int, string FLD="f")')
C('i07_pkgparam',  'function void m(); T t; s = {PKGP160, t.gt()}; endfunction',
  pre='  parameter string PKGP160 = "pp";')
C('i08_inherited', 'function void m(); T t; s = {ipro, t.gt()}; endfunction')
# ---- scoped operand --------------------------------------------------
C('c01_scopedname','function void m(); T t; s = {"[", T::tn, "]", t.gt()}; endfunction')
C('c02_scopedcall','function void m(); T t; s = {"[", T::mk(), "]", t.gt()}; endfunction')
C('c03_scoped3',   'function void m(); T t; s = {"[", T::inr::tn, "]", t.gt()}; endfunction')
C('c04_scopedarg', 'function void m(); T t; s = {"[", T::mk("z"), "]", t.gt()}; endfunction')
C('c05_pkgscope',  'function void m(); T t; s = {"[", pvx160::VX, "]", t.gt()}; endfunction')
# ---- dotted operand --------------------------------------------------
C('d01_dotcall',   'basev160 bh; function void m(); T t; s = {"[", bh.gn(), "]", t.gt()}; endfunction')
C('d02_dotname',   'basev160 bh; function void m(); T t; s = {"[", bh.pn, "]", t.gt()}; endfunction')
C('d03_dotcallarg','basev160 bh; string p; function void m(); T t; s = {"[", bh.gn(p), "]", t.gt()}; endfunction')
C('d04_dotcalldot','basev160 bh; function void m(); T t; s = {"[", bh.gn(bh.pn), "]", t.gt()}; endfunction')
C('d05_dot3',      'basev160 bh; function void m(); T t; s = {"[", bh.bb.pn, "]", t.gt()}; endfunction')
C('d06_dot3call',  'basev160 bh; function void m(); T t; s = {"[", bh.bb.gn(), "]", t.gt()}; endfunction')
# ---- shapes OUTSIDE the five (must stay pristine) ---------------------
C('o01_intlit',    'function void m(); T t; s = {8\'d5, t.gt()}; endfunction')
C('o02_select',    'string p; function void m(); T t; s = {"[", p[0], "]", t.gt()}; endfunction')
C('o03_sysfunc',   'int iv; function void m(); T t; s = {$sformatf("%0d", iv), t.gt()}; endfunction')
C('o04_paren',     'string p; function void m(); T t; s = {(p), t.gt()}; endfunction')
C('o05_ternary',   'string p; function void m(); T t; s = {(p=="")?"a":"b", t.gt()}; endfunction')
C('o06_nestcat',   'function void m(); T t; s = {{"x","y"}, t.gt()}; endfunction')
C('o07_barecall',  'function string q(); return "q"; endfunction\n    function void m(); T t; s = {q(), t.gt()}; endfunction')
C('o08_repl',      'function void m(); T t; s = {{2{"x"}}, t.gt()}; endfunction')
C('o09_cast',      'function void m(); T t; s = {string\'("x"), t.gt()}; endfunction')
C('o10_binary',    'string p; function void m(); T t; s = {{p, "y"}, t.gt()}; endfunction')
# ---- all five at once -------------------------------------------------
C('f01_allfive',   'basev160 bh; function void m(); T t; s = {"lit", FLD, bh.pn, bh.gn(), T::tn, t.gt()}; endfunction',
  hdr='#(type T=int, string FLD="f")')
# ---- bad-operand faces ------------------------------------------------
C('x01_membersel', 'function void m(); T t; s = {"[", t.fld, "]"}; endfunction')
C('x02_scopedcall','function void m(); s = {"[", T::mk(), "]"}; endfunction')
C('x03_badarg',    'basev160 bh; function void m(); T t; s = {"[", bh.gn(t.gt()), "]"}; endfunction')
C('x04_nested',    'basev160 bh; function void m(); T t; s = {"[", bh.gn({"<", t.gt(), ">"}), "]"}; endfunction')
C('x05_onlybad',   'function void m(); T t; s = {t.gt()}; endfunction')
C('x06_firstbad',  'function void m(); T t; s = {t.gt(), "b"}; endfunction')
C('x07_twobad',    'function void m(); T t; s = {"a", t.gt(), "b", t.g2()}; endfunction')
C('x08_str',       'function void m(); T t; s = {"[", t.gt(), "]"}; endfunction', hdr='#(type T=string)')
C('x09_struct',    'function void m(); T t; s = {"[", t.gt(), "]"}; endfunction', hdr='#(type T=stv160)',
  pre='  typedef struct packed { int a; int b; } stv160;')
C('x10_enum',      'function void m(); T t; s = {"[", t.gt(), "]"}; endfunction', hdr='#(type T=env160)',
  pre='  typedef enum { EV0, EV1 } env160;')
C('x11_class',     'function void m(); T t; s = {"[", t.gt(), "]"}; endfunction', hdr='#(type T=basev160)')
C('x12_bit',       'function void m(); T t; s = {"[", t.gt(), "]"}; endfunction', hdr='#(type T=bit)')
C('x13_real',      'function void m(); T t; s = {"[", t.gt(), "]"}; endfunction', hdr='#(type T=real)')
C('x14_selbadty',  'function void m(); T t; s = {"[", t.fld.sub, "]"}; endfunction', hdr='#(type T=byte)')
# ---- the concatenation's own context ----------------------------------
C('y01_init',      'function void m(); T t; string lv = {"[", t.gt(), "]"}; s = lv; endfunction')
C('y02_return',    'function string m(); T t; return {"[", t.gt(), "]"}; endfunction')
C('y03_arg',       'function string q(string a); return a; endfunction\n    function void m(); T t; s = q({"[", t.gt(), "]"}); endfunction')
C('y04_sysarg',    'function void m(); T t; $display("%s", {"[", t.gt(), "]"}); endfunction')
C('y05_ternarm',   'int iv; function void m(); T t; s = (iv==0) ? {"[", t.gt(), "]"} : "z"; endfunction')
C('y06_cond',      'function void m(); T t; if ({"[", t.gt(), "]"} != "") s = "y"; endfunction')
C('y07_caseexpr',  'function void m(); T t; case ({"[", t.gt(), "]"}) "a": s="1"; default: s="2"; endcase endfunction')
C('y08_caseitem',  'string p; function void m(); T t; case (p) {"[", t.gt(), "]"}: s="1"; default: s="2"; endcase endfunction')
C('y09_lvalue',    'bit [7:0] v1, v2; function void m(); T t; {v1, v2} = 16\'h55aa; s = {"[", t.gt(), "]"}; endfunction')
C('y10_nestgood',  'function void m(); T t; s = {"<", {"[", t.gt(), "]"}, ">"}; endfunction')
C('y11_cast',      'function void m(); T t; s = string\'({"[", t.gt(), "]"}); endfunction')
C('y12_binary',    'function void m(); T t; if ({"[", t.gt(), "]"} == "q") s = "y"; endfunction')
C('y13_foreach',   'int qa[3]; function void m(); T t; foreach (qa[i]) s = {"[", t.gt(), "]"}; endfunction')
C('y14_fork',      'task m(); T t; fork s = {"[", t.gt(), "]"}; join_none endtask')
C('y15_propinit',  'static T tp; static string sp = {"[", tp.gt(), "]"};')
C('y16_two',       'function void m(); T t; s = {"a", t.gt()}; s = {"b", t.gt()}; endfunction')
# ---- homes -------------------------------------------------------------
C('h01_task',      'task m(); T t; s = {"[", t.gt(), "]"}; endtask')
C('h02_static',    'static function void m(); T t; s = {"[", t.gt(), "]"}; endfunction')
C('h03_twoparam',  'function void m(); T t; V v; s = {"[", t.gt(), v.g2(), "]"}; endfunction', hdr='#(type T=int, type V=int)')
C('h04_classspec', 'function void m(); T t; s = {"[", t.gt(), "]"}; endfunction',
  post='  typedef hold160#(basev160) spec160;')
C('h05_twospec',   'function void m(); T t; s = {"[", t.gt(), "]"}; endfunction',
  post='  typedef hold160#(basev160) sa160;\n  typedef hold160#(string) sb160;')
C('h06_inst',      'function void m(); T t; s = {"[", t.gt(), "]"}; endfunction',
  post='  typedef hold160#(basev160) spec160;',
  top='  pv160::spec160 h1;\n  initial $display("hi");')
C('h07_inst3',     'function void m(); T t; s = {"[", t.gt(), "]"}; endfunction',
  post='  typedef hold160#(basev160) spec160;',
  top='  pv160::spec160 h1, h2, h3;\n  initial $display("hi");')

TPL = '''// r10v160 cell {name} — MEASUREMENT ONLY, generated by gencells160.py.
package pvx160;
  parameter string VX = "vx";
endpackage
package pv160;
  import pvx160::*;
{pre}
  class basev160;
    string pn;
    basev160 bb;
    function new(string name="x"); endfunction
    function string gn(string a="q"); return a; endfunction
  endclass
  class midv160 extends basev160;
    string ipro;
  endclass
  class hold160 {hdr} extends midv160;
    {B}
    {body}
  endclass
{post}
endpackage

module topv160;
{top}
endmodule
'''
n = 0
for (name, pre, hdr, body, post, top) in CELLS:
    open(os.path.join(OUT, name + '.sv'), 'w').write(
        TPL.format(name=name, pre=pre, hdr=hdr, B=B, body=body, post=post, top=top))
    n += 1
print("cells", n)
