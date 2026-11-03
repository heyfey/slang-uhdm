import os
R='/tmp/wt_v11u477/tools/probe/v11u477repro/cases'
def w(g,n,t):
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(t)
L4='// § caAddLeafIntMint477\n'
def mod(body,ports='output logic [7:0] z'):
    return L4+'module top(%s);\n  parameter logic [7:0] P = 8\'d33;\n  parameter logic [7:0] Q = 8\'d5;\n%s\nendmodule\n'%(ports,body)
w('VA','va25',mod("  assign z = -8'd1 + P;"))
w('VA','va26',mod("  assign z = P + (Q - 8'd1);"))
w('VA','va27',mod("  localparam L = P + 8'd1;\n  localparam M = L & 8'hff;\n  logic [L-1:0] y;\n  assign z = M + y[0];"))
w('VA','va28',L4+"module top(output logic [7:0] z [2]);\n  for (genvar i = 0; i < 2; i++) begin : g\n    assign z[i] = i + 8'd1;\n  end\nendmodule\n")
w('VA','va29',mod("  assign z = (P + 8'd1 == 8'd34);"))
w('VA','va30',L4+"package p;\n  parameter logic [7:0] P = 8'h21;\n  function automatic logic [7:0] f(); return P + 8'd1; endfunction\nendpackage\nmodule top(output logic [7:0] z);\n  assign z = p::f();\nendmodule\n")
w('VA','va31',mod("  logic [7:0] n;\n  assign n = 8'd3;\n  assign z = n + 8'd1 + P;"))
w('VA','va32',mod("  localparam int unsigned U = 8'd200 + 8'd100;\n  assign z = U[7:0];"))
