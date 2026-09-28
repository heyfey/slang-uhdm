import os
import os.path as _p; C=_p.join(_p.dirname(_p.abspath(__file__)),'..','cases')+'/J'
hdr="// § genForWholeLhsNestedKeep192v\npackage p;\n  parameter int unsigned W = $clog2(16);\nendpackage\n"
cases={
 'j5_implicit_net':"  for (genvar i = 0; i < 2; i++) begin : g\n    assign t = {x[31:W], {W{1'b0}}};\n    assign z[i] = {31'b0, t};\n    assign q[i] = x[W:0];\n  end\n",
 'j6_local_logic':"  for (genvar i = 0; i < 2; i++) begin : g\n    logic [31:0] t;\n    assign t = {x[31:W], {W{1'b0}}};\n    assign z[i] = t;\n    assign q[i] = x[W:0];\n  end\n",
 'j7_local_repl_only':"  for (genvar i = 0; i < 2; i++) begin : g\n    wire [31:0] t;\n    assign t = {{W{1'b0}}, x[0]};\n    assign z[i] = t;\n    assign q[i] = x[W:0];\n  end\n",
 'j8_local_or':"  for (genvar i = 0; i < 2; i++) begin : g\n    wire [31:0] t;\n    assign t = x[W:0] | 32'd1;\n    assign z[i] = t;\n    assign q[i] = x;\n  end\n",
}
for n,body in cases.items():
    for top in ('t','c'):
        ports="input logic [31:0] x, output logic [31:0] z [2], output logic [31:0] q [2]"
        s=hdr+f"module {'top' if top=='t' else 'leaf'} import p::*; ({ports});\n{body}endmodule\n"
        if top=='c': s+=f"module top ({ports});\n  leaf u (.*);\nendmodule\n"
        d=f"{C}/{n}_{top}"; os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(s)
