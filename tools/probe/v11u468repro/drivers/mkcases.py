import os
R='/tmp/wt_v11u468/tools/probe/v11u468repro/cases'
L1='unitInclClassImports468'; L2='specArgPairsImportedFormal468'; L3='clsPropSpecTpFullName468'; L4='oobClassTdImporterClass468'; L5='specArgTypedefNameShares468'
P='''package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
  function int f(); return 1; endfunction
endpackage
'''
cases={}
def add(name, law, files, order=None):
    cases[name]=(law,files,order)
# ---------- L1
add('VI/vi01',L1,{'dut.sv':P+'''import p::*;
`define MKC(n) class n; int x; endclass
`MKC(c)
module top; c h; endmodule
'''})
add('VI/vi02',L1,{'a.sv':P+'''`define MKC(n) class n; int x; endclass
''','dut.sv':'''import p::*;
`MKC(c)
module top; c h; endmodule
'''},'a.sv dut.sv')
add('VI/vi03',L1,{'m.svh':'''`define MKC(n) class n; int x; endclass
''','dut.sv':P+'''`include "m.svh"
import p::*;
`MKC(c)
module top; c h; endmodule
'''})
add('VI/vi04',L1,{'x.svh':'''`include "c.svh"
''','c.svh':'''class c;
  int x;
endclass
''','dut.sv':P+'''import p::*;
`include "x.svh"
module top; c h; endmodule
'''})
add('VI/vi05',L1,{'i.svh':'''import p::*;
''','dut.sv':P+'''`include "i.svh"
class c;
  int x;
endclass
module top; c h; endmodule
'''})
add('VI/vi06',L1,{'a.sv':P+'''import p::*;
''','c.svh':'''class c;
  int x;
endclass
''','dut.sv':'''`include "c.svh"
module top; c h; endmodule
'''},'a.sv dut.sv')
add('VI/vi07',L1,{'p.svh':P,'c.svh':'''class c;
  int x;
endclass
''','dut.sv':'''`include "p.svh"
import p::*;
`include "c.svh"
module top; c h; endmodule
'''})
add('VI/vi08',L1,{'c.svh':'''class c;
  int x;
  function int g(); return f(); endfunction
endclass
''','dut.sv':P+'''package q;
  parameter int Q = 7;
endpackage
import p::*;
import q::Q;
`include "c.svh"
module top; c h; endmodule
'''})
add('VI/vi09',L1,{'c.svh':'''class c;
  int x;
endclass
''','dut.sv':P+'''import p::*;
module top;
`include "c.svh"
  c h;
endmodule
'''})
# ---------- L2
SP=P+'import p::*;\nclass item; int d; endclass\n'
add('VS/vs01',L2,{'dut.sv':SP+'''class C #(type T = item, type U = int);
  T m; U n;
endclass
class env;
  C #(.U(item)) comp;
endclass
module top; env e; endmodule
'''})
add('VS/vs02',L2,{'dut.sv':SP+'''class C #(type T = item, int W = 2);
  T m; bit [W-1:0] n;
endclass
class env;
  C #(item, 4) comp;
endclass
module top; env e; endmodule
'''})
add('VS/vs03',L2,{'dut.sv':P+'''package q;
  import p::*;
  class item; int d; endclass
  class C #(type T = item);
    T m;
  endclass
endpackage
class env;
  q::C #(q::item) comp;
endclass
module top; env e; endmodule
'''})
add('VS/vs04',L2,{'dut.sv':P+'''package r;
  parameter int RX = 1;
endpackage
import p::*;
import r::*;
class item; int d; endclass
class C #(type T = item, type U = item, type V = item, type W = item);
  T m;
endclass
class env;
  C #(item, int, byte, shortint) comp;
endclass
module top; env e; endmodule
'''})
add('VS/vs05',L2,{'dut.sv':'''package p;
  typedef int t_t;
endpackage
import p::*;
class item; int d; endclass
class C #(type T = item);
  T m;
endclass
class env;
  C #(item) comp;
endclass
module top; env e; endmodule
'''})
add('VS/vs06',L2,{'dut.sv':'''package p;
  parameter int PA = 2;
endpackage
import p::*;
class item; int d; endclass
class C #(type T = item, type U = int, type V = int);
  T m;
endclass
class env;
  C #(item, byte, shortint) comp;
endclass
module top; env e; endmodule
'''})
add('VS/vs07',L2,{'dut.sv':SP+'''class C #(type T = item, type U = int);
  T m;
endclass
class env;
  C #(item) comp;
endclass
module top; env e; endmodule
'''})
add('VS/vs08',L2,{'dut.sv':P+'''import p::PA;
class item; int d; endclass
class C #(type T = item);
  T m;
endclass
class env;
  C #(item) comp;
endclass
module top; env e; endmodule
'''})
add('VS/vs09',L2,{'dut.sv':SP+'''class C #(type T = item);
  T m;
endclass
module top;
  typedef C #(item) ci_t;
  ci_t h;
endmodule
'''})
add('VS/vs10',L2,{'dut.sv':SP+'''class C #(type T = item);
  T m;
endclass
class D extends C #(item);
  int z;
endclass
module top; D d; endmodule
'''})
add('VS/vs11',L2,{'dut.sv':SP+'''class C #(type T = item);
  T m;
endclass
class env;
  function void run();
    C #(item) loc;
    loc = new;
  endfunction
endclass
module top; env e; endmodule
'''})
add('VS/vs12',L2,{'dut.sv':SP+'''class C #(type T = item);
  T m;
endclass
class env;
  typedef C #(item) ci_t;
  ci_t comp;
endclass
module top; env e; endmodule
'''})
# ---------- L3
add('VF/vf01',L3,{'dut.sv':'''package q;
  class C #(type T = int);
    T m;
  endclass
  class env;
    C #(byte) comp;
  endclass
endpackage
module top; q::env e; endmodule
'''})
add('VF/vf02',L3,{'dut.sv':'''class C #(type T = int);
  T m;
endclass
class outer;
  class inner;
    C #(byte) comp;
  endclass
  inner i;
endclass
module top; outer o; endmodule
'''})
add('VF/vf03',L3,{'dut.sv':'''class C #(type T = int, type U = int);
  T m;
endclass
class env;
  rand C #(byte, shortint) comp;
  static C #(byte) s;
endclass
module top; env e; endmodule
'''})
add('VF/vf04',L3,{'dut.sv':'''module top;
  class C #(type T = int);
    T m;
  endclass
  class env;
    C #(byte) comp;
  endclass
  env e;
endmodule
'''})
add('VF/vf05',L3,{'dut.sv':'''class C #(type T = int);
  T m;
endclass
class env;
  C #(byte) a, b;
endclass
module top; env e; endmodule
'''})
add('VF/vf06',L3,{'dut.sv':'''class C #(type T = int);
  T m;
endclass
class env;
  C #(C #(byte)) nest;
endclass
module top; env e; endmodule
'''})
# ---------- L4
PK='''package p;
  class aa;
    typedef aa this_type;
  endclass
  class lib #(type REQ=int);
    typedef lib#(REQ) this_type;
    extern static function bit m_check(int s, this_type l);
  endclass
  function bit lib::m_check(int s, this_type l);
    return 0;
  endfunction
endpackage
'''
add('VO/vo01',L4,{'p.sv':PK,'c.svh':'''class cmp;
  typedef cmp this_type;
endclass
''','dut.sv':'''import p::*;
`include "c.svh"
module top; cmp c; endmodule
'''},'p.sv dut.sv')
add('VO/vo02',L4,{'dut.sv':PK+'''import p::*;
`include "c.svh"
module top; cmp c; endmodule
''','c.svh':'''class cmp;
  typedef cmp this_type;
endclass
'''})
add('VO/vo03',L4,{'p.sv':PK,'dut.sv':'''module m1;
  import p::*;
  class u1; typedef u1 this_type; endclass
  u1 h;
endmodule
module m2;
  import p::*;
  class u1; typedef u1 this_type; int k; endclass
  u1 h;
endmodule
module top; m1 a(); m2 b(); endmodule
'''},'p.sv dut.sv')
add('VO/vo04',L4,{'p.sv':PK,'dut.sv':'''package r;
  import p::*;
  class zz; typedef zz this_type; endclass
endpackage
package q;
  import p::*;
  class yy; typedef yy this_type; endclass
endpackage
module top; q::yy a; r::zz b; endmodule
'''},'p.sv dut.sv')
add('VO/vo05',L4,{'p.sv':PK,'dut.sv':'''import p::*;
class gen #(type T = int);
  typedef gen #(T) this_type;
  T m;
endclass
module top; gen #(byte) g; endmodule
'''},'p.sv dut.sv')
add('VO/vo06',L4,{'p.sv':PK,'dut.sv':'''import p::*;
class cmp;
  typedef int this_type;
endclass
module top; cmp c; endmodule
'''},'p.sv dut.sv')
add('VO/vo07',L4,{'p.sv':PK,'dut.sv':'''import p::lib;
class cmp;
  typedef cmp this_type;
endclass
module top; cmp c; endmodule
'''},'p.sv dut.sv')
add('VO/vo08',L4,{'p.sv':PK,'dut.sv':'''import p::*;
class cmp;
  class nest;
    typedef nest this_type;
  endclass
endclass
module top; cmp c; endmodule
'''},'p.sv dut.sv')
# ---------- L5
add('VT/vt01',L5,{'dut.sv':'''class C #(type T = int, type U = int);
  T m;
endclass
class E; int k; endclass
module top;
  typedef E e_t;
  C #(int, e_t) x;
endmodule
'''})
add('VT/vt02',L5,{'dut.sv':'''package p;
  class E; int k; endclass
  typedef E e_t;
endpackage
import p::*;
class C #(type T = int, type U = int);
  T m;
endclass
class D;
  C #(int, e_t) x;
endclass
module top; D d; endmodule
'''})
add('VT/vt03',L5,{'dut.sv':'''class C #(type T = int, type U = int);
  T m;
endclass
class E; int k; endclass
class D;
  typedef E e_t;
  typedef e_t f_t;
  C #(int, f_t) x;
endclass
module top; D d; endmodule
'''})
add('VT/vt04',L5,{'dut.sv':'''class C #(type T = int, type U = int);
  T m;
endclass
class D;
  typedef C #(byte) cb_t;
  C #(int, cb_t) x;
endclass
module top; D d; endmodule
'''})
add('VT/vt05',L5,{'dut.sv':'''package q;
  class C #(type T = int, type U = int);
    T m;
  endclass
  class D;
    typedef D this_type;
    C #(int, this_type) x;
  endclass
endpackage
module top; q::D d; endmodule
'''})
add('VT/vt06',L5,{'dut.sv':'''class C #(type T = int, type U = int);
  T m;
endclass
class D;
  typedef D this_type;
  function void g();
    C #(int, this_type) loc;
  endfunction
endclass
module top; D d; endmodule
'''})
add('VT/vt07',L5,{'dut.sv':'''class C #(type T = int);
  T m;
endclass
class E; int k; endclass
typedef E e_t;
class D;
  C #(e_t) x;
  C #(e_t) y;
endclass
module top; D d; endmodule
'''})
for n,(law,files,order) in cases.items():
    d=os.path.join(R,n); os.makedirs(d,exist_ok=True)
    for f,t in files.items():
        open(os.path.join(d,f),'w').write('// § '+law+'\n'+t)
    if order: open(os.path.join(d,'FILES'),'w').write(order+'\n')
print(len(cases))
