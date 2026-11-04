import os
R='/tmp/wt_v11u478/tools/probe/v11u478repro/cases'
C={}
LF='§ aliasFormalCopyPerClone478'
LM='§ cloneHierArrElemMember478'
LQ='§ aliasCopyParamUnnamed478'
LB='§ providerBodyCopyBind478'
def uses(n): return '\n'.join(f'package i{k};\n  import h::*;\n  class X{k}; function int g(); return f(A); endfunction endclass\nendpackage' for k in range(n))
C['VF/vf01']=f'''// {LF} (three importing packages)
package h;
  typedef enum {{A, B}} mode_e;
  typedef mode_e M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
{uses(3)}
module top;
  import i0::*; import i1::*; import i2::*;
  X0 x0; X1 x1; X2 x2;
endmodule
'''
C['VF/vf02']=f'''// {LF} (three alias levels)
package h;
  typedef enum {{A, B}} mode_e;
  typedef mode_e M1;
  typedef M1 M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
{uses(2)}
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
'''
C['VF/vf03']=f'''// {LF} (control: alias of an alias of a struct)
package h;
  typedef struct {{int a; int b;}} st_t;
  typedef st_t S1;
  typedef S1 M_T;
  typedef enum {{A, B}} e_t;
  function automatic int f(M_T v);
    return v.a;
  endfunction
endpackage
package i0;
  import h::*;
  class X0; function int g(); M_T s; return f(s); endfunction endclass
endpackage
package i1;
  import h::*;
  class X1; function int g(); M_T s; return f(s); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
'''
C['VF/vf04']=f'''// {LF} (a module importer beside a package importer)
package h;
  typedef enum {{A, B}} mode_e;
  typedef mode_e M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
package i0;
  import h::*;
  class X0; function int g(); return f(A); endfunction endclass
endpackage
module top;
  import h::*;
  import i0::*;
  X0 x0;
  int r;
  initial r = f(B);
endmodule
'''
C['VF/vf05']=f'''// {LF} (two alias formals in two functions, two importers)
package h;
  typedef enum {{A, B}} mode_e;
  typedef enum {{P, Q}} kind_e;
  typedef mode_e M_T;
  typedef kind_e K_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
  function automatic int k(K_T w);
    return int'(w);
  endfunction
endpackage
package i0;
  import h::*;
  class X0; function int g(); return f(A) + k(P); endfunction endclass
endpackage
package i1;
  import h::*;
  class X1; function int g(); return f(B) + k(Q); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
'''
C['VF/vf06']=f'''// {LF} (task output and inout formals)
package h;
  typedef enum {{A, B}} mode_e;
  typedef mode_e M_T;
  task automatic t(output M_T o, inout M_T io);
    o = A; io = B;
  endtask
endpackage
package i0;
  import h::*;
  class X0; task g(); M_T a, b; t(a, b); endtask endclass
endpackage
package i1;
  import h::*;
  class X1; task g(); M_T a, b; t(a, b); endtask endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
'''
C['VF/vf07']=f'''// {LF} (a provider chain: t reaches h only through a)
package h;
  typedef enum {{A, B}} mode_e;
  typedef mode_e M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
package a;
  import h::*;
  class X; function int g(); return f(A); endfunction endclass
endpackage
package t;
  import a::*;
  class T; X x; endclass
endpackage
package s;
  import h::*;
  class Y; function int g(); return f(B); endfunction endclass
endpackage
module top;
  import t::*; import s::*;
  T o; Y y;
endmodule
'''
C['VF/vf08']=f'''// {LF} (a file-level import beside a package importer)
package h;
  typedef enum {{A, B}} mode_e;
  typedef mode_e M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
import h::*;
package i0;
  import h::*;
  class X0; function int g(); return f(A); endfunction endclass
endpackage
package i1;
  import h::*;
  class X1; function int g(); return f(B); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
'''
C['VF/vf09']=f'''// {LF} (an alias formal with a default)
package h;
  typedef enum {{A, B}} mode_e;
  typedef mode_e M_T;
  function automatic int f(M_T v = B);
    return int'(v);
  endfunction
endpackage
package i0;
  import h::*;
  class X0; function int g(); return f(); endfunction endclass
endpackage
package i1;
  import h::*;
  class X1; function int g(); return f(A); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
'''
C['VF/vf10']=f'''// {LF} (class method and free function sharing the alias, two importers)
package h;
  typedef enum {{A, B}} mode_e;
  typedef mode_e M_T;
  function automatic int pf(M_T v);
    return int'(v);
  endfunction
  class C;
    extern function void set(M_T val);
  endclass
  function void C::set(M_T val);
  endfunction
endpackage
package i0;
  import h::*;
  class X0; C c; function int g(); return pf(A); endfunction endclass
endpackage
package i1;
  import h::*;
  class X1; C c; function int g(); return pf(B); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
'''
C['VF/vf11']=f'''// {LF} (the base enum declared in another package)
package e;
  typedef enum {{A, B}} mode_e;
endpackage
package h;
  import e::*;
  typedef mode_e M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
package i0;
  import e::*; import h::*;
  class X0; function int g(); return f(A); endfunction endclass
endpackage
package i1;
  import e::*; import h::*;
  class X1; function int g(); return f(B); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
'''
C['VF/vf12']=f'''// {LF} (an explicit import of the function)
package h;
  typedef enum {{A, B}} mode_e;
  typedef mode_e M_T;
  function automatic int f(M_T v);
    return int'(v);
  endfunction
endpackage
package i0;
  import h::f; import h::A;
  class X0; function int g(); return f(A); endfunction endclass
endpackage
package i1;
  import h::*;
  class X1; function int g(); return f(B); endfunction endclass
endpackage
module top;
  import i0::*; import i1::*;
  X0 x0; X1 x1;
endmodule
'''
# ---------- VM
def am(body_decl, use, pre='', extra_pkg='', cls_extra=''):
    return f'''package u;
{pre}  class C;
{cls_extra}    extern function int f(int n);
  endclass
  function int C::f(int n);
{body_decl}
    int r;
    {use}
    return r;
  endfunction
endpackage
{extra_pkg}package a;
  import u::*;
  class A; C c; endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top;
  import a::*; import t::*;
  A o; T p;
endmodule
'''
ST='  typedef struct { int k; bit [63:0] data; } op_t;\n'
C['VM/vm01']=f'// {LM} (a two-dimension unpacked array)\n'+am('    op_t acc[2][3];','r = acc[0][1].data;',ST)
C['VM/vm02']=f'// {LM} (a packed array of a packed struct in an unpacked array)\n'+am('    op_t [1:0] acc [2];','r = acc[0][1].data;','  typedef struct packed { logic [7:0] data; logic k; } op_t;\n')
C['VM/vm03']=f'// {LM} (a member named size)\n'+am('    op_t acc[$];','r = acc[0].size;','  typedef struct { int k; int size; } op_t;\n')
C['VM/vm04']=f'// {LM} (a member named name)\n'+am('    op_t acc[2];','r = acc[0].name;','  typedef struct { int k; int name; } op_t;\n')
C['VM/vm05']=f'// {LM} (a struct typedef declared in the function)\n'+am('    typedef struct { int k; int data; } lt;\n    lt acc[2];','r = acc[1].data;')
C['VM/vm06']=f'''// {LM} (the array is a formal)
package u;
  typedef struct {{ int k; int data; }} op_t;
  typedef op_t arr_t [2];
  function automatic int f(arr_t acc);
    return acc[1].data;
  endfunction
endpackage
package a;
  import u::*;
  class A; function int g(); arr_t x; return f(x); endfunction endclass
endpackage
module top; import a::*; A o; endmodule
'''
C['VM/vm07']=f'// {LM} (a package-level array)\n'+am('','r = g_acc[1].data;',ST+'  op_t g_acc[4];\n')
C['VM/vm08']=f'// {LM} (a struct array inside a struct array)\n'+am('    op_t acc[2];','r = acc[0].b[1].data;','  typedef struct { int k; int data; } in_t;\n  typedef struct { in_t b[2]; int z; } op_t;\n')
C['VM/vm09']=f'// {LM} (a dynamic array)\n'+am('    op_t acc[];','acc = new[2]; r = acc[1].data;',ST)
C['VM/vm10']=f'// {LM} (an associative array)\n'+am('    op_t acc[int];','r = acc[5].data;',ST)
C['VM/vm11']=f'// {LM} (an alias of the struct typedef)\n'+am('    op2_t acc[2];','r = acc[1].data;',ST+'  typedef op_t op2_t;\n')
C['VM/vm12']=f'// {LM} (the struct imported from another package)\n'+am('    op_t acc[2];','r = acc[1].data;','  import s::*;\n',extra_pkg='')
C['VM/vm12']=C['VM/vm12'].replace('package u;','package s;\n  typedef struct { int k; bit [63:0] data; } op_t;\nendpackage\npackage u;',1)
C['VM/vm13']=f'// {LM} (a write and a foreach)\n'+am('    op_t acc[2];','acc[0].data = 5; foreach (acc[i]) r += acc[i].k;',ST)
C['VM/vm14']=f'// {LM} (a struct typedef of a class read through a package alias)\n'+am('    op2_t acc[2];','r = acc[1].data;','  class K; typedef struct { int k; int data; } op_t; endclass\n  typedef K::op_t op2_t;\n')
C['VM/vm15']=f'''// {LM} (a free function, direct and provider importers)
package u;
  typedef struct {{ int k; bit [63:0] data; }} op_t;
  function automatic int f(int n);
    op_t acc[$];
    int r;
    acc.push_back('{{1, 2}});
    r = acc[0].data;
    return r;
  endfunction
endpackage
package a;
  import u::*;
  class A; function int g(); return f(1); endfunction endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
package d;
  import u::*;
  class D; function int g(); return f(2); endfunction endclass
endpackage
module top; import t::*; import d::*; T o; D q; endmodule
'''
C['VM/vm16']=f'// {LM} (a union array)\n'+am('    un_t acc[2];','r = acc[1].data;','  typedef union { int k; int data; } un_t;\n')
C['VM/vm17']=f'// {LM} (a member select after the member)\n'+am('    op_t acc[2];','r = acc[1].data[3];',ST)
C['VM/vm18']=f'// {LM} (a struct array in a struct)\n'+am('    op_t acc;','r = acc.b[1].data;','  typedef struct { int k; int data; } in_t;\n  typedef struct { in_t b[2]; int z; } op_t;\n')
# ---------- VQ
C['VQ/vq01']=f'''// {LQ} (a module typedef chain of a value specialization)
class C #(int W = 1, int V = 2);
  int x;
endclass
module top;
  typedef C #(4, 5) c_t;
  typedef c_t c2_t;
  c2_t h;
endmodule
'''
C['VQ/vq02']=f'''// {LQ} (a package typedef chain used by a class property)
package p;
  class C #(int W = 1, int V = 2);
    typedef C #(W, V) this_t;
    int x;
  endclass
  typedef C #(8, 9) c_t;
  typedef c_t c2_t;
  class D; c2_t h; endclass
endpackage
module top; import p::*; D d; endmodule
'''
C['VQ/vq03']=f'''// {LQ} (named overrides)
package u;
  class R #(type T = int);
    typedef R #(T) this_type;
  endclass
endpackage
package a;
  import u::*;
  class A #(int W = 1, int V = 2);
    typedef A #(.W(W), .V(V)) this_t;
    typedef R #(this_t) type_id;
  endclass
  typedef A #(.V(7)) A_t;
  class E; A_t h; endclass
endpackage
module top; import a::*; E e; endmodule
'''
C['VQ/vq04']=f'''// {LQ} (a type and a value parameter)
package u;
  class R #(type T = int);
    typedef R #(T) this_type;
  endclass
endpackage
package a;
  import u::*;
  class A #(type X = int, int W = 1);
    typedef A #(X, W) this_t;
    typedef R #(this_t) type_id;
    X d;
  endclass
  class K; localparam w = 3; endclass
  typedef A #(byte, K::w) A_t;
endpackage
package c;
  import a::*;
  class E; A_t h; endclass
endpackage
module top; import c::*; E e; endmodule
'''
C['VQ/vq05']=f'''// {LQ} (a nested class specialization)
package a;
  class O;
    class A #(int W = 1);
      typedef A #(W) this_t;
    endclass
  endclass
  typedef O::A #(6) A_t;
  class E; A_t h; endclass
endpackage
module top; import a::*; E e; endmodule
'''
C['VQ/vq06']=f'''// {LQ} ($unit classes)
class R #(type T = int);
  typedef R #(T) this_type;
endclass
class A #(int W = 1, int V = 2);
  typedef A #(W, V) this_t;
  typedef R #(this_t) type_id;
endclass
class K; localparam w = 11; endclass
typedef A #(K::w, 4) A_t;
class E; A_t h; endclass
module top; E e; endmodule
'''
C['VQ/vq07']=f'''// {LQ} (an imported package parameter as the argument)
package q;
  parameter int QW = 12;
endpackage
package u;
  class R #(type T = int);
    typedef R #(T) this_type;
  endclass
endpackage
package a;
  import u::*;
  class A #(int W = 1, int V = 2);
    typedef A #(W, V) this_t;
    typedef R #(this_t) type_id;
  endclass
endpackage
package b;
  import q::*; import a::*;
  typedef A #(QW, 3) A_t;
  class E; A_t h; endclass
endpackage
module top; import b::*; E e; endmodule
'''
C['VQ/vq08']=f'''// {LQ} (a specialization as a function local in a package function)
package a;
  class A #(int W = 1);
    typedef A #(W) this_t;
    int x;
  endclass
  typedef A #(5) A_t;
  function automatic int f();
    A_t h;
    h = new;
    return h.x;
  endfunction
endpackage
package b;
  import a::*;
  class B; function int g(); return f(); endfunction endclass
endpackage
module top; import b::*; B o; endmodule
'''
# ---------- VB
def pb(fbody, pre='  class C; endclass\n', chain=1):
    s=f'''package u;
{pre}  function automatic void f();
{fbody}
  endfunction
endpackage
package a;
  import u::*;
  class A;
    function void g();
      f();
    endfunction
  endclass
endpackage
'''
    last='a'
    for k in range(chain):
        s+=f'''package t{k};
  import {last}::*;
  class T{k}; A h; endclass
endpackage
'''
        last=f't{k}'
    s+=f'module top; import {last}::*; T{chain-1} o; endmodule\n'
    return s
