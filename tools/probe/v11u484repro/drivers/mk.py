import os,sys
R='/tmp/wt_v11u484/tools/probe/v11u484repro/cases'
C={}
# ---- VL: § ownNamedAliasLocalIsRefVar484
C['VL/vl01']=('ownNamedAliasLocalIsRefVar484','package local of an alias of an alias of a struct','''package u;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  typedef op2_t op3_t;
  function int f(int n);
    op3_t a;
    a.k = n;
    return a.k;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule''')
C['VL/vl02']=('ownNamedAliasLocalIsRefVar484','module function local of a module alias of a module vector typedef','''module top;
  typedef logic [3:0] w_t;
  typedef w_t w2_t;
  function int f(int n);
    w2_t a;
    a = n;
    return a;
  endfunction
  int x;
  initial x = f(1);
endmodule''')
C['VL/vl03']=('ownNamedAliasLocalIsRefVar484','module function local of a module alias of a $unit struct','''typedef struct { int k; int d; } op_t;
module top;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a;
    a.k = n;
    return a.k;
  endfunction
  int x;
  initial x = f(1);
endmodule''')
C['VL/vl04']=('ownNamedAliasLocalIsRefVar484','package local with an initializer','''package u;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a = '{k: 1, d: 2};
    a.k = n;
    return a.d;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule''')
C['VL/vl05']=('ownNamedAliasLocalIsRefVar484','program function local of a program alias of a struct','''program prg;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a;
    a.k = n;
    return a.k;
  endfunction
  int x;
  initial x = f(1);
endprogram''')
C['VL/vl06']=('ownNamedAliasLocalIsRefVar484','module function in a generate block (abstains)','''module top;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  if (1) begin : g
    function int f(int n);
      op2_t a;
      a.k = n;
      return a.k;
    endfunction
  end
  int x;
  initial x = g.f(1);
endmodule''')
C['VL/vl07']=('ownNamedAliasLocalIsRefVar484','module alias in a parameterized module instantiated twice','''module sub #(parameter int W = 4) (output int o);
  typedef logic [W-1:0] w_t;
  typedef w_t w2_t;
  function int f(int n);
    w2_t a;
    a = n;
    return a;
  endfunction
  assign o = f(3);
endmodule
module top;
  int a, b;
  sub #(4) u1(a);
  sub #(8) u2(b);
endmodule''')
C['VL/vl08']=('ownNamedAliasLocalIsRefVar484','module alias of a scoped package struct p::op_t','''package p;
  typedef struct { int k; int d; } op_t;
endpackage
module top;
  typedef p::op_t op2_t;
  task t(output int o);
    op2_t a;
    a.k = 1;
    o = a.k;
  endtask
  int x;
  initial t(x);
endmodule''')
C['VL/vl09']=('ownNamedAliasLocalIsRefVar484','package alias of an enum typedef and a local of it plus the enum read','''package u;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t e2_t;
  function int f(int n);
    e2_t e;
    e = B;
    return int'(e) + n;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule''')
C['VL/vl10']=('ownNamedAliasLocalIsRefVar484','interface task local of an interface alias of a package union','''package p;
  typedef union packed { logic [7:0] b; logic [7:0] c; } un_t;
endpackage
interface ifc;
  typedef p::un_t u2_t;
  logic [7:0] q;
  task t();
    u2_t a;
    a.b = 8'h3;
    q = a.c;
  endtask
endinterface
module top;
  ifc i();
  initial i.t();
endmodule''')
C['VL/vl11']=('ownNamedAliasLocalIsRefVar484','package local, alias declared after the function','''package u;
  typedef struct { int k; int d; } op_t;
  function automatic int f(int n);
    op2_t a;
    a.k = n;
    return a.k;
  endfunction
  typedef op_t op2_t;
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule''')
C['VL/vl12']=('ownNamedAliasLocalIsRefVar484','uninstantiated module function local of a module alias','''module other;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a;
    a.k = n;
    return a.k;
  endfunction
endmodule
module top;
  int x;
  initial x = 1;
endmodule''')
C['VL/vl13']=('ownNamedAliasLocalIsRefVar484','two locals in one declaration plus a dynamic array of the alias','''package u;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a, b;
    op2_t q[$];
    a.k = n; b = a;
    q.push_back(b);
    return q[0].k;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule''')
