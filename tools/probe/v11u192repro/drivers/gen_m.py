import os
import os.path as _p; C=_p.join(_p.dirname(_p.abspath(__file__)),'..','cases')+'/M'
hdr="// § genForWholeLhsNestedKeep192v\npackage p;\n  parameter int unsigned W = $clog2(16);\nendpackage\n"
L={'whole':'z','cidx':'z2[0]','gidx':'z2[i]','psel':'z[15:0]'}
R={'bare':'x[W:0]','cat':"{1'b0, x[W:0]}",'repl':"{{W{1'b0}}, x[0]}",'or':"x[W:0] | 32'd0",'cat2':"{x[31:W], 1'b0}"}
for ln,l in L.items():
  for rn,r in R.items():
    s=hdr+"module top import p::*; (input logic [31:0] x, output logic [31:0] z, output logic [31:0] z2 [1]);\n"
    s+=f"  for (genvar i = 0; i < 1; i++) begin : g\n    assign {l} = {r};\n  end\nendmodule\n"
    d=f"{C}/m_{ln}_{rn}"; os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(s)
