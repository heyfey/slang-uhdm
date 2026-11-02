import os
C='/tmp/wt_v11u463/tools/probe/v11u463repro/cases'
L='// § firstListerNamesClassTd463'
U='''package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
'''
cases={}
def w(n,desc,body):
    d=os.path.join(C,n); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(f'{L} ({desc})\n'+body)
w('VG/vg01','non-parameterized class typedef in two packages, later package first',U+'''package b;
  import u::*;
  typedef C b_ct;
endpackage
package a;
  import u::*;
  typedef C a_ct;
endpackage
module top;
endmodule
''')
w('VG/vg02',"the same specialization S#(int) typedef'd in b then a",U+'''package b;
  import u::*;
  typedef S #(int) b_si;
endpackage
package a;
  import u::*;
  typedef S #(int) a_si;
endpackage
module top;
endmodule
''')
w('VG/vg03',"an earlier package lists a late-named typedef of the same class first",U+'''package u2;
  import u::*;
  typedef S #(item) z_dflt;
endpackage
package b;
  import u::*;
  class b_item extends item; endclass
  typedef S #(b_item) b_seqr;
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
module top;
endmodule
''')
w('VG/vg04','four packages d c b a',U+'''package d; import u::*; class d_item extends item; endclass typedef S #(d_item) d_seqr; endpackage
package c; import u::*; class c_item extends item; endclass typedef S #(c_item) c_seqr; endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
module top;
endmodule
''')
w('VG/vg05','generic class in package a itself, typedef in a and in later b (control)','''package a;
  class item; endclass
  class S #(type REQ = item); REQ r; endclass
  class a_item extends item; endclass
  typedef S #(a_item) z_seqr;
endpackage
package b;
  import a::*;
  class b_item extends item; endclass
  typedef S #(b_item) b_seqr;
endpackage
module top;
endmodule
''')
w('VG/vg06','a $unit typedef of the same generic class beside package typedefs',U+'''import u::*;
class ui extends item; endclass
typedef S #(ui) aa_unit_seqr;
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
module top;
endmodule
''')
w('VG/vg07','a class-nested typedef of the generic class in the later-declared package',U+'''package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass
  class K; typedef S #(a_item) a_seqr; a_seqr h; endclass
  typedef S #(a_item) a_top;
endpackage
module top;
endmodule
''')
w('VG/vg08','module and class variables typed by the renamed typedef, through import',U+'''package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr;
  class env; a_seqr s; b::b_seqr t; endclass
endpackage
module top;
  import a::*;
  a_seqr m;
  env e;
  initial begin m = new; e = new; end
endmodule
''')
w('VG/vg09','value-parameter class specializations','''package u; class V #(int N = 1); bit [N-1:0] x; endclass endpackage
package b; import u::*; typedef V #(4) b_v; endpackage
package a; import u::*; typedef V #(8) a_v; endpackage
module top;
endmodule
''')
w('VG/vg10','a typedef of a typedef in the declaring package',U+'''package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; typedef a_seqr a2_seqr; endpackage
module top;
endmodule
''')
w('VG/vg11',"a later package names an earlier package's typedef by scope",U+'''package a; import u::*; class a_item extends item; endclass typedef S #(a_item) z_seqr; endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; a::z_seqr h; endpackage
module top;
endmodule
''')
w('VG/vg12','two generic classes, interleaved groups','''package u; class item; endclass
  class S #(type REQ = item); REQ r; endclass
  class D #(type REQ = item); REQ r; endclass
endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; typedef D #(b_item) b_drv; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; typedef D #(a_item) a_drv; endpackage
module top;
endmodule
''')
w('VE/ve01','explicit import and export of a class typedef, later package',U+'''package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
package b; import a::a_seqr; export a::a_seqr; endpackage
module top; import b::*; a_seqr x; initial x = new; endmodule
''')
w('VE/ve02','wildcard import and export of a class typedef, later package also specializes',U+'''package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
package b; import u::*; import a::*; export a::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; a_seqr h; endpackage
module top; import b::*; a_seqr x; initial x = new; endmodule
''')
w('VE/ve03','a non-generic class typedef re-exported','''package a; class K; int v; endclass typedef K kt; endpackage
package b; import a::*; export a::kt; kt h; endpackage
module top; import b::*; kt x; initial x = new; endmodule
''')
w('VE/ve04',"a parameter type defaulting to another package's class typedef",U+'''package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; parameter type PT = a::a_seqr; endpackage
module top; b::PT x; initial x = new; endmodule
''')
w('VU/vu01','a module and an interface both use the group from imports',U+'''package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
interface ifc; import a::*; a_seqr q; endinterface
module top; import b::*; import a::*; b_seqr x; a_seqr y; ifc i(); endmodule
''')
w('VU/vu02','a program importing the declaring package',U+'''package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
program prg; import a::*; a_seqr y; initial y = new; endprogram
module top; endmodule
''')
w('VU/vu03','a function return typed by the renamed typedef',U+'''package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr;
  function automatic a_seqr mk(); mk = new; endfunction
endpackage
module top; import a::*; a_seqr y; initial y = mk(); endmodule
''')
