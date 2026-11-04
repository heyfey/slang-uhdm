import os
R='/tmp/wt_v11u484/tools/probe/v11u484repro/cases'
C={}
C['VC/vc03']=('cloneAliasCopyBareName484','home alias local in a clone reached through an explicit import of the function and of the alias','''package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc;
    acc.k = n;
    return acc.data;
  endfunction
endpackage
package a;
  import u::f;
  import u::op2_t;
  function int g(); op2_t m; m.k = 1; return f(m.k); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule''')
C['VL/vl11']=('ownNamedAliasLocalIsRefVar484','module alias named like a typedef of a wildcard-imported package','''package p;
  typedef struct { int z; } op2_t;
endpackage
module top;
  import p::*;
  typedef struct { int k; int d; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t a;
    a.k = n;
    return a.k;
  endfunction
  int x;
  initial x = f(1);
endmodule''')
C['VM/vm03']=('modAliasTdAtBaseClone484','output port typed by a package alias, module alias of the same','''package p;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
endpackage
module sub(input logic [7:0] i, output p::op2_t o);
  typedef p::op_t loc_t;
  loc_t w;
  assign w = i;
  assign o = w;
endmodule
module top(input logic [7:0] i, output logic [7:0] o);
  sub u(.i(i), .o(o));
endmodule''')
C['VP/vp06']=('aliasTdTargetTopView484','package alias of a packed struct as a function return and a module port','''package u;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  typedef op_t op2_t;
  function automatic op2_t f(logic [7:0] n);
    return n;
  endfunction
endpackage
module top(input logic [7:0] i, output u::op2_t o);
  assign o = u::f(i);
endmodule''')
for k,(law,desc,body) in C.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(f'// § {law} ({desc})\n'+body+'\n')
