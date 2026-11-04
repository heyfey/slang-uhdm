import os
R='/tmp/wt_v11u484/tools/probe/v11u484repro/cases'
C={}
C['VC/vc09']=('cloneAliasCopyBareName484','middle alias in the home package over a third-package struct, cloned','''package s;
  typedef struct { int k; int data; } op_t;
endpackage
package u;
  typedef s::op_t mid_t;
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
C['VC/vc10']=('cloneAliasCopyBareName484','union alias of an alias in a clone','''package u;
  typedef union packed { logic [7:0] r; logic [7:0] q; } un_t;
  typedef un_t un2_t;
  typedef un2_t un3_t;
  function logic [7:0] f(logic [7:0] n);
    un3_t acc;
    acc.r = n;
    return acc.q;
  endfunction
endpackage
package a;
  import u::*;
  function logic [7:0] g(); return f(8'h5); endfunction
endpackage
module top(output logic [7:0] o);
  import a::*;
  assign o = g();
endmodule''')
C['VC/vc11']=('cloneAliasCopyBareName484','home alias local, the home package imported straight into a module that calls it','''package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
module top;
  import u::*;
  int x;
  initial x = f(1);
endmodule''')
C['VC/vc12']=('cloneAliasCopyBareName484','home alias of an unpacked-array typedef, cloned (copy kind array)','''package u;
  typedef struct { int k; } op_t;
  typedef op_t arr_t [2];
  typedef arr_t a2_t;
  function int f(int n);
    a2_t acc;
    acc[0].k = n;
    return acc[1].k;
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
C['VC/vc13']=('cloneAliasCopyBareName484','alias declared in the importing package of the home struct, local in a function cloned again into a third package','''package u;
  typedef struct { int k; int data; } op_t;
endpackage
package a;
  import u::*;
  typedef op_t op2_t;
  function int g(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
package b;
  import a::*;
  function int h(); return g(2); endfunction
endpackage
module top;
  import b::*;
  int x;
  initial x = h();
endmodule''')
C['VC/vc14']=('cloneAliasCopyBareName484','clone in a package imported by an interface','''package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
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
interface ifc;
  import a::*;
  int x;
  initial x = g();
endinterface
module top;
  ifc i();
endmodule''')
C['VC/vc15']=('cloneAliasCopyBareName484','two aliases of one struct in one clone','''package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t opa_t;
  typedef op_t opb_t;
  function int f(int n);
    opa_t x;
    opb_t y[2];
    x.k = n;
    y[0] = x;
    return y[0].k;
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
C['VP/vp07']=('aliasTdTargetTopView484','package alias never imported, only declared with a function local','''package u;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  function automatic logic [3:0] f(logic [7:0] n);
    op2_t w;
    w = n;
    return w.a;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  assign o = i[3:0];
endmodule''')
C['VP/vp08']=('ownNamedAliasLocalIsRefVar484','package alias with packed dimensions on the named base','''package u;
  typedef logic [3:0] b_t;
  typedef b_t [1:0] w_t;
  function automatic logic [7:0] f(logic [7:0] n);
    w_t a;
    a = n;
    return a;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  assign o = u::f(i);
endmodule''')
C['VP/vp09']=('aliasTdMembTsInstAtAlias484','package alias of a struct whose member is typed by an alias','''package u;
  typedef logic [3:0] n_t;
  typedef n_t n2_t;
  typedef struct packed { n2_t a; n_t b; } op_t;
  typedef op_t op2_t;
  function automatic logic [3:0] f(logic [7:0] n);
    op2_t w;
    w = n;
    return w.a;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [3:0] o);
  import u::*;
  op2_t v;
  assign v = i;
  assign o = f(v);
endmodule''')
C['VP/vp10']=('aliasTdTargetTopView484','package enum alias whose base enum has a typedef base','''package u;
  typedef logic [1:0] b_t;
  typedef enum b_t { A, B, C } e_t;
  typedef e_t e2_t;
  function automatic logic [1:0] f(logic [1:0] n);
    e2_t e;
    e = e2_t'(n);
    return e;
  endfunction
endpackage
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = u::f(i);
endmodule''')
C['VL/vl15']=('ownNamedAliasLocalIsRefVar484','var keyword and a static local of the alias','''package u;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    var op2_t a;
    static op2_t b;
    a.k = n; b = a;
    return b.k;
  endfunction
endpackage
module top;
  int x;
  initial x = u::f(1);
endmodule''')
C['VL/vl16']=('ownNamedAliasLocalIsRefVar484','two declarators with an initializer on the first','''module top;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a = '{1, 2}, b;
    b = a;
    b.k = n;
    return b.k + a.d;
  endfunction
  int x;
  initial x = f(1);
endmodule''')
C['VL/vl17']=('ownNamedAliasLocalIsRefVar484','fixed array of a module alias in a module task','''module top;
  typedef union packed { logic [7:0] r; logic [7:0] q; } un_t;
  typedef un_t un2_t;
  task t(output logic [7:0] o);
    un2_t acc[2];
    acc[0].r = 8'h3;
    o = acc[0].q;
  endtask
  logic [7:0] x;
  initial t(x);
endmodule''')
C['VL/vl18']=('ownNamedAliasLocalIsRefVar484','package alias local in a package class method (control) and a free function','''package u;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  class C;
    function int m(int n);
      op2_t a;
      a.k = n;
      return a.k;
    endfunction
  endclass
  function int f(int n);
    op2_t b;
    b.d = n;
    return b.d;
  endfunction
endpackage
module top;
  int x;
  initial begin u::C c; c = new; x = c.m(1) + u::f(2); end
endmodule''')
C['VM/vm13']=('modAliasTdAtBaseClone484','module alias of a package struct, the package wildcard-imported by top and by sub, port connection','''package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
endpackage
module sub(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  typedef op_t loc_t;
  loc_t w;
  assign w = i;
  assign o = w.b;
endmodule
module top(input logic [7:0] i, output logic [3:0] o);
  import p::*;
  typedef op_t loc_t;
  loc_t w;
  assign w = i;
  sub u(.i(w), .o(o));
endmodule''')
C['VM/vm14']=('modAliasTdAtBaseClone484','program alias of a package union','''package p;
  typedef union packed { logic [7:0] r; logic [7:0] q; } un_t;
endpackage
program prg;
  typedef p::un_t u2_t;
  u2_t w;
  initial begin w.r = 8'h3; $display(w.q); end
endprogram''')
for k,(law,desc,body) in C.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(f'// § {law} ({desc})\n'+body+'\n')
print(len(C))
