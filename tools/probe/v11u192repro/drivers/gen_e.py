import os
import os.path as _p; C=_p.join(_p.dirname(_p.abspath(__file__)),'..','cases')+'/E'
hdr="// § genForWholeLhsNestedKeep192v\npackage p;\n  parameter int unsigned W = $clog2(16);\nendpackage\n"
cases={
 'e1_n1_gv':("input logic [31:0] x [1], output logic [31:0] z [1]","  for (genvar i = 0; i < 1; i++) begin : g\n    assign z[i] = {x[i][31:W], {W{1'b0}}};\n  end\n"),
 'e2_n2_nogv_wire':("input logic [31:0] x, output wire [31:0] z","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z = {x[31:W], {W{1'b0}}};\n  end\n"),
 'e3_n2_gv_lhs_only':("input logic [31:0] x, output logic [31:0] z [2]","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[i] = {x[31:W], {W{1'b0}}};\n  end\n"),
 'e4_n2_gv_rhs_other':("input logic [31:0] x, output logic [31:0] z [2]","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[i] = {x[31:W] + i, {W{1'b0}}};\n  end\n"),
 'e5_n2_gv_sel_only':("input logic [31:0] x [2], output logic [31:0] z [2]","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[i] = x[i][31:W];\n  end\n"),
 'e6_n2_nogv_bare':("input logic [31:0] x, output logic [31:0] z [2]","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[i] = x[31:W];\n  end\n"),
 'e7_n2_repl_only':("input logic [31:0] x, output logic [31:0] z [2]","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[i] = {{W{1'b0}}, x[0]};\n  end\n"),
 'e8_n2_repl_gv':("input logic [31:0] x [2], output logic [31:0] z [2]","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[i] = {{W{1'b0}}, x[i][0]};\n  end\n"),
}
for n,(ports,body) in cases.items():
    for top in ('t','c'):
        s=hdr+f"module {'top' if top=='t' else 'leaf'} import p::*; ({ports});\n{body}endmodule\n"
        if top=='c': s+=f"module top ({ports});\n  leaf u (.*);\nendmodule\n"
        d=f"{C}/{n}_{top}"; os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(s)
