import os
R='/tmp/wt_v11u427/tools/probe/v11u427repro/cases'
C={}
U='elabUnszXzTypedAdjust427'
C['VE/ve23']=(U,"module top(output [15:0] o);\n  parameter logic [7:0] P = 'h1x;\n  wire [15:0] w = P;\n  assign o = w;\nendmodule\n")
C['VE/ve24']=(U,"module top(output logic [15:0] o);\n  parameter logic [7:0] P = 'h1x;\n  always_comb o = P;\nendmodule\n")
C['VE/ve25']=(U,"module top(output [7:0] o);\n  parameter logic [7:0] P = 'h1x;\n  assign o = P;\nendmodule\n")
C['VE/ve26']=(U,"module sub #(parameter logic [7:0] P = 'b1x) (output [7:0] o);\n  assign o = P;\nendmodule\nmodule top(output [7:0] o, o2);\n  sub u(o);\n  sub #(.P(8'h3)) u2(o2);\nendmodule\n")
C['VE/ve27']=('typedLitElabAdjustLogic427',"module top(output [15:0] o);\n  parameter logic [3:0] P = 8'b1010_1010;\n  assign o = P;\nendmodule\n")
C['VE/ve28']=(U,"module top(output [15:0] o);\n  parameter logic [7:0] P = 4'hx;\n  assign o = P;\nendmodule\n")
C['VE/ve29']=(U,"module top(output [15:0] o);\n  parameter logic [7:0] P = 'hx1;\n  assign o = P + 1;\nendmodule\n")
C['VE/ve30']=('typedLitElabAdjustLogic427',"module top(output [15:0] o);\n  parameter bit [15:0] P = 8'hA5;\n  assign o = P;\nendmodule\n")
C['VX/vx17']=('xzOvLitKeepsText427',"module sub #(parameter logic [7:0] P = 0) (output [15:0] o);\n  assign o = P;\nendmodule\nmodule top(output [15:0] o);\n  sub #(.P(4'bz1)) u(o);\nendmodule\n")
C['VX/vx18']=('xzOvLitKeepsText427',"module sub #(parameter P = 0) (output [15:0] o);\n  wire [15:0] w = P;\n  assign o = w;\nendmodule\nmodule top(output [15:0] o);\n  sub #(.P(8'hx3)) u(o);\nendmodule\n")
C['VX/vx19']=('xzOvLitKeepsText427',"interface ifc #(parameter P = 0);\n  logic [7:0] s;\n  assign s = P;\nendinterface\nmodule top;\n  ifc #(.P(4'b1x)) u();\nendmodule\n")
O='oneBitXQuirkTokenOnly427'
C['VO/vo14']=(O,"module top(output o);\n  assign o = 1'Hx;\nendmodule\n")
C['VO/vo15']=(O,"module top(input [1:0] s, output logic o);\n  always_comb case (s) 2'b00: o = 1'ox; default: o = 1'sbX; endcase\nendmodule\n")
C['VO/vo16']=(O,"module top #(parameter logic P = 1'hx) (output o);\n  assign o = P;\nendmodule\n")
X='xzPkgLeafFoldIsRhsCopy427'
C['VP/vp15']=(X,"package p;\n  parameter B = 4'b1x01;\nendpackage\nmodule top(output [3:0] o);\n  if (p::B == 4'b1x01) begin : g\n    assign o = p::B;\n  end\nendmodule\n")
C['VP/vp16']=(X,"package p;\n  parameter B = 4'b1x01;\nendpackage\nmodule a(output [3:0] o);\n  assign o = p::B;\nendmodule\nmodule top(output [3:0] o, o2);\n  a u(o);\n  assign o2 = p::B;\nendmodule\n")
C['VP/vp17']=(X,"package p;\n  parameter logic [3:0] B = 4'b1x;\nendpackage\nmodule top(output [3:0] o);\n  assign o = p::B;\nendmodule\n")
C['VP/vp18']=(X,"package p;\n  parameter B = 8'HxF;\nendpackage\nmodule top(output [7:0] o);\n  assign o = p::B;\nendmodule\n")
C['VP/vp19']=(X,"package p;\n  parameter B = 4'b1x01;\nendpackage\nmodule top(output [7:0] o);\n  assign o = {p::B, p::B};\nendmodule\n")
C['VP/vp20']=(X,"package p;\n  parameter B = 4'b1x01;\nendpackage\nmodule sub #(parameter Q = 0) (output [3:0] o);\n  assign o = Q;\nendmodule\nmodule top(output [3:0] o);\n  sub #(.Q(p::B)) u(o);\nendmodule\n")
S='sgnBinUntypedFreshTsUnsigned427'
C['VS/vs08']=(S,"module top(output [7:0] o);\n  parameter D = 4'sb1010;\n  parameter E = D + 1;\n  assign o = E;\nendmodule\n")
C['VS/vs09']=(S,"package p;\n  parameter D = 4'sb1010;\nendpackage\nmodule top(output [7:0] o);\n  import p::*;\n  assign o = D;\nendmodule\n")
C['VS/vs10']=(S,"module sub #(parameter D = 4'sb1010) (output [7:0] o);\n  assign o = D;\nendmodule\nmodule top(output [7:0] o);\n  sub #(.D(3)) u(o);\nendmodule\n")
for k,(law,txt) in C.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § %s\n'%law+txt)
print(len(C))
