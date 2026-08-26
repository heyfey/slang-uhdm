import os
OUT='/tmp/v154_probe/src'
for bt,b in {'nobase':'','int':'int ','integer':'integer ','longint':'longint ','shortint':'shortint ','bit32':'bit [31:0] '}.items():
    for ft,f in {'negdec':'-1','negzero':'-0','sized':"-32'd3",'plus':'3'}.items():
        open(f'{OUT}/q6_succ__{bt}__{ft}.sv','w').write(f"""package sucpkg_{bt}_{ft};
  typedef enum {b}{{ SUC_HEAD = {f}, SUC_NEXT, SUC_TAILEND }} suc_face_t;
  suc_face_t sig;
endpackage
module dut_suc_{bt}_{ft}; import sucpkg_{bt}_{ft}::*; suc_face_t z; initial z = SUC_HEAD; endmodule
""")
print('ok')