C['VL/vl14']=('ownNamedAliasLocalIsRefVar484','module alias of a module typedef of an int (keyword base)','''module top;
  typedef int i_t;
  typedef i_t i2_t;
  function int f(int n);
    i2_t a;
    a = n + 1;
    return a;
  endfunction
  int x;
  initial x = f(1);
endmodule''')
# ---- VM: § modAliasTdAtBaseClone484
C['VM/vm01']=('modAliasTdAtBaseClone484','module alias of a struct with a nested struct member and an enum member','''module top;
  typedef enum logic [1:0] { A, B } e_t;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } in_t;
  typedef struct packed { in_t i; e_t e; logic [1:0] z; } op_t;
  typedef op_t op2_t;
  op2_t v;
  logic [9:0] o;
  assign v = 10'h15;
  assign o = v;
endmodule''')
C['VM/vm02']=('modAliasTdAtBaseClone484','module alias of a package packed struct used as a port','''package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
endpackage
module sub(input p::op_t i, output logic [3:0] o);
  typedef p::op_t op2_t;
  op2_t w;
  assign w = i;
  assign o = w.a ^ w.b;
endmodule
module top(input logic [7:0] i, output logic [3:0] o);
  sub u(.i(i), .o(o));
endmodule''')
C['VM/vm03']=('modAliasTdAtBaseClone484','module alias of a packed struct used as an output port type','''module sub(input logic [7:0] i, output op2_t o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  assign o = i;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub u(.i(i), .o(o));
endmodule''')
C['VM/vm04']=('modAliasTdAtBaseClone484','interface alias of an interface struct, used by an interface variable','''interface ifc;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  op2_t v;
endinterface
module top(input logic [7:0] i, output logic [3:0] o);
  ifc u();
  assign u.v = i;
  assign o = u.v.a;
endmodule''')
C['VM/vm05']=('modAliasTdAtBaseClone484','two modules each aliasing one package struct','''package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
endpackage
module s1(input logic [7:0] i, output logic [3:0] o);
  typedef p::op_t x_t;
  x_t w;
  assign w = i;
  assign o = w.a;
endmodule
module s2(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  typedef op_t x_t;
  x_t w;
  assign w = i;
  assign o = w.b;
endmodule
module top(input logic [7:0] i, output logic [3:0] o1, o2);
  s1 u1(i, o1);
  s2 u2(i, o2);
endmodule''')
C['VM/vm06']=('modAliasTdAtBaseClone484','parameterized module alias of a parameter-width struct, two instances','''module sub #(parameter int W = 4) (input logic [2*W-1:0] i, output logic [W-1:0] o);
  typedef struct packed { logic [W-1:0] a; logic [W-1:0] b; } op_t;
  typedef op_t op2_t;
  op2_t w;
  assign w = i;
  assign o = w.a;
endmodule
module top(input logic [15:0] i, output logic [3:0] o1, output logic [7:0] o2);
  sub #(4) u1(i[7:0], o1);
  sub #(8) u2(i, o2);
endmodule''')
C['VM/vm07']=('modAliasTdAtBaseClone484','module alias of an alias of a package struct (chain across scopes)','''package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  typedef p::op2_t op3_t;
  op3_t w;
  assign w = i;
  assign o = w.b;
endmodule''')
C['VM/vm08']=('modAliasTdAtBaseClone484','module alias of an unpacked struct with a member default','''module top;
  typedef struct { int k = 3; int d; } op_t;
  typedef op_t op2_t;
  op2_t v;
  int x;
  initial begin v.d = 1; x = v.k + v.d; end
endmodule''')
C['VM/vm09']=('modAliasTdAtBaseClone484','module alias of a union with a struct member','''module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  typedef union packed { s_t s; logic [7:0] r; } u_t;
  typedef u_t u2_t;
  u2_t w;
  assign w.r = i;
  assign o = w.s.b;
endmodule''')
C['VM/vm10']=('modAliasTdAtBaseClone484','module alias declared inside a generate block','''module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  if (1) begin : g
    typedef op_t op2_t;
    op2_t w;
    assign w = i;
    assign o = w.a;
  end
endmodule''')
C['VM/vm11']=('modAliasTdAtBaseClone484','module alias array of a struct, net of the alias with an unpacked dimension','''module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  op2_t w [2];
  assign w[0] = i;
  assign w[1] = ~i;
  assign o = w[0].a ^ w[1].b;
endmodule''')
C['VM/vm12']=('modAliasTdAtBaseClone484','module alias of a struct with an alias-typed member','''module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; } in_t;
  typedef in_t in2_t;
  typedef struct packed { in2_t x; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  op2_t w;
  assign w = i;
  assign o = w.x.a;
endmodule''')
# ---- VP: package alias laws
C['VP/vp01']=('aliasTdMembTsInstAtAlias484','package alias of a struct with an enum and a nested struct member, imported by top','''package u;
  typedef enum logic [1:0] { A, B } e_t;
  typedef struct packed { logic [3:0] x; } in_t;
  typedef struct packed { in_t i; e_t e; } op_t;
  typedef op_t op2_t;
endpackage
module top(input logic [5:0] i, output logic [3:0] o);
  import u::*;
  op2_t w;
  assign w = i;
  assign o = w.i.x;
endmodule''')
C['VP/vp02']=('aliasTdTargetTopView484','package alias chain of three, variable of the last at the module','''package u;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  typedef op2_t op3_t;
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  u::op3_t w;
  assign w = i;
  assign o = w.a;
endmodule''')
C['VP/vp03']=('aliasTdTargetTopView484','package alias of a union of another package','''package s;
  typedef union packed { logic [7:0] r; logic [7:0] q; } un_t;
endpackage
package u;
  import s::*;
  typedef un_t un2_t;
  function automatic logic [7:0] f(logic [7:0] n);
    un2_t a;
    a.r = n;
    return a.q;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  assign o = u::f(i);
endmodule''')
C['VP/vp04']=('aliasTdTargetTopView484','package alias of an enum used by a module variable','''package u;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef e_t e2_t;
endpackage
module top(output logic [1:0] o);
  import u::*;
  e2_t e;
  assign e = C;
  assign o = e;
endmodule''')
C['VP/vp05']=('aliasTdMembTsInstAtAlias484','package alias imported by two modules, each with a variable','''package u;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
endpackage
module s1(input logic [7:0] i, output logic [3:0] o);
  import u::*;
  op2_t w;
  assign w = i;
  assign o = w.a;
endmodule
module s2(input logic [7:0] i, output logic [3:0] o);
  u::op2_t w;
  assign w = i;
  assign o = w.b;
endmodule
module top(input logic [7:0] i, output logic [3:0] o1, o2);
  s1 a(i, o1);
  s2 b(i, o2);
endmodule''')
C['VP/vp06']=('aliasTdMembTsInstAtAlias484','package alias of a $unit struct','''typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
package u;
  typedef op_t op2_t;
  function automatic logic [3:0] f(logic [7:0] n);
    op2_t x;
    x = n;
    return x.b;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  assign o = u::f(i);
endmodule''')
# ---- VC: § cloneAliasCopyBareName484 in import clones
C['VC/vc01']=('cloneAliasCopyBareName484','four-level alias chain local in an import clone','''package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  typedef op2_t op3_t;
  typedef op3_t op4_t;
  function int f(int n);
    op4_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule''')
