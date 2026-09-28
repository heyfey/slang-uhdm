import os
import os.path as _p; C=_p.join(_p.dirname(_p.abspath(__file__)),'..','cases')+'/J'
hdr="// § genForWholeLhsNestedKeep192v\npackage p;\n  parameter int unsigned W = $clog2(16);\nendpackage\n"
cases={
 'j1_for_in_if':"  if (W > 1) begin : gi\n    for (genvar i = 0; i < 2; i++) begin : g\n      assign z[i] = {x[31:W], {W{1'b0}}};\n      assign q[i] = x[W:0];\n    end\n  end\n",
 'j2_if_in_for':"  for (genvar i = 0; i < 2; i++) begin : g\n    if (W > 1) begin : gi\n      assign z[i] = {x[31:W], {W{1'b0}}};\n      assign q[i] = x[W:0];\n    end\n  end\n",
 'j3_named_blk_in_for':"  for (genvar i = 0; i < 2; i++) begin : g\n    begin : nb\n      assign z[i] = {x[31:W], {W{1'b0}}};\n    end\n    assign q[i] = x[W:0];\n  end\n",
 'j4_for_cat_whole_lhs_net':"  wire [31:0] zz [2];\n  for (genvar i = 0; i < 2; i++) begin : g\n    wire [31:0] t;\n    assign t = {x[31:W], {W{1'b0}}};\n    assign zz[i] = t;\n    assign z[i] = zz[i];\n    assign q[i] = x[W:0];\n  end\n",
}
for n,body in cases.items():
    for top in ('t','c'):
        ports="input logic [31:0] x, output logic [31:0] z [2], output logic [31:0] q [2]"
        s=hdr+f"module {'top' if top=='t' else 'leaf'} import p::*; ({ports});\n{body}endmodule\n"
        if top=='c': s+=f"module top ({ports});\n  leaf u (.*);\nendmodule\n"
        d=f"{C}/{n}_{top}"; os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(s)
