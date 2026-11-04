import os
R='/tmp/wt_v11u482/tools/probe/v11u482repro/cases'
def imp1(fcall='f(1)'):
    return f"""package a;
  import u::*;
  function int g(); return {fcall}; endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
"""
def imp2():
    return """package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
package b;
  import u::*;
  function int h(); return f(2); endfunction
endpackage
package c;
  import u::*;
  function int k(); return f(3); endfunction
endpackage
module top;
  import a::*;
  import b::*;
  import c::*;
  int x;
  initial x = g() + h() + k();
endmodule
"""
C={}
L1='cloneFixArrAggElemShared482'; L2='cloneArrElemAggOwnCopy482'; L3='cloneOwnCopyInstHomeTop482'
L4='cloneTfVarParentAtTf482'; L5='cloneHierIdxChainActual482'; L6='cloneHierMemberChain482'
ST='  typedef struct { int k; int data; } op_t;\n'
def fn(body, ret='int', args='int n', kw='function'):
    end = 'endfunction' if kw=='function' else 'endtask'
    hdr = f"  function {ret} f({args});\n" if kw=='function' else f"  task automatic t({args});\n"
    return hdr + body + f"  {end}\n"
# VF: law 1
C['VF/vf01']=(L1,'three importing packages', 'package u;\n'+ST+fn("    op_t acc[2];\n    acc[0].k = n;\n    return acc[1].data;\n")+'endpackage\n'+imp2())
C['VF/vf02']=(L1,'alias of the struct in the home package', 'package u;\n'+ST+'  typedef op_t op2_t;\n'+fn("    op2_t acc[2];\n    acc[0].k = n;\n    return acc[1].data;\n")+'endpackage\n'+imp1())
C['VF/vf03']=(L1,'home alias of a struct from a third package s', 'package s;\n'+ST+'endpackage\npackage u;\n  import s::*;\n  typedef s::op_t op_t2;\n'+fn("    op_t2 acc[2];\n    acc[0].k = n;\n    return acc[1].data;\n")+'endpackage\n'+imp1())
C['VF/vf04']=(L1,'typedef declared inside the function', 'package u;\n'+fn("    typedef struct { int k; int data; } lop_t;\n    lop_t acc[2];\n    acc[0].k = n;\n    return acc[1].data;\n")+'endpackage\n'+imp1())
C['VF/vf05']=(L1,'parameter-sized array', 'package u;\n  parameter N = 3;\n'+ST+fn("    op_t acc[N];\n    acc[0].k = n;\n    return acc[N-1].data;\n")+'endpackage\n'+imp1())
C['VF/vf06']=(L1,'array with an initializer', 'package u;\n'+ST+fn("    op_t acc[2] = '{default: '{k: 0, data: 5}};\n    acc[0].k = n;\n    return acc[1].data;\n")+'endpackage\n'+imp1())
C['VF/vf07']=(L1,'array declared in a nested begin', 'package u;\n'+ST+fn("    int r;\n    begin\n      op_t acc[2];\n      acc[0].k = n;\n      r = acc[1].data;\n    end\n    return r;\n")+'endpackage\n'+imp1())
C['VF/vf08']=(L1,'struct also used as a module variable type', 'package u;\n'+ST+fn("    op_t acc[2];\n    acc[0].k = n;\n    return acc[1].data;\n")+'endpackage\n'+"""package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  u::op_t mv;
  int x;
  initial begin x = g(); mv.k = x; end
endmodule
""")
C['VF/vf09']=(L1,'struct also used as a package variable in the importer', 'package u;\n'+ST+fn("    op_t acc[2];\n    acc[0].k = n;\n    return acc[1].data;\n")+'endpackage\n'+"""package a;
  import u::*;
  op_t pv;
  function int g(); pv.k = 1; return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
""")
C['VF/vf10']=(L1,'packed struct with a named enum member', 'package u;\n  typedef enum logic [1:0] {A, B, C} e_t;\n  typedef struct packed { e_t e; logic [5:0] d; } op_t;\n'+fn("    op_t acc[2];\n    acc[0].e = B;\n    return acc[1].d + n;\n")+'endpackage\n'+imp1())
C['VF/vf11']=(L1,'task local, two importers', 'package u;\n'+ST+fn("    op_t acc[2];\n    acc[0].k = n;\n    acc[1].data = acc[0].k;\n", kw='task')+'endpackage\n'+"""package a;
  import u::*;
  task automatic g(); t(1); endtask
endpackage
package b;
  import u::*;
  task automatic h(); t(2); endtask
endpackage
module top;
  import a::*;
  import b::*;
  initial begin g(); h(); end
endmodule
""")
C['VF/vf12']=(L1,'two fixed arrays of two structs in one function', 'package u;\n'+ST+'  typedef union { int i; bit [31:0] b; } un_t;\n'+fn("    op_t acc[2];\n    un_t uu[3];\n    acc[0].k = n;\n    uu[1].i = n;\n    return acc[1].data + uu[2].i;\n")+'endpackage\n'+imp1())
C['VF/vf13']=(L1,'importer chain b imports a which imports u', 'package u;\n'+ST+fn("    op_t acc[2];\n    acc[0].k = n;\n    return acc[1].data;\n")+'endpackage\n'+"""package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
package b;
  import a::*;
  import u::*;
  function int h(); return g() + f(2); endfunction
endpackage
module top;
  import b::*;
  int x;
  initial x = h();
endmodule
""")
C['VF/vf14']=(L1,'module imports u directly and package a clones', 'package u;\n'+ST+fn("    op_t acc[2];\n    acc[0].k = n;\n    return acc[1].data;\n")+'endpackage\n'+"""package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import u::*;
  import a::*;
  int x;
  initial x = g() + f(5);
endmodule
""")
C['VF/vf15']=(L1,'explicit import u::f in the importer', 'package u;\n'+ST+fn("    op_t acc[2];\n    acc[0].k = n;\n    return acc[1].data;\n")+'endpackage\n'+"""package a;
  import u::f;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
""")
C['VF/vf16']=(L1,'static local array', 'package u;\n'+ST+"  function automatic int f(int n);\n    static op_t acc[2];\n    acc[0].k = n;\n    return acc[1].data;\n  endfunction\n"+'endpackage\n'+imp1())
# VA: law 2
C['VA/va01']=(L2,'queue of a struct with packed vector members', 'package u;\n  typedef struct { logic [7:0] a; bit [3:0] b; } op_t;\n'+fn("    op_t acc[$];\n    acc.push_back('{a: n, b: 1});\n    return acc[0].a;\n")+'endpackage\n'+imp1())
C['VA/va02']=(L2,'queue of a union', 'package u;\n  typedef union { int i; bit [31:0] b; } op_t;\n'+fn("    op_t acc[$];\n    op_t e;\n    e.i = n;\n    acc.push_back(e);\n    return acc[0].i;\n")+'endpackage\n'+imp1())
C['VA/va03']=(L2,'dynamic array in a task', 'package u;\n'+ST+fn("    op_t acc[];\n    acc = new[2];\n    acc[0].k = n;\n", kw='task')+'endpackage\n'+"""package a;
  import u::*;
  task automatic g(); t(1); endtask
endpackage
module top;
  import a::*;
  initial g();
endmodule
""")
C['VA/va04']=(L2,'queue of a struct with an anonymous struct member', 'package u;\n  typedef struct { struct { int q; } in; int data; } op_t;\n'+fn("    op_t acc[$];\n    op_t e;\n    e.data = n;\n    acc.push_back(e);\n    return acc[0].data;\n")+'endpackage\n'+imp1())
C['VA/va05']=(L2,'queue of a struct, three importers', 'package u;\n'+ST+fn("    op_t acc[$];\n    acc.push_back('{k: n, data: 1});\n    return acc[0].data;\n")+'endpackage\n'+imp2())
C['VA/va06']=(L2,'dynamic array of a struct as a formal', 'package u;\n'+ST+fn("    return acc[0].data + n;\n", args='op_t acc[], int n')+'endpackage\n'+"""package a;
  import u::*;
  function int g(); op_t q[]; q = new[1]; return f(q, 1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
""")
C['VA/va07']=(L2,'queue of a struct with a string member', 'package u;\n  typedef struct { string s; int data; } op_t;\n'+fn("    op_t acc[$];\n    acc.push_back('{s: \"x\", data: n});\n    return acc[0].data;\n")+'endpackage\n'+imp1())
C['VA/va08']=(L2,'queue of a struct in a class method of the home package', 'package u;\n'+ST+"  class C;\n    function int m(int n);\n      op_t acc[$];\n      acc.push_back('{k: n, data: 1});\n      return acc[0].data;\n    endfunction\n  endclass\n"+fn("    C c = new;\n    return c.m(n);\n")+'endpackage\n'+imp1())
# VC: law 3
C['VC/vc01']=(L3,'scalar struct local with an enum member', 'package u;\n  typedef enum {A, B} e_t;\n  typedef struct { e_t e; int data; } op_t;\n'+fn("    op_t s;\n    s.e = B;\n    s.data = n;\n    return s.data;\n")+'endpackage\n'+imp1())
C['VC/vc02']=(L3,'struct formal', 'package u;\n'+ST+fn("    return p.data;\n", args='op_t p')+'endpackage\n'+"""package a;
  import u::*;
  function int g(); op_t q; q.data = 1; return f(q); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
""")
C['VC/vc03']=(L3,'struct return type', 'package u;\n'+ST+fn("    f.k = n;\n    f.data = n;\n", ret='op_t')+'endpackage\n'+"""package a;
  import u::*;
  function int g(); op_t q; q = f(1); return q.data; endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
""")
C['VC/vc04']=(L3,'scalar union local, two importers', 'package u;\n  typedef union { int i; bit [31:0] b; } op_t;\n'+fn("    op_t s;\n    s.i = n;\n    return s.i;\n")+'endpackage\n'+imp2())
C['VC/vc05']=(L3,'struct with a struct-typedef member, scalar local', 'package u;\n  typedef struct { int k; int data; } in_t;\n  typedef struct { in_t i; int z; } op_t;\n'+fn("    op_t s;\n    s.i.data = n;\n    return s.i.data;\n")+'endpackage\n'+imp1())
C['VC/vc06']=(L3,'struct with a member typed by an enum of a third package', 'package s;\n  typedef enum {A, B} e_t;\nendpackage\npackage u;\n  import s::*;\n  typedef struct { s::e_t e; int data; } op_t;\n'+fn("    op_t s0;\n    s0.data = n;\n    return s0.data;\n")+'endpackage\n'+imp1())
C['VC/vc07']=(L3,'struct local, the typedef also used in a module port', 'package u;\n'+ST+fn("    op_t s;\n    s.data = n;\n    return s.data;\n")+'endpackage\n'+"""package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module sub(input u::op_t p, output int o);
  assign o = p.data;
endmodule
module top;
  import a::*;
  u::op_t w;
  int x, y;
  sub s0(.p(w), .o(y));
  initial x = g();
endmodule
""")
C['VC/vc08']=(L3,'enum local of the home package', 'package u;\n  typedef enum {A, B, C} e_t;\n'+fn("    e_t e;\n    e = B;\n    return int'(e) + n;\n")+'endpackage\n'+imp1())
C['VC/vc09']=(L3,'two packages each declaring a struct op_t, both cloned', 'package u;\n'+ST+fn("    op_t s;\n    s.data = n;\n    return s.data;\n")+'endpackage\npackage v;\n  typedef struct { int z; } op_t;\n  function int fv(int n);\n    op_t s;\n    s.z = n;\n    return s.z;\n  endfunction\nendpackage\n'+"""package a;
  import u::*;
  import v::*;
  function int g(); return f(1) + fv(2); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
""")
# VP: law 4
C['VP/vp01']=(L4,'named block local and function locals', 'package u;\n'+fn("    int t;\n    begin : blk\n      int q;\n      q = n;\n      t = q;\n    end\n    return t;\n")+'endpackage\n'+imp1())
C['VP/vp02']=(L4,'for loop variable and a local', 'package u;\n'+fn("    int s;\n    s = 0;\n    for (int i = 0; i < n; i++) s += i;\n    return s;\n")+'endpackage\n'+imp1())
C['VP/vp03']=(L4,'local with an initializer, two importers', 'package u;\n'+fn("    int t = n;\n    int w = 2;\n    return t + w;\n")+'endpackage\n'+imp2())
C['VP/vp04']=(L4,'task with fork and locals', 'package u;\n'+fn("    int a0;\n    a0 = n;\n    fork\n      begin int z; z = a0; end\n    join\n", kw='task')+'endpackage\n'+"""package a;
  import u::*;
  task automatic g(); t(1); endtask
endpackage
module top;
  import a::*;
  initial g();
endmodule
""")
C['VP/vp05']=(L4,'class method in the home package called by the clone', 'package u;\n  class C;\n    function int m(int n);\n      int r;\n      r = n;\n      return r;\n    endfunction\n  endclass\n'+fn("    int z;\n    C c = new;\n    z = c.m(n);\n    return z;\n")+'endpackage\n'+imp1())
C['VP/vp06']=(L4,'local declared after statements in an unnamed begin', 'package u;\n'+fn("    int t;\n    t = n;\n    begin\n      int q;\n      q = t;\n      t = q + 1;\n    end\n    return t;\n")+'endpackage\n'+imp1())
# VI: law 5
C['VI/vi01']=(L5,'acc[0][1].data, three importers', 'package u;\n'+ST+fn("    op_t acc[2][3];\n    acc[0][1].k = n;\n    return acc[1][2].data;\n")+'endpackage\n'+imp2())
C['VI/vi02']=(L5,'variable indexes in two dimensions', 'package u;\n'+ST+fn("    op_t acc[2][3];\n    acc[i][j].k = 1;\n    return acc[j][i].data;\n", args='int i, int j')+'endpackage\n'+imp1('f(0, 1)'))
C['VI/vi03']=(L5,'queue of fixed arrays acc[$][2]', 'package u;\n'+ST+fn("    op_t acc[$][2];\n    op_t e[2];\n    acc.push_back(e);\n    acc[0][1].k = n;\n    return acc[0][1].data;\n")+'endpackage\n'+imp1())
C['VI/vi04']=(L5,'acc[0][1].i.data, both chain laws', 'package u;\n  typedef struct { int k; int data; } in_t;\n  typedef struct { in_t i; int z; } op_t;\n'+fn("    op_t acc[2][2];\n    acc[0][1].z = n;\n    return acc[1][0].i.data;\n")+'endpackage\n'+imp1())
C['VI/vi05']=(L5,'acc[0][1].data[3:0] part-select after the member', 'package u;\n  typedef struct { int k; logic [7:0] data; } op_t;\n'+fn("    op_t acc[2][2];\n    acc[0][1].data[3:0] = n;\n    return acc[1][1].data[7:4];\n")+'endpackage\n'+imp1())
C['VI/vi06']=(L5,'two-dimension array called only from the module (no clone)', 'package u;\n'+ST+fn("    op_t acc[2][3];\n    acc[0][1].k = n;\n    return acc[1][2].data;\n")+'endpackage\nmodule top;\n  import u::*;\n  int x;\n  initial x = f(1);\nendmodule\n')
C['VI/vi07']=(L5,'struct with a two-dimension array member s.arr[0][1]', 'package u;\n  typedef struct { int arr[2][2]; int z; } op_t;\n'+fn("    op_t s;\n    s.arr[0][1] = n;\n    return s.arr[1][0];\n")+'endpackage\n'+imp1())
C['VI/vi08']=(L5,'array of int arrays inside a struct array acc[0].arr[1][0]', 'package u;\n  typedef struct { int arr[2][2]; int z; } op_t;\n'+fn("    op_t acc[2];\n    acc[0].arr[1][0] = n;\n    return acc[1].arr[0][1];\n")+'endpackage\n'+imp1())
# VM: law 6
C['VM/vm01']=(L6,'three member levels acc[1].o.i.data', 'package u;\n  typedef struct { int k; int data; } in_t;\n  typedef struct { in_t i; int y; } mid_t;\n  typedef struct { mid_t o; int z; } op_t;\n'+fn("    op_t acc[2];\n    acc[0].z = n;\n    return acc[1].o.i.data;\n")+'endpackage\n'+imp1())
C['VM/vm02']=(L6,'union member inside a struct', 'package u;\n  typedef union { int i; bit [31:0] b; } un_t;\n  typedef struct { un_t m; int z; } op_t;\n'+fn("    op_t acc[2];\n    acc[0].m.i = n;\n    return acc[1].m.i;\n")+'endpackage\n'+imp1())
C['VM/vm03']=(L6,'packed struct member', 'package u;\n  typedef struct packed { logic [3:0] x; logic [3:0] y; } p_t;\n  typedef struct { p_t p; int z; } op_t;\n'+fn("    op_t acc[2];\n    acc[0].p.x = n;\n    return acc[1].p.y;\n")+'endpackage\n'+imp1())
C['VM/vm04']=(L6,'member typed by an alias of a struct', 'package u;\n  typedef struct { int k; int data; } in_t;\n  typedef in_t in2_t;\n  typedef struct { in2_t i; int z; } op_t;\n'+fn("    op_t acc[2];\n    acc[0].z = n;\n    return acc[1].i.data;\n")+'endpackage\n'+imp1())
C['VM/vm05']=(L6,'member typed by a struct of a third package', 'package s;\n  typedef struct { int k; int data; } in_t;\nendpackage\npackage u;\n  typedef struct { s::in_t i; int z; } op_t;\n'+fn("    op_t acc[2];\n    acc[0].z = n;\n    return acc[1].i.data;\n")+'endpackage\n'+imp1())
C['VM/vm06']=(L6,'member chain on a queue element acc[0].i.data', 'package u;\n  typedef struct { int k; int data; } in_t;\n  typedef struct { in_t i; int z; } op_t;\n'+fn("    op_t acc[$];\n    op_t e;\n    acc.push_back(e);\n    acc[0].i.k = n;\n    return acc[0].i.data;\n")+'endpackage\n'+imp1())
C['VM/vm07']=(L6,'member chain on a scalar struct local s.i.data', 'package u;\n  typedef struct { int k; int data; } in_t;\n  typedef struct { in_t i; int z; } op_t;\n'+fn("    op_t s;\n    s.i.k = n;\n    return s.i.data;\n")+'endpackage\n'+imp1())
C['VM/vm08']=(L6,'member chain inside a module function (no clone)', 'package u;\n  typedef struct { int k; int data; } in_t;\n  typedef struct { in_t i; int z; } op_t;\nendpackage\nmodule top;\n  import u::*;\n  function int f(int n);\n    op_t acc[2];\n    acc[0].z = n;\n    return acc[1].i.data;\n  endfunction\n  int x;\n  initial x = f(1);\nendmodule\n')
C['VM/vm09']=(L6,'enum member then .name() call', 'package u;\n  typedef enum {A, B} e_t;\n  typedef struct { e_t e; int z; } op_t;\n'+fn("    op_t acc[2];\n    string s;\n    acc[0].e = B;\n    s = acc[0].e.name();\n    return acc[1].z + n;\n")+'endpackage\n'+imp1())
for k,(law,shape,src) in C.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(f'// § {law} ({shape})\n'+src)
print(len(C))
