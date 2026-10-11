import os
ops={'add':'a + N','addr':'N + a','sub':'a - N','mul':'a * N','shl':'a << N','and':'a & N','or':'a | N','neg':'~N','umin':'-N','gt':'(a > N)','eq':'(a == N)','tern':'(N > 2) ? a : 0','addsub':'a + N - 1','muladd':'a * N + 1','addmul':'(a + N) * 2','xor':'a ^ N','div':'a / N','lit_add':'a + 3','lit_xor':'a ^ 3','ne':'(a != N)','le':'(a <= N)','addneg':'a + (-N)','addpar':'a + (N)'}
def w(d,s):
    os.makedirs(d,exist_ok=True); open(d+'/dut.sv','w').write(s)
for o,e in ops.items():
    w(f'c2/pk_{o}', f'// § evalFuncUnreducedOperandKeepsCall287\npackage p; parameter int N = 3;\n  function automatic int f(int a); int r; r = {e}; return r; endfunction\nendpackage\nmodule m(output logic [31:0] o); assign o = p::f(5); endmodule\n')
    w(f'c2/pr_{o}', f'// § evalFuncUnreducedOperandKeepsCall287\npackage p; parameter int N = 3;\n  function automatic int f(int a); return {e}; endfunction\nendpackage\nmodule m(output logic [31:0] o); assign o = p::f(5); endmodule\n')
    w(f'c2/mi_{o}', f'// § evalFuncUnreducedOperandKeepsCall287\nmodule m #(parameter int N = 3) (output logic [31:0] o);\n  function automatic int f(int a); int r; r = 0; if ({e}) r = 1; return r; endfunction\n  assign o = f(5);\nendmodule\n')
    w(f'c2/ml_{o}', f'// § evalFuncUnreducedOperandKeepsCall287\nmodule m #(parameter int N = 3) (output logic [31:0] o);\n  function automatic int f(int a); int r; r = {e}; return r; endfunction\n  assign o = f(5);\nendmodule\n')
