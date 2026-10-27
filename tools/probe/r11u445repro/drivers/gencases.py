import os,sys
R='/tmp/wt_r11u445/tools/probe/r11u445repro/cases'
L='foreachLoopVarShadowDeclTs445'
C={}
M=lambda body,hdr='module top;': hdr+'\nint arr[4];\n'+body+'\nendmodule\n'
C['SM/sm01']=M('initial begin int i; foreach (arr[i]) arr[i] = i; end')
C['SM/sm02']=M('initial begin : nb int i; foreach (arr[i]) arr[i] = i; end')
C['SM/sm03']=M('parameter int i = 2;\ninitial foreach (arr[i]) arr[i] = i;')
C['SM/sm04']=M('localparam logic [3:0] i = 2;\ninitial foreach (arr[i]) arr[i] = i;')
C['SM/sm05']=M('initial foreach (arr[i]) arr[i] = i;','module top(output int i);')
C['SM/sm06']=M('int s;\ninitial foreach (arr[i]) s = s + i;','module top(input logic [3:0] i);')
C['SM/sm07']=M('input [3:0] i;\nint s;\ninitial foreach (arr[i]) s = s + i;','module top(i);')
C['SM/sm08']=M('wire [3:0] i;\nint s;\ninitial foreach (arr[i]) s = s + i;')
C['SM/sm09']=M('int i;\ninitial foreach (arr[i]) arr[i] = i;')
C['SM/sm10']=M('function automatic void f(int i); foreach (arr[i]) arr[i] = i; endfunction')
C['SM/sm11']=M('function automatic void f(); int i; foreach (arr[i]) arr[i] = i; endfunction')
C['SM/sm12']=M('task automatic t; begin int i; foreach (arr[i]) arr[i] = i; end endtask')
C['SM/sm13']=M('initial fork int i; foreach (arr[i]) arr[i] = i; join')
C['SM/sm14']=M('initial fork : nf int i; foreach (arr[i]) arr[i] = i; join')
C['SM/sm15']=M('initial begin int i; begin foreach (arr[i]) arr[i] = i; end end')
C['SM/sm16']=M('logic [7:0] i;\nint s;\ninitial foreach (arr[i]) s = s + i;')
C['SM/sm17']=M('int b[2]; int s;\ninitial foreach (arr[i]) foreach (b[i]) s = s + i;')
C['SM/sm18']=M('typedef logic [3:0] n_t;\ninitial begin n_t i; foreach (arr[i]) arr[i] = i; end')
C['SM/sm19']=M('genvar i;\ninitial foreach (arr[i]) arr[i] = i;')
C['SM/sm20']=M('if (1) begin : g int i; initial foreach (arr[i]) arr[i] = i; end')
C['SM/sm21']=M('int m[2][3]; int s;\ninitial begin int i; foreach (m[j, i]) s = s + i + j; end')
C['SM/sm22']=M('int s;\nalways @* begin int i; foreach (arr[i]) s = s + i; end')
C['SM/sm23']=M('initial begin byte i; foreach (arr[i]) arr[i] = i; end')
C['SM/sm24']=M('initial begin : outer int i; begin : inner foreach (arr[i]) arr[i] = i; end end')
C['SM/sm25']=M('function automatic void f(); begin int i; foreach (arr[i]) arr[i] = i; end endfunction')
C['SM/sm26']=M('initial begin int i; int j; foreach (arr[j]) arr[j] = j; end')
P=lambda body: 'module top; prg p(); endmodule\nprogram prg;\nint arr[4];\nint s;\n'+body+'\nendprogram\n'
C['SP/sp01']=P('initial begin int i; foreach (arr[i]) s = i; end')
C['SP/sp02']=P('initial begin : nb int i; foreach (arr[i]) s = s + i; end')
C['SP/sp03']=P('int i;\ninitial foreach (arr[i]) s = s + i;')
C['SP/sp04']=P('parameter int i = 1;\ninitial foreach (arr[i]) s = s + i;')
C['SP/sp05']=P('task automatic t; int i; foreach (arr[i]) s = s + i; endtask')
C['SP/sp06']=P('function automatic void f(int i); foreach (arr[i]) s = s + i; endfunction')
C['SP/sp07']=P('initial fork int i; foreach (arr[i]) s = s + i; join')
I=lambda body: 'interface ifc;\nlogic [3:0] sig;\nint s;\n'+body+'\nendinterface\nmodule top; ifc u(); endmodule\n'
C['SI/si01']=I('initial begin int i; foreach (sig[i]) s = s + i; end')
C['SI/si02']=I('int i;\ninitial foreach (sig[i]) s = s + i;')
C['SI/si03']=I('initial begin : nb int i; foreach (sig[i]) s = s + i; end')
C['SI/si04']=I('parameter int i = 1;\ninitial foreach (sig[i]) s = s + i;')
C['SI/si05']=I('function automatic void f(int i); foreach (sig[i]) s = s + i; endfunction')
C['SI/si06']=I('int arr[4];\ninitial begin int i; foreach (arr[i]) s = s + i; end')
C['SU/su01']='module top; endmodule\nprogram prg;\nint arr[4];\nint s;\ninitial begin int i; foreach (arr[i]) s = s + i; end\nendprogram\n'
C['SU/su02']='module top; endmodule\ninterface ifc;\nint arr[4];\nint s;\ninitial begin int i; foreach (arr[i]) s = s + i; end\nendinterface\n'
C['SK/sk01']='package pk;\nfunction automatic int f(); int arr[4]; int s; int i; foreach (arr[i]) s = s + i; return s; endfunction\nendpackage\nmodule top; int x = pk::f(); endmodule\n'
C['SK/sk02']='package pk;\nfunction automatic int f(); int arr[4]; int s; begin int i; foreach (arr[i]) s = s + i; end return s; endfunction\nendpackage\nmodule top; int x = pk::f(); endmodule\n'
C['SK/sk03']='package pk;\nfunction automatic int f(int i); int arr[4]; int s; foreach (arr[i]) s = s + i; return s; endfunction\nendpackage\nmodule top; int x = pk::f(1); endmodule\n'
C['SC/sc01']='class C;\nint arr[4]; int s;\nfunction void f(); begin int i; foreach (arr[i]) s = s + i; end endfunction\nendclass\nmodule top; C c = new; endmodule\n'
C['SG/sg01']=M('if (1) begin : g\n  initial begin int i; foreach (arr[i]) arr[i] = i; end\nend')
C['SG/sg02']=M('for (genvar g = 0; g < 2; g++) begin : gl\n  initial begin int i; foreach (arr[i]) arr[i] = i; end\nend')
C['SG/sg03']='module sub;\nint arr[4];\ninitial begin int i; foreach (arr[i]) arr[i] = i; end\nendmodule\nmodule top; sub u1(); sub u2(); endmodule\n'
for k,v in C.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § '+L+'\n'+v)
print(len(C))
C2={}
C2['SM/sm27']=M('parameter i = 2;\ninitial foreach (arr[i]) arr[i] = i;')
C2['SM/sm28']=M('initial begin localparam int i = 1; foreach (arr[i]) arr[i] = i; end')
C2['SM/sm29']=M('parameter int i = 2;\nfunction automatic void f(); foreach (arr[i]) arr[i] = i; endfunction')
C2['SM/sm30']=M('parameter type i = int;\nint s;\ninitial foreach (arr[k]) s = s + k;\ninitial foreach (arr[i]) s = s + 1;')
C2['SM/sm31']='module sub;\nparameter logic [3:0] i = 2;\nint arr[4];\ninitial foreach (arr[i]) arr[i] = i;\nendmodule\nmodule top; sub u1(); sub #(.i(3)) u2(); endmodule\n'
C2['SM/sm32']=M('parameter int i = 2;\nint s;\ninitial foreach (arr[i]) s = s + arr[i];')
C2['SI/si07']=I('wire [3:0] i;\ninitial foreach (sig[i]) s = s + i;')
C2['SI/si08']=I('logic [7:0] i;\ninitial foreach (sig[i]) s = s + i;')
C2['SI/si09']=I('localparam int i = 1;\ninitial foreach (sig[i]) s = s + i;')
C2['SP/sp08']=P('parameter i = 1;\ninitial foreach (arr[i]) s = s + i;')
C2['SP/sp09']=P('localparam logic [1:0] i = 1;\ninitial foreach (arr[i]) arr[i] = i;')
for k,v in C2.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § '+L+'\n'+v)
print(len(C2))
C3={}
C3['SK/sk04']='package pk;\nint g;\ntask automatic t(); int arr[4]; begin int i; foreach (arr[i]) g = g + i; end endtask\nendpackage\nmodule top; initial pk::t(); endmodule\n'
C3['SK/sk05']='package pk;\nint i;\nfunction automatic int f(); int arr[4]; int s; foreach (arr[i]) s = s + i; return s; endfunction\nendpackage\nmodule top; int x = pk::f(); endmodule\n'
C3['SK/sk06']='package pk;\nclass C; int arr[4]; int s;\nfunction void f(); int i; foreach (arr[i]) s = s + i; endfunction\nendclass\nendpackage\nmodule top; pk::C c = new; endmodule\n'
C3['SK/sk07']='package pk;\nfunction automatic int f(); int arr[4]; int s; begin : nb int i; foreach (arr[i]) s = s + arr[i] + i; end return s; endfunction\nendpackage\nmodule top; int x = pk::f(); endmodule\n'
C3['SK/sk08']='package pk;\nfunction automatic int f(); int arr[4]; int s; foreach (arr[i]) s = s + i; return s; endfunction\nendpackage\nmodule top; int x = pk::f(); endmodule\n'
for k,v in C3.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § '+L+'\n'+v)
C4={}
C4['SM/sm33']=M('int s;\nalways_comb begin int i; s = 0; foreach (arr[i]) s = s + i; end')
C4['SM/sm34']=M('int s;\nfinal begin int i; foreach (arr[i]) s = s + i; end')
C4['SM/sm35']=M('int m[2][3]; int s;\ninitial begin int i; int j; foreach (m[i, j]) s = s + i + j; end')
C4['SM/sm36']=M('class C; int a[4]; int s; function void f(); begin int i; foreach (a[i]) s = s + i; end endfunction endclass\nC c = new;')
C4['SM/sm37']=M('parameter int i = 2;\ninitial begin logic [2:0] i; foreach (arr[i]) arr[i] = i; end')
C4['SM/sm38']=M('localparam int K = 3;\ninitial foreach (arr[K]) arr[K] = K;')
C4['SM/sm39']=M('parameter int i = 2;\nint b[3]; int s;\ninitial foreach (arr[i]) foreach (b[j]) s = s + i + j;')
for k,v in C4.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § '+L+'\n'+v)
C5={}
C5['SW/sw01']='module top;\nparameter int item = 2;\nint q[$]; int s;\ninitial s = q.sum() with (item * 2);\nendmodule\n'
C5['SW/sw02']='package pk;\nfunction automatic int f(); int q[$]; int x; int r[$]; r = q.find(x) with (x > 1); return r.size(); endfunction\nendpackage\nmodule top; int y = pk::f(); endmodule\n'
C5['SW/sw03']='interface ifc;\nint x; int q[$]; int r[$];\ninitial r = q.find(x) with (x > 0);\nendinterface\nmodule top; ifc u(); endmodule\n'
C5['SW/sw04']='module top;\nint arr[4]; int q[$]; int s;\ninitial begin int i; foreach (arr[i]) s = s + q.sum() with (item + i); end\nendmodule\n'
for k,v in C5.items():
    d=os.path.join(R,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write('// § '+L+'\n'+v)
