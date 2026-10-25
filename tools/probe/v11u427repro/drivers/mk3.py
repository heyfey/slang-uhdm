import os
R='/tmp/wt_v11u427/tools/probe/v11u427repro/cases'
C={}
E='elabBasedLitLowerBase427'
el=lambda d:"module top(output [15:0] o);\n  %s;\n  assign o = P;\nendmodule\n"%d
C['VE/ve31']=('typedLitElabAdjustLogic427',el("parameter bit [7:0] P = 4'b1010"))
C['VE/ve32']=(E,el("parameter int P = 8'hFF"))
C['VE/ve33']=(E,el("parameter shortint P = 8'sh7"))
C['VE/ve34']=(E,el("parameter int P = 12'shFxF"))
C['VE/ve35']=(E,el("parameter [7:0] P = 8'HAB"))
C['VE/ve36']=(E,el("parameter P = 8'O17"))
C['VE/ve37']=(E,"module sub #(parameter P = 8'HAB) (output [7:0] o);\n  assign o = P;\nendmodule\nmodule top(output [7:0] o, o2);\n  sub u(o);\n  sub u2(o2);\nendmodule\n")
C['VE/ve38']=('typedLitElabAdjustLogic427',el("parameter bit [3:0] P = 8'hAB"))
C['VE/ve39']=(E,el("parameter integer P = 8'HAB"))
X='xzOvLitKeepsText427'
ov=lambda d,a:"module sub #(%s) (output [7:0] o);\n  assign o = P;\nendmodule\nmodule top(output [7:0] o);\n  sub #(.P(%s)) u(o);\nendmodule\n"%(d,a)
C['VX/vx20']=(X,ov("parameter integer P = 0","8'b1x"))
C['VX/vx21']=(X,ov("parameter [7:0] P = 0","4'b1x"))
C['VX/vx22']=(X,"class C #(parameter P = 0);\n  static int v = P;\nendclass\nmodule top(output int o);\n  assign o = C#(4'b1x)::v;\nendmodule\n")
C['VX/vx23']=(X,ov("parameter logic signed [7:0] P = 0","4'b1x"))
P='xzPkgLeafFoldIsRhsCopy427'
C['VP/vp21']=(P,"package p;\n  parameter B = 4'b1x01;\nendpackage\nclass K;\n  int x = p::B;\nendclass\nmodule top(output [3:0] o);\n  assign o = p::B;\nendmodule\n")
C['VP/vp22']=(P,"package p;\n  parameter B = 4'b1x01;\n  parameter C = B;\nendpackage\nmodule top(output [3:0] o);\n  assign o = p::C;\nendmodule\n")
for k,(law,txt) in C.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § %s\n'%law+txt)
