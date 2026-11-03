import os
R='/tmp/wt_v11u468/tools/probe/v11u468repro/cases'
L2='specArgPairsImportedFormal468'; L4='oobClassTdImporterClass468'
PK=open('/tmp/wt_v11u468/tools/probe/v11u468repro/drivers/mkcases.py').read().split("PK='''")[1].split("'''")[0]
P='''package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
  function int f(); return 1; endfunction
endpackage
'''
cases={}
def add(n,law,files,order=None): cases[n]=(law,files,order)
add('VO/vo09',L4,{'p.sv':PK,'dut.sv':'''import p::*;
class cmp;
  typedef int this_type;
endclass
class cmp2;
  typedef cmp2 this_type;
endclass
module top; cmp c; cmp2 d; endmodule
'''},'p.sv dut.sv')
add('VO/vo10',L4,{'p.sv':PK,'dut.sv':'''import p::*;
class cmp;
  typedef struct { int a; } this_type;
endclass
module top; cmp c; endmodule
'''},'p.sv dut.sv')
add('VO/vo11',L4,{'p.sv':PK,'dut.sv':'''import p::*;
class cmp;
  typedef p::aa this_type;
endclass
module top; cmp c; endmodule
'''},'p.sv dut.sv')
add('VO/vo12',L4,{'p.sv':PK,'dut.sv':'''import p::*;
class cmp;
  typedef enum { A, B } this_type;
endclass
module top; cmp c; endmodule
'''},'p.sv dut.sv')
add('VO/vo13',L4,{'p.sv':PK,'dut.sv':'''import p::*;
class cmp2;
  typedef cmp2 this_type;
endclass
class cmp;
  typedef int this_type;
endclass
module top; cmp c; cmp2 d; endmodule
'''},'p.sv dut.sv')
add('VO/vo14',L4,{'p.sv':PK,'dut.sv':'''import p::*;
class base; int k; endclass
class cmp;
  typedef base this_type;
endclass
module top; cmp c; endmodule
'''},'p.sv dut.sv')
add('VS/vs13',L2,{'dut.sv':P+'''import p::*;
class item; int d; endclass
class C #(int W = 1, type T = item);
  T m;
endclass
class env;
  C #(4, item) comp;
endclass
module top; env e; endmodule
'''})
add('VS/vs14',L2,{'dut.sv':P+'''module top;
  import p::*;
  class item; int d; endclass
  class C #(type T = item);
    T m;
  endclass
  class env;
    C #(item) comp;
  endclass
  env e;
endmodule
'''})
add('VS/vs15',L2,{'dut.sv':P+'''import p::*;
import p::PA;
class item; int d; endclass
class C #(type T = item, type U = item);
  T m;
endclass
class env;
  C #(item, byte) comp;
endclass
module top; env e; endmodule
'''})
for n,(law,files,order) in cases.items():
    d=os.path.join(R,n); os.makedirs(d,exist_ok=True)
    for f,t in files.items():
        open(os.path.join(d,f),'w').write('// § '+law+'\n'+t)
    if order: open(os.path.join(d,'FILES'),'w').write(order+'\n')
print(len(cases))
