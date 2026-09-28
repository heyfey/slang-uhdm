import os
import os.path as _p; C=_p.join(_p.dirname(_p.abspath(__file__)),'..','cases')+'/N'
hdr="// § genForWholeLhsNestedKeep192v\npackage p;\n  parameter int unsigned W = $clog2(16);\n  typedef struct packed { logic [31:0] f; logic [31:0] g; } s_t;\nendpackage\n"
L={'member':'s.f','concat':'{a, b}','whole':'z'}
R={'cat':"{1'b0, x[W:0]}",'cond':"c ? x[W:0] : 32'd0",'cast':"32'(x[W:0])",'bare':'x[W:0]','repl':"{{W{1'b0}}, x[0]}"}
for ln,l in L.items():
  for rn,r in R.items():
    s=hdr+"module top import p::*; (input logic [31:0] x, input logic c, output logic [31:0] z, output s_t s, output logic [15:0] a, output logic [15:0] b);\n"
    s+=f"  for (genvar i = 0; i < 1; i++) begin : g\n    assign {l} = {r};\n  end\nendmodule\n"
    d=f"{C}/n_{ln}_{rn}"; os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(s)
