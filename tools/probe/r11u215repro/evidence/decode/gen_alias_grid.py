import os,sys
out=sys.argv[1]
PK = {
 'E': ('typedef enum logic [1:0] {A, B} e_t;\n  typedef e_t alias_t;', 'alias_t'),
 'C': ('class gen #(type T=int); T v; endclass\n  typedef gen#(int) g_int_t;\n  typedef gen#(bit) g_bit_t;', 'g_int_t'),
}
USE = {
 'n': '',
 'k': '  class c;\n    function void set({T} v); endfunction\n  endclass',
 'f': '  function automatic void f({T} v); endfunction',
 'v': '  class c;\n    {T} m;\n  endclass',
}
CTX = {
 'x0': 'module m;\nendmodule\n',
 'm1': 'module m;\n  import p::*;\nendmodule\n',
 'i1': 'interface ifc;\n  import p::*;\nendinterface\nmodule m;\n  ifc i();\nendmodule\n',
 'u1': 'import p::*;\nclass env;\n  int q;\nendclass\nmodule m;\nendmodule\n',
 'u2': 'import p::*;\nmodule m;\nendmodule\n',
 'q1': 'package q;\n  import p::*;\nendpackage\nmodule m;\nendmodule\n',
 'q2': 'package q;\n  class d;\n    import p::*;\n  endclass\nendpackage\nmodule m;\nendmodule\n',
 'q3': 'package q;\n  import p::*;\n  class d; int z; endclass\nendpackage\nmodule m;\nendmodule\n',
 'mi': 'interface ifc;\n  import p::*;\nendinterface\nmodule m;\n  import p::*;\n  ifc i();\nendmodule\n',
 'pr': 'program pg;\n  import p::*;\nendprogram\nmodule m;\nendmodule\n',
 'qm': 'package q;\n  import p::*;\nendpackage\nmodule m;\n  import p::*;\nendmodule\n',
}
for pk,(decl,T) in PK.items():
  for u,ut in USE.items():
    for c,ct in CTX.items():
      d=os.path.join(out,f'{pk}{u}_{c}'); os.makedirs(d,exist_ok=True)
      body=ut.replace('{T}',T)
      open(os.path.join(d,'dut.sv'),'w').write(f'package p;\n  {decl}\n{body}\nendpackage\n{ct}')
