import os
R='/tmp/wt_v11u478/tools/probe/v11u478repro/cases/VQ'
base=open('/tmp/wt_v11u478/tools/probe/r11u478repro/cases/AP/ap03/dut.sv').read()
L='// § aliasCopyParamUnnamed478'
def mk(name, note, s):
    s=s.replace('// § aliasCopyParamUnnamed478 (no imported package parameter)', f'{L} ({note})')
    os.makedirs(f'{R}/{name}',exist_ok=True); open(f'{R}/{name}/dut.sv','w').write(s)
mk('vq09','one class-scoped argument',base.replace('typedef A #(K::w, K::v) A_t;','typedef A #(K::w) A_t;'))
mk('vq10','a class-scoped and a literal argument',base.replace('typedef A #(K::w, K::v) A_t;','typedef A #(K::w, 7) A_t;'))
mk('vq11','the user class in the typedef package',base.replace('  typedef A #(K::w, K::v) A_t;\n','  typedef A #(K::w, K::v) A_t;\n  class E2; A_t h2; endclass\n'))
mk('vq12','a module variable of the typedef',base.replace('module top;\n  import c::*;\nendmodule','module top;\n  import b::*;\n  A_t mh;\nendmodule'))
mk('vq13','two user packages',base.replace('module top;','package d;\n  import a::*;\n  import b::*;\n  class F; A_t q; endclass\nendpackage\nmodule top;\n  import d::*;'))
mk('vq14','typed value parameters',base.replace('class A #(int W = 1, int V = 2);','class A #(int unsigned W = 1, bit [7:0] V = 2);'))
mk('vq15','named this_t arguments',base.replace('typedef A #(W, V) this_t;','typedef A #(.W(W), .V(V)) this_t;'))
mk('vq16','no registry typedef',base.replace('    typedef R #(this_t) type_id;\n    int x;\n  endclass\n  class B','    int x;\n  endclass\n  class B',1))
mk('vq17','a typedef of the typedef',base.replace('  typedef A #(K::w, K::v) A_t;\n','  typedef A #(K::w, K::v) A_t;\n  typedef A_t A2_t;\n').replace('    A_t h;','    A2_t h;'))
mk('vq18','a class-scoped argument named like the formal',base.replace('localparam w = 16;','localparam W = 16;').replace('K::w, K::v','K::W, K::v'))