C['VC/vc02']=('cloneAliasCopyBareName484','middle alias in another package (u alias of s alias of s struct)','''package s;
  typedef struct { int k; int data; } op_t;
  typedef op_t mid_t;
endpackage
package u;
  import s::*;
  typedef mid_t op2_t;
  function int f(int n);
    op2_t acc[2];
    acc[0].k = n;
    return acc[1].data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule''')
C['VC/vc03']=('cloneAliasCopyBareName484','home alias of a $unit struct in an import clone','''typedef struct { int k; int data; } op_t;
package u;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule''')
C['VC/vc04']=('cloneAliasCopyBareName484','two packages each with an alias named op2_t, both cloned','''package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
package v;
  typedef struct { int z; } op_t;
  typedef op_t op2_t;
  function int h(int n);
    op2_t acc;
    acc.z = n;
    return acc.z;
  endfunction
endpackage
package a;
  import u::*;
  import v::h;
  function int g(); return f(1) + h(2); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule''')
C['VC/vc05']=('cloneAliasCopyBareName484','alias local in a task clone called from a module through an explicit import','''package u;
  typedef union { int k; int data; } op_t;
  typedef op_t op2_t;
  task t(output int o);
    op2_t acc;
    acc.k = 3;
    o = acc.data;
  endtask
endpackage
package a;
  import u::t;
  task g(output int o); t(o); endtask
endpackage
module top;
  import a::*;
  int x;
  initial g(x);
endmodule''')
C['VC/vc06']=('cloneAliasCopyBareName484','packed alias local and an alias of a struct holding a third-package struct member, two importers','''package s;
  typedef struct packed { logic [3:0] a; } in_t;
endpackage
package u;
  typedef struct packed { s::in_t i; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  function logic [3:0] f(logic [7:0] n);
    op2_t acc;
    acc = n;
    return acc.i.a;
  endfunction
endpackage
package a;
  import u::*;
  function logic [3:0] g(); return f(8'h12); endfunction
endpackage
package b;
  import u::*;
  function logic [3:0] g2(); return f(8'h34); endfunction
endpackage
module top(output logic [3:0] o1, o2);
  import a::*;
  import b::*;
  assign o1 = g();
  assign o2 = g2();
endmodule''')
C['VC/vc07']=('cloneAliasCopyBareName484','alias array of three elements and an alias struct copy assigned from another','''package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc[3];
    op_t one;
    one.k = n;
    acc[2] = one;
    return acc[2].k;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule''')
C['VC/vc08']=('cloneAliasCopyBareName484','home alias declared in the importing package named like a home typedef','''package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
package a;
  import u::*;
  typedef struct { int z; } op2b_t;
  typedef op2b_t mine_t;
  function int g(); mine_t m; m.z = 2; return f(1) + m.z; endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule''')
for k,(law,desc,body) in C.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(f'// § {law} ({desc})\n'+body+'\n')
print(len(C))
