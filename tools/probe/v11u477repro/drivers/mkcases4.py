import os
R='/tmp/wt_v11u477/tools/probe/v11u477repro/cases'
def w(g,n,t):
    d=os.path.join(R,g,n); os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(t)
L4='// § caAddLeafIntMint477\n'
def mod(body,ports='output logic [7:0] z'):
    return L4+'module top(%s);\n  parameter logic [7:0] P = 8\'d33;\n%s\nendmodule\n'%(ports,body)
w('VA','va33',mod("  localparam logic [7:0] L = P + 8'd1;\n  localparam logic [7:0] M = L & 8'hff;\n  assign z = M;"))
w('VA','va34',mod("  localparam logic [7:0] L = P + 8'd1;\n  assign z = L & 8'hff;"))
w('VA','va35',mod("  localparam logic [7:0] L = P + 8'd1;\n  assign z = L;"))
w('VA','va36',mod("  localparam logic [7:0] L = P + 8'd1;\n  logic [L:0] y;\n  assign z = y[7:0];"))
w('VA','va37',mod("  localparam logic [7:0] L = P + 8'd1;\n  localparam logic [7:0] M = L | 8'h0;\n  localparam logic [7:0] N = L + 8'h1;\n  assign z = M ^ N;"))
