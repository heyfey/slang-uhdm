#!/usr/bin/env python3
"""mkgrid.py: writes the r11u234 grid cases under cases/G<law>/<case>/ (dut.sv, or an `args` file with several
roots / an included file). Every dut.sv starts with a `// §` line naming the law and the shape. Idempotent."""
import os, sys
if len(os.environ.get("FENCED", "").split()) != 4: sys.exit("mkgrid.py: source drivers/env.sh first (FENCED)")
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cases')
C = {}
def c(path, text, extra=None, crlf=False):
    C[path] = (text, extra or {}, crlf)

E1 = "tpTdDefaultUseSharesListing234 + tpTdFormalWritesTypedef234"
# ---- law E ------------------------------------------------------------------------------------------------
c('GE/ge01_import', f"""// § {E1}: the typedef in another package imported by the class's package
package q;
  typedef enum bit {{ A=0, B=1 }} e_t;
endpackage
package p;
  import q::*;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
    static function void g(); T l = l.first(); l = l.next(); endfunction
  endclass
endpackage
""")
c('GE/ge02_unit', f"""// § {E1}: a $unit typedef and a $unit class (not a package: both laws decline)
typedef enum bit {{ A=0, B=1 }} e_t;
class W #(type T=e_t);
  static T m;
  function void f(T a); endfunction
endclass
module top; endmodule
""")
c('GE/ge03_nested', f"""// § {E1}: the parameterized class nested in another package class
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  class O;
    class W #(type T=e_t);
      static T m;
      function void f(T a); endfunction
    endclass
  endclass
endpackage
""")
c('GE/ge04_virt_static', f"""// § {E1}: a virtual method, a static method and a task, each with a formal written T
package p;
  typedef enum bit [1:0] {{ A=0, B=1, C=2 }} e_t;
  class W #(type T=e_t);
    T m;
    virtual function void v(T a); endfunction
    static function void s(input T b); endfunction
    task t(output T c); c = A; endtask
  endclass
endpackage
""")
c('GE/ge05_tdtd', f"""// § {E1}: a default naming a typedef of a typedef (typedef e_t e2_t)
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  typedef e_t e2_t;
  class W #(type T=e2_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
""")
c('GE/ge06_fwd', f"""// § {E1}: a forward typedef of the enum before the class, defined after it
package p;
  typedef e_t;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
  endclass
  typedef enum bit {{ A=0, B=1 }} e_t;
endpackage
""")
c('GE/ge07_dims', f"""// § {E1}: properties written T with every container: fixed, queue, dynamic, associative, packed
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  class W #(type T=e_t);
    T fx[4];
    T qu[$];
    T dy[];
    T as[int];
    T [1:0] pk;
    function void f(T a); endfunction
  endclass
endpackage
""")
c('GE/ge08_twofiles', f"""// § {E1}: two files, the typedef's package in a.sv, the class in b.sv importing it
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
""", {'b.sv': """// § tpTdDefaultUseSharesListing234: the second file (a class of another package writing p::W's shapes)
package r;
  import p::*;
  class V #(type T=e_t);
    T m;
    function void g(T b); endfunction
  endclass
endpackage
""", 'args': 'dut.sv b.sv\n'})
c('GE/ge09_include', f"""// § {E1}: the class's methods in an included file
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  class W #(type T=e_t);
    static T m;
`include "w_methods.svh"
    function void h(T z); endfunction
  endclass
endpackage
""", {'w_methods.svh': """    function void f(T a); endfunction
    static function void g(); T l = l.first(); l = l.next(); endfunction
"""})
c('GE/ge10_macro', f"""// § {E1}: a method written by a macro, its formal written T
`define MK_SET(NM) function void NM(T v); endfunction
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
    `MK_SET(set_it)
  endclass
endpackage
""")
c('GE/ge11_crlf', f"""// § {E1}: e01 with CRLF line endings
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  class W #(type T=e_t);
    protected static T map[string];
    static function bit from_name(string name, ref T value);
      if (map.exists(name)) begin
        value = map[name];
        return 1;
      end
      return 0;
    endfunction
    protected static function void m_init_map();
      T e = e.first();
      map[e.name()] = e;
    endfunction
  endclass
endpackage
""", crlf=True)
c('GE/ge12_union', f"""// § {E1}: a packed union typedef default
package p;
  typedef union packed {{ bit [1:0] a; bit [1:0] b; }} u_t;
  class W #(type T=u_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
""")
c('GE/ge13_spec_module', f"""// § {E1}: specializations with the default's typedef and another typedef, used from a module
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  typedef enum bit [1:0] {{ X=0, Y=1, Z=2 }} f_t;
  class W #(type T=e_t);
    static T m;
    function void f(T a); endfunction
  endclass
endpackage
module top;
  import p::*;
  W #(e_t) w1;
  W #(f_t) w2;
  W w3;
endmodule
""")
c('GE/ge14_modclass', f"""// § {E1}: the class declared in a module, the typedef in a package
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
endpackage
module top;
  import p::*;
  class W #(type T=e_t);
    T m;
    function void f(T a); endfunction
  endclass
  W w;
endmodule
""")
c('GE/ge15_blocklocal', f"""// § {E1}: locals written T in a nested begin block and in a task
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  class W #(type T=e_t);
    function void f(T a);
      begin
        T b = a;
        b = b.next();
      end
    endfunction
    task t();
      T c = c.first();
      c = c.last();
    endtask
  endclass
endpackage
""")
c('GE/ge16_struct_unpacked', f"""// § {E1}: an unpacked struct typedef default with a property, a local and a formal
package p;
  typedef struct {{ int a; bit b; }} s_t;
  class W #(type T=s_t);
    T m;
    function void f(T a); T l; l = a; endfunction
  endclass
endpackage
""")
c('GE/ge17_twoparams', f"""// § {E1}: two independent type parameters with two enum defaults
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  typedef enum bit [1:0] {{ X=0, Y=1 }} f_t;
  class W #(type T=e_t, type U=f_t);
    static T m;
    static U n;
    function void f(T a, U b); endfunction
  endclass
endpackage
""")
c('GE/ge18_oob_local', f"""// § {E1}: an out-of-body definition's local written T (the fence: not claimed)
package p;
  typedef enum bit {{ A=0, B=1 }} e_t;
  class W #(type T=e_t);
    static T m;
    extern function void f(T a);
  endclass
  function void W::f(T a);
    T l;
    l = a;
  endfunction
endpackage
""")
# ---- law R ------------------------------------------------------------------------------------------------
R = "tpGroupOneSpan234"
c('GR/gr01_include', f"""// § {R}: the group's formals in an included file and after it
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
`include "base_protos.svh"
    extern function void push_req(REQ x);
  endclass
  function void base::push_req(REQ x); endfunction
  function void base::push_rsp(RSP x); endfunction
endpackage
""", {'base_protos.svh': """    extern function void push_rsp(RSP x);
"""})
c('GR/gr02_macro', f"""// § {R}: the last formal written by a macro expansion
`define MK_PUT(NM, TY) function void NM(TY v); endfunction
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    `MK_PUT(put_rsp, RSP)
  endclass
endpackage
""")
c('GR/gr03_nested', f"""// § {R}: a nested class's formal written with an outer parameter name is not a writer
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    class inner;
      function void g(int x); endfunction
    endclass
  endclass
endpackage
""")
c('GR/gr04_chain3', f"""// § {R}: a three-parameter chain with a typedef of the last
package p;
  class item; endclass
  class base #(type A = item, type B = A, type C = B);
    typedef C c_type;
    A a_buf[$];
    C c_one;
    function void pa(A x); endfunction
    function void pc(C y); endfunction
  endclass
endpackage
""")
c('GR/gr05_qualdefault', f"""// § {R}: a package-qualified default (type REQ = q::item)
package q;
  class item; endclass
endpackage
package p;
  class base #(type REQ = q::item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    function void push_rsp(RSP x); endfunction
  endclass
endpackage
""")
c('GR/gr06_virt', f"""// § {R}: a virtual class with a pure virtual prototype, a static method and a task writing the group
package p;
  class item; endclass
  virtual class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_one;
    static function void s(REQ x); endfunction
    task t(input RSP y); endtask
    pure virtual function void pv(RSP z);
  endclass
endpackage
""")
c('GR/gr07_sites', f"""// § {R}: every holder: fixed / dynamic / associative properties, a method local, a nested-block local, a return value
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ fx[2];
    RSP dy[];
    REQ as[string];
    function RSP last_rsp(); RSP l; begin REQ n; n = null; end return l; endfunction
    function void push_req(REQ x); endfunction
  endclass
endpackage
""")
c('GR/gr08_spec', f"""// § {R}: the generic class beside two specializations used by a package variable
package p;
  class item; endclass
  class item2 extends item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    function void push_rsp(RSP x); endfunction
  endclass
  base #(item2) b1;
  base #(item, item2) b2;
endpackage
""")
c('GR/gr09_unit', f"""// § {R}: a $unit class group
class item; endclass
class base #(type REQ = item, type RSP = REQ);
  typedef REQ req_type;
  typedef RSP rsp_type;
  REQ m_req_buf[$];
  function void push_rsp(RSP x); endfunction
  function void push_req(REQ x); endfunction
endclass
module top; endmodule
""")
c('GR/gr10_crlf', f"""// § {R}: r01 with CRLF line endings
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    RSP m_rsp_buf[$];
    extern function void push_rsp(RSP x);
    extern function void push_req(REQ x);
  endclass
  function void base::push_rsp(RSP x); endfunction
  function void base::push_req(REQ x); endfunction
endpackage
""", crlf=True)
c('GR/gr11_twofiles', f"""// § {R}: two files, the item class in a.sv's package, the group class in b.sv
package q;
  class item; endclass
endpackage
""", {'b.sv': """// § tpGroupOneSpan234: the second file
package p;
  import q::*;
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    function void push_rsp(RSP x); endfunction
  endclass
endpackage
""", 'args': 'dut.sv b.sv\n'})
c('GR/gr12_tdformal', f"""// § {R}: only typedef-spelled formals (not writers): the header default's token
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(req_type x); endfunction
    function void push_rsp(rsp_type y); endfunction
  endclass
endpackage
""")
c('GR/gr13_dimformal', f"""// § {R}: the last formal written with dimensions (REQ x[])
package p;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_rsp(RSP x); endfunction
    function void push_reqs(REQ xs[]); endfunction
  endclass
endpackage
""")
c('GR/gr14_modclass', f"""// § {R}: the group class declared in a module
module top;
  class item; endclass
  class base #(type REQ = item, type RSP = REQ);
    typedef REQ req_type;
    typedef RSP rsp_type;
    REQ m_req_buf[$];
    function void push_req(REQ x); endfunction
    function void push_rsp(RSP x); endfunction
  endclass
  base b;
endmodule
""")
# ---- law F ------------------------------------------------------------------------------------------------
F = "retNameLocalClassTsAtType234"
c('GF/gf01_spec', f"""// § {F}: an out-of-body method returning a specialization, its name assigned in the body
package p;
  class vis #(type N = int); endclass
  class cs;
    extern function vis#(int) get_v();
  endclass
  function vis#(int) cs::get_v();
    get_v = null;
  endfunction
endpackage
""")
c('GF/gf02_qual', f"""// § {F}: a package function returning a class of another package, written q::rgn
package q;
  class rgn; endclass
endpackage
package p;
  function q::rgn mk(int n);
    mk = null;
    if (n == 0) return mk;
  endfunction
endpackage
""")
c('GF/gf03_static', f"""// § {F}: an out-of-body STATIC method
package p;
  class rgn; endclass
  class mam;
    extern static function rgn get_one();
  endclass
  function rgn mam::get_one();
    get_one = null;
  endfunction
endpackage
""")
c('GF/gf04_unit', f"""// § {F}: a $unit function returning a $unit class
class rgn; endclass
function rgn mk_unit(int n);
  mk_unit = null;
endfunction
module top; endmodule
""")
c('GF/gf05_td', f"""// § {F}: the return written with a package typedef of the class (typedef rgn h_t)
package p;
  class rgn; endclass
  typedef rgn h_t;
  function h_t mk(int n);
    mk = null;
  endfunction
endpackage
""")
c('GF/gf06_crlf_incl', f"""// § {F}: f01 with CRLF endings, the out-of-body body in an included file
package p;
  class region; endclass
  class mam;
    extern function region reserve_region(int n);
  endclass
`include "mam_body.svh"
endpackage
""", {'mam_body.svh': """  function region mam::reserve_region(int n);
    reserve_region = null;
    if (n == 0) return reserve_region;
  endfunction
"""}, crlf=True)
c('GF/gf07_module', f"""// § {F}: a module function returning a module class
module top;
  class rgn; endclass
  function rgn mk(int n);
    mk = null;
  endfunction
endmodule
""")
# ---- law V ------------------------------------------------------------------------------------------------
V = "pureVirtRetSpecWholeSpan234"
c('GV/gv01_qualspec', f"""// § {V}: a pure virtual returning a package-qualified specialization
package q;
  virtual class vis #(type N = int); endclass
endpackage
package p;
  class comp; endclass
  virtual class cs;
    pure virtual function q::vis#(comp) get_v();
  endclass
endpackage
""")
c('GV/gv02_valparam', f"""// § {V}: a pure virtual returning a value-parameter specialization vis#(4)
package p;
  virtual class vis #(int N = 1); endclass
  virtual class cs;
    pure virtual function vis#(4) get_v();
  endclass
endpackage
""")
c('GV/gv03_unit', f"""// § {V}: $unit classes
class comp; endclass
virtual class vis #(type N = int); endclass
virtual class cs;
  pure virtual function vis#(comp) get_v();
endclass
module top; endmodule
""")
c('GV/gv04_module', f"""// § {V}: the classes declared in a module
module top;
  class comp; endclass
  virtual class vis #(type N = int); endclass
  virtual class cs;
    pure virtual function vis#(comp) get_v();
  endclass
endmodule
""")
c('GV/gv05_tp', f"""// § {V}: a pure virtual returning the class's own type parameter
package p;
  class comp; endclass
  virtual class cs #(type T = comp);
    pure virtual function T get_t();
  endclass
endpackage
""")
c('GV/gv06_plain', f"""// § {V}: a pure virtual returning a plain class and one returning a two-argument specialization
package p;
  class comp; endclass
  virtual class vis #(type N = int, type M = int); endclass
  virtual class cs;
    pure virtual function comp get_c();
    pure virtual function vis#(comp, int) get_v2();
  endclass
endpackage
""")
# ---- law U ------------------------------------------------------------------------------------------------
U = "clsScopeFormalQualSpan234"
c('GU/gu01_constref', f"""// § {U}: `const ref cls::t` (a direction: the whole name)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    function void f(const ref types::rsrc_q_t rq);
    endfunction
  endclass
endpackage
""")
c('GU/gu02_pkgcls', f"""// § {U}: a package-and-class qualified formal type (p::types::rsrc_q_t)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
endpackage
package r;
  class pool;
    function void f(p::types::rsrc_q_t rq);
    endfunction
  endclass
endpackage
""")
c('GU/gu03_default', f"""// § {U}: a task formal with no direction and a default beside it
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    task t(types::rsrc_q_t rq, int k = 3);
    endtask
  endclass
endpackage
""")
c('GU/gu04_spacing', f"""// § {U}: blanks around the scope operator (types :: rsrc_q_t)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    function void f(types :: rsrc_q_t rq);
    endfunction
  endclass
endpackage
""")
c('GU/gu05_extern', f"""// § {U}: an extern prototype and its out-of-body definition
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    extern function void f(types::rsrc_q_t rq);
  endclass
  function void pool::f(types::rsrc_q_t rq);
  endfunction
endpackage
""")
c('GU/gu06_output', f"""// § {U}: an output formal (a direction keyword)
package p;
  class rsrc; endclass
  class types;
    typedef rsrc rsrc_q_t[$];
  endclass
  class pool;
    function void f(output types::rsrc_q_t rq);
    endfunction
  endclass
endpackage
""")
# ---- law Q ------------------------------------------------------------------------------------------------
Q = "clsTdClassElemRetSharesListing234"
c('GQ/gq01_tdtd', f"""// § {Q}: the element written with a class typedef (typedef el e2_t; typedef e2_t q_t[$])
package p;
  class el; endclass
  class cont;
    typedef el e2_t;
    typedef e2_t q_t[$];
    el m[$];
    virtual function q_t get(); return m; endfunction
  endclass
endpackage
""")
c('GQ/gq02_spec', f"""// § {Q}: a specialization element (typedef box#(int) q_t[$])
package p;
  class box #(type T = int); endclass
  class cont;
    typedef box#(int) q_t[$];
    box#(int) m[$];
    virtual function q_t get(); return m; endfunction
  endclass
endpackage
""")
c('GQ/gq03_oob', f"""// § {Q}: an extern prototype with an out-of-body definition returning cont::q_t
package p;
  class el; endclass
  class cont;
    typedef el q_t[$];
    el m[$];
    extern function q_t get();
  endclass
  function cont::q_t cont::get(); return m; endfunction
endpackage
""")
c('GQ/gq04_static', f"""// § {Q}: a static method
package p;
  class el; endclass
  class cont;
    typedef el q_t[$];
    static el m[$];
    static function q_t get(); return m; endfunction
  endclass
endpackage
""")
c('GQ/gq05_qualelem', f"""// § {Q}: a package-qualified element (typedef q::el q_t[$])
package q;
  class el; endclass
endpackage
package p;
  class cont;
    typedef q::el q_t[$];
    q::el m[$];
    virtual function q_t get(); return m; endfunction
  endclass
endpackage
""")
c('GQ/gq06_tpelem', f"""// § {Q}: an element written as the class's own type parameter (the twin kept)
package p;
  class el; endclass
  class cont #(type T = el);
    typedef T q_t[$];
    T m[$];
    virtual function q_t get(); return m; endfunction
  endclass
endpackage
""")

for path, (text, extra, crlf) in C.items():
    d = os.path.join(D, path)
    os.makedirs(d, exist_ok=True)
    def w(fn, t):
        if crlf and fn != 'args':
            t = t.replace('\n', '\r\n')
        with open(os.path.join(d, fn), 'w', newline='') as f:
            f.write(t)
    w('dut.sv', text)
    for fn, t in extra.items():
        w(fn, t)
print(len(C), 'grid cases')
