import os
import os.path as _p; C=_p.join(_p.dirname(_p.abspath(__file__)),'..','cases')+'/D'
hdr="// § genForWholeLhsNestedKeep192v\npackage p;\n  parameter int unsigned W = $clog2(16);\nendpackage\n"
bodies={
 'noi':("input logic [31:0] x, output logic [31:0] z","  for (genvar i = 0; i < 1; i++) begin : g\n    assign z = {x[31:W], {W{1'b0}}};\n  end\n"),
 'gi':("input logic [31:0] x [2], output logic [31:0] z [2]","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[i] = {x[i][31:W], {W{1'b0}}};\n  end\n"),
}
for lv in (1,2,3):
  for k,(ports,body) in bodies.items():
    s=hdr+f"module leaf import p::*; ({ports});\n{body}endmodule\n"
    prev='leaf'
    for j in range(1,lv):
        s+=f"module mid{j} ({ports});\n  {prev} u{j} (.*);\nendmodule\n"; prev=f"mid{j}"
    s+=f"module top ({ports});\n  {prev} u0 (.*);\nendmodule\n"
    d=f"{C}/d_lv{lv}_{k}"; os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(s)
