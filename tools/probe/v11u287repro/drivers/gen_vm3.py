import os
def w(d,s):
    os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(s)
H='// § evalFuncKeepOwnParamAddCmp287v\n'
ops={'mulpar1':'a * (N + 1)','nplus1':'N + 1','caseeq':'(a === N)','logand':'(a && N)','ltplus':'(a < N + 1)','subl':'N - a','paramsel':'a + N[1:0]','addcast':"a + int'(N)",'gecmp':'(a >= N)','nplusn':'N + N'}
for o,e in ops.items():
    w(f'c3/ml_{o}', f'{H}module m #(parameter int N = 3) (output logic [31:0] o);\n  function automatic int f(int a); int r; r = {e}; return r; endfunction\n  assign o = f(5);\nendmodule\n')
    w(f'c3/pk_{o}', f'{H}package p; parameter int N = 3;\n  function automatic int f(int a); int r; r = {e}; return r; endfunction\nendpackage\nmodule m(output logic [31:0] o); assign o = p::f(5); endmodule\n')
w('c3/ml_while', f'{H}module m #(parameter int N = 3) (output logic [31:0] o);\n  function automatic int f(int a); int i; i = 0; while (i < N) i++; return i + a; endfunction\n  assign o = f(5);\nendmodule\n')
w('c3/pk_lp', f'{H}package p; localparam int N = 3;\n  function automatic int f(int a); int r; r = a + N; return r; endfunction\nendpackage\nmodule m(output logic [31:0] o); assign o = p::f(5); endmodule\n')
w('c3/if_iface', f'{H}interface ifc #(parameter int N = 3); logic [31:0] o;\n  function automatic int f(int a); int r; r = a * N; return r; endfunction\n  assign o = f(5);\nendinterface\nmodule m(output logic [31:0] y); ifc u(); assign y = u.o; endmodule\n')
w('c3/ml_genscope_mul', f'{H}module m #(parameter int N = 3) (output logic [31:0] o [2]);\n  function automatic int f(int a); int r; r = a * N; return r; endfunction\n  for (genvar i = 0; i < 2; i++) begin : g assign o[i] = f(i); end\nendmodule\n')
w('c3/ml_pkgcmp_in_mod', f'{H}package q; parameter int W = 3; endpackage\nmodule m #(parameter int N = 3) (output logic [31:0] o);\n  function automatic int f(int a); int r; r = (a > q::W) ? N : 0; return r; endfunction\n  assign o = f(5);\nendmodule\n')
