import os
ops={'add':'a + N','addr':'N + a','sub':'a - N','mul':'a * N','shl':'a << N','and':'a & N','or':'a | N','neg':'~N','umin':'-N','gt':'(a > N)','eq':'(a == N)','tern':'(N > 2) ? a : 0','addsub':'a + N - 1','muladd':'a * N + 1','addmul':'(a + N) * 2','xor':'a ^ N','div':'a / N','ret_add':None,'ret_mul':None}
kinds={
 'mp':('module m #(parameter int N = 3) (output logic [31:0] o);','',''),
 'mu':('module m #(parameter N = 3) (output logic [31:0] o);','',''),
 'lp':('module m(output logic [31:0] o);\n  localparam int N = 3;','',''),
 'pq':('module m(output logic [31:0] o);','package p; parameter int N = 3; endpackage\n','p::'),
 'im':('module m import p::*; (output logic [31:0] o);','package p; parameter int N = 3; endpackage\n',''),
}
for k,(hdr,pre,q) in kinds.items():
  for o,e in ops.items():
    d=f'c/{k}_{o}'; os.makedirs(d,exist_ok=True)
    if o=='ret_add': body=f'return a + {q}N;'
    elif o=='ret_mul': body=f'return a * {q}N;'
    else: body=f'int r; r = {e.replace("N",q+"N")}; return r;'
    open(d+'/dut.sv','w').write(f'// § evalFuncUnreducedOperandKeepsCall287\n{pre}{hdr}\n  function automatic int f(int a); {body} endfunction\n  assign o = f(5);\nendmodule\n')
