#!/usr/bin/env python3
"""v154 adversarial grid: value FACES x BASES x HOMES.
Names deliberately VARIED (not a_t/b_t/c_t over A/B/C) per the ops rules."""
import os, itertools
OUT='/tmp/v154_probe/src'
os.makedirs(OUT, exist_ok=True)

# ---- value faces demanded by the brief -----------------------------------
FACES = {
 'negdec'     : '-1',            # bare negative literal
 'negdec7'    : '-7',
 'negbig'     : '-2147483648',   # exactly INT_MIN magnitude
 'neg33'      : '-4294967296',   # 33-bit value
 'neg64'      : '-999999999999999999',   # 18 digits (gate edge, inside)
 'neg64over'  : '-1000000000000000000',  # 19 digits (gate edge, outside)
 'negzero'    : '-0',
 'neglz'      : '-007',          # LEADING ZEROS
 'negsep'     : '-1_0',          # digit separator
 'negparen'   : '-(1)',
 'negspace'   : '- 1',
 'negneg'     : '-(-2)',
 'unsz'       : "-'d1",          # unsized based negative
 'sized'      : "-32'd3",        # sized based negative
 'sizedsgn'   : "-32'sd3",
 'hexallone'  : "32'hFFFF_FFFF", # sized hex all-ones
 'hexallunsz' : "'hFFFFFFFF",    # unsized hex all-ones
 'submin'     : '1-2',
 'negminus'   : '-1-1',
 'tilde0'     : '~0',
 'param'      : 'KMINUS',        # local parameter = -1
 'pkgparam'   : 'refpkg::QM1',   # package parameter = -1
 'castneg'    : "int'(-1)",      # value written with a cast
 'castneg2'   : "signed'(-1)",
}
# faces needing a wide base (overflow of narrow base handled separately)
BASES = {
 'nobase'  : '',
 'int'     : 'int ',
 'integer' : 'integer ',
 'bit32'   : 'bit [31:0] ',
 'logic8'  : 'logic [7:0] ',
 'byte'    : 'byte ',
 'shortint': 'shortint ',
 'longint' : 'longint ',
 'intuns'  : 'int unsigned ',
 'bituns'  : 'bit unsigned ',
 'tdbase'  : 'wideword_t ',      # typedef'd base
 'narrow'  : 'bit [3:0] ',       # base NARROWER than the value
}
PRE = """package refpkg;
  parameter int QM1 = -1;
  parameter int QP2 = 2;
endpackage
"""
TD = "  typedef bit [31:0] wideword_t;\n"

def pkgfile(tag, base, face):
    return PRE + f"""package hostpkg_{tag};
  import refpkg::*;
{TD}  parameter int KMINUS = -1;
  typedef enum {base}{{ CVR_MARK = {face}, CVR_TAIL = 9 }} coverage_face_t;
  coverage_face_t sig_face;
endpackage
module wrap_{tag};
  import hostpkg_{tag}::*;
  coverage_face_t held;
  initial held = CVR_MARK;
endmodule
"""

n=0
for bt, base in BASES.items():
    for ft, face in FACES.items():
        tag=f'{bt}__{ft}'
        open(f'{OUT}/q1_{tag}.sv','w').write(pkgfile(tag, base, face))
        n+=1
print('grid1 files', n)
