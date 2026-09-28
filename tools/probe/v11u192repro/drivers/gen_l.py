import os
import os.path as _p; C=_p.join(_p.dirname(_p.abspath(__file__)),'..','cases')+'/L'
hdr="// § genForWholeLhsNestedKeep192v\npackage p;\n  parameter int unsigned W = $clog2(16);\nendpackage\n"
cases={
 'l1_lhs_nogv':("input logic [31:0] x, output wire [31:0] z","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[W:0] = x[4:0];\n  end\n"),
 'l2_lhs_gv':("input logic [31:0] x, output logic [31:0] z [2]","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[i][W:0] = x[4:0];\n  end\n"),
 'l3_gv_via_lparam':("input logic [31:0] x, output logic [31:0] z [2]","  for (genvar i = 0; i < 2; i++) begin : g\n    localparam int K = i;\n    assign z[K] = {x[31:W], {W{1'b0}}};\n  end\n"),
 'l4_gv_in_call':("input logic [31:0] x, output wire [31:0] z","  function automatic logic [31:0] f(int a); return a; endfunction\n  for (genvar i = 0; i < 1; i++) begin : g\n    assign z = {x[31:W], {W{1'b0}}} + f(i);\n  end\n"),
 'l5_nogv_one_iter_repl':("input logic [31:0] x, output logic [31:0] z","  for (genvar i = 0; i < 1; i++) begin : g\n    assign z = {{W{1'b0}}, x[0]};\n  end\n"),
 'l6_nogv_one_iter_bare':("input logic [31:0] x, output logic [31:0] z","  for (genvar i = 0; i < 1; i++) begin : g\n    assign z = x[W:0];\n  end\n"),
 'l7_two_assigns_mixed':("input logic [31:0] x, output logic [31:0] z [2], output wire [31:0] v","  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[i] = x[W:0];\n    assign v = x[31:W];\n  end\n"),
}
for n,(ports,body) in cases.items():
    for top in ('t','c'):
        s=hdr+f"module {'top' if top=='t' else 'leaf'} import p::*; ({ports});\n{body}endmodule\n"
        if top=='c': s+=f"module top ({ports});\n  leaf u (.*);\nendmodule\n"
        d=f"{C}/{n}_{top}"; os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(s)
