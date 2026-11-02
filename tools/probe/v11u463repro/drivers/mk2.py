import os,sys
sys.path.insert(0,'/tmp/v11u463_scr')
exec(open('/tmp/v11u463_scr/mk.py').read().split("cases={}")[0])
def w(n,desc,body):
    d=os.path.join(C,n); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(f'{L} ({desc})\n'+body)
w('VG/vg13','a module-local typedef of the same generic class beside package typedefs',U+'''package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
module top;
  import u::*;
  typedef S #(item) aa_mod_seqr;
  aa_mod_seqr h;
endmodule
''')
w('VG/vg14','a $unit typedef of the same generic class after the packages',U+'''package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
import u::*;
class ui extends item; endclass
typedef S #(ui) zz_unit_seqr;
module top;
endmodule
''')
w('VG/vg15','a typedef of a typedef named after the base in the declaring package',U+'''package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; typedef a_seqr z2_seqr; endpackage
module top;
endmodule
''')
w('VG/vg16','a $unit typedef of an unrelated generic class beside the group',U+'''package u3; class T #(type X = int); X x; endclass endpackage
import u3::*;
typedef T #(int) aa_other;
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
module top;
endmodule
''')
w('VG/vg17','a typedef of a typedef in the earlier package',U+'''package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; typedef b_seqr b2_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
module top;
endmodule
''')