C['VB/vb01']=f'// {LB} (a local in a nested begin)\n'+pb('    int r;\n    begin\n      int k;\n      k = 1;\n      r = k;\n    end')
C['VB/vb02']=f'// {LB} (two locals of one name in two blocks)\n'+pb('    begin : b1\n      int k;\n      k = 1;\n    end\n    begin : b2\n      int k;\n      k = 2;\n    end')
C['VB/vb03']=f'// {LB} (a three-level chain)\n'+pb('    process p;\n    C c;\n    p = process::self();\n    c = null;',chain=2)
C['VB/vb04']=f'// {LB} (locals with initializers)\n'+pb('    C c = null;\n    int k = 3;\n    if (c == null) k = 4;')
C['VB/vb05']=f'// {LB} (a local in a fork)\n'+pb('    int r;\n    fork\n      begin\n        int k;\n        k = 2;\n        r = k;\n      end\n    join')
C['VB/vb06']=f'// {LB} (a foreach over a local array)\n'+pb('    int arr[3];\n    int s;\n    foreach (arr[i]) s += arr[i];')
C['VB/vb07']=f'// {LB} (a static local)\n'+pb('    static int cnt;\n    int k;\n    cnt++;\n    k = cnt;')
C['VB/vb08']=f'''// {LB} (two providers)
package u;
  class C; endclass
  function automatic void f();
    process p;
    C c;
    p = process::self();
    c = null;
  endfunction
endpackage
package a;
  import u::*;
  class A; function void g(); f(); endfunction endclass
endpackage
package b;
  import u::*;
  class B; function void g(); f(); endfunction endclass
endpackage
package t;
  import a::*; import b::*;
  class T; A h; B j; endclass
endpackage
module top; import t::*; T o; endmodule
'''
C['VB/vb09']=f'// {LB} (a task with a local and a loop variable)\n'+pb('    int r;\n    for (int i = 0; i < 2; i++) r += i;')
C['VB/vb10']=f'''// {LB} (a class method out of body as the provided subroutine)
package u;
  class C;
    extern function int m();
  endclass
  function int C::m();
    process p;
    int k;
    p = process::self();
    k = 1;
    return k;
  endfunction
endpackage
package a;
  import u::*;
  class A; C c; endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top; import t::*; T o; endmodule
'''
C['VB/vb11']=f'// {LB} (a local declared after a statement in a nested begin and named like a formal-less outer local)\n'+pb('    int k;\n    k = 0;\n    begin\n      int k;\n      k = 5;\n    end')
for k,v in C.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(v)
print(len(C))
