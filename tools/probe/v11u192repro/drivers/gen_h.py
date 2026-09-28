import os
import os.path as _p; C=_p.join(_p.dirname(_p.abspath(__file__)),'..','cases')+'/H'
hdr="// § genForWholeLhsNestedKeep192v\npackage p;\n  parameter int unsigned W = $clog2(16);\n  typedef struct packed { logic [31:0] f; logic [31:0] g; } s_t;\nendpackage\n"
L={'whole':'z','member':'t.f','idx':'z2[i]'}
R={'hbare':'s.g[W:0]','hcat':"{1'b0, s.g[W:0]}",'hor':"s.g[31:W] | 32'd0",'hparen':'(s.g[W:0])'}
for ln,l in L.items():
  for rn,r in R.items():
    s=hdr+"module top import p::*; (input s_t s, output logic [31:0] z, output s_t t, output logic [31:0] z2 [1]);\n"
    s+=f"  for (genvar i = 0; i < 1; i++) begin : g\n    assign {l} = {r};\n  end\nendmodule\n"
    d=f"{C}/h_{ln}_{rn}"; os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(s)
