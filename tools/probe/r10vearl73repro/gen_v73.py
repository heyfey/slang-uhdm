#!/usr/bin/env python3
"""r10v73 — adversarial grids for § ovActReduceIntOp73."""
import sys

# ---------------- v1: EVERY operator shape as an override actual ----------
OPS = [
 ('div','A / B'), ('mod','A % B'), ('mul','A * B'), ('sub','A - B'),
 ('add','A + B'), ('shl','A << 1'), ('shr','A >> 1'), ('ashr','A >>> 1'),
 ('ashrn','NEG >>> 1'), ('band','A & B'), ('bor','A | B'), ('bxor','A ^ B'),
 ('bxnor','A ~^ B'), ('eq','A == B'), ('ne','A != B'), ('lt','B < A'),
 ('le','B <= A'), ('gt','A > B'), ('ge','A >= B'), ('land','A && B'),
 ('lor','A || B'), ('ceq','A === B'), ('cne','A !== B'),
 ('pow','2 ** B'), ('unm','-B'), ('unp','+B'), ('unot','!B'), ('ubn','~B'),
 ('ured','&A'), ('uor','|A'), ('uxor','^A'),
 ('tern','(A > B) ? 1 : 2'), ('ternI','(A > B) ? A/B : 4'),
 ('ternE','(A < B) ? 4 : A/B'),
 ('castI',"int'(A / B)"), ('castS',"signed'(A - B)"), ('castU',"unsigned'(A - B)"),
 ('castW',"16'(A / B)"), ('dsgn','$signed(A - B)'), ('duns','$unsigned(A - B)'),
 ('clog','$clog2(A)'), ('clogd','$clog2(A / B)'), ('dbits','$bits(A)'),
 ('conc','{B, B}'), ('repl','{2{B}}'), ('conca','{A/B}'),
 ('lit','128'), ('blit',"8'd128"), ('hlit',"'h80"), ('shlit',"8'sh40"),
 ('refa','A'), ('reflp','WORDS'), ('refpk','vp73::PA'), ('refpkm','vp73::PA / 2'),
 ('enm','E_TWO'), ('enmm','E_TWO * 4'),
 ('nest','(A - B) * (A + B)'), ('deep','((A / B) - 1) * 2 + 1'),
 ('divz','A / 0'), ('big','BIG * BIG'), ('sat','MAXI + MAXI'),
]
V1TYPES = [('int','parameter int P = 7'), ('unt','parameter P = 7'),
           ('b8','parameter bit [7:0] P = 7'), ('lg32','parameter logic [31:0] P = 7'),
           ('sg16','parameter signed [15:0] P = 7'), ('itg','parameter integer P = 7')]

def v1():
    o=[]; w=o.append
    w('// r10v73 v1 — every operator shape as an override actual. MEASUREMENT ONLY.')
    w('package vp73; parameter int PA = 40; endpackage')
    w('typedef enum int { E_ONE = 1, E_TWO = 2 } e73_t;')
    for tn,d in V1TYPES:
        w('module cv1_%s #(%s) (); localparam int U = 1; endmodule' % (tn,d))
    w('module topv1;')
    w('  import vp73::*;')
    w('  parameter int A = 256;')
    w('  parameter int B = 2;')
    w('  parameter int NEG = -8;')
    w('  parameter int BIG = 3037000500;')
    w('  parameter int MAXI = 2147483647;')
    w('  localparam int WORDS = A / B;')
    for tn,_ in V1TYPES:
        for nm,a in OPS:
            w('  cv1_%s #(.P(%s)) u_%s_%s ();' % (tn, a, tn, nm))
    w('endmodule')
    return '\n'.join(o)+'\n'

# ---------------- v2: DECLARATION sites (the 12911 call site) -------------
DECL_OPS = [n for n,_ in OPS if n not in ('divz',)]
def v2():
    o=[]; w=o.append
    w('// r10v73 v2 — NON-OVERRIDDEN declaration initialisers (the decl call site).')
    w('package vp73b; parameter int PA = 40; endpackage')
    w('typedef enum int { F_ONE = 1, F_TWO = 2 } f73_t;')
    w('module topv2;')
    w('  import vp73b::*;')
    w('  parameter int A = 256;')
    w('  parameter int B = 2;')
    w('  parameter int NEG = -8;')
    w('  parameter int BIG = 3037000500;')
    w('  parameter int MAXI = 2147483647;')
    w('  localparam int WORDS = A / B;')
    for nm,a in OPS:
        if nm in ('divz','refpk','refpkm','enm','enmm'): continue
        w('  localparam int L_%s = %s;' % (nm, a))
        w('  parameter  int Q_%s = %s;' % (nm, a))
        w('  localparam bit [15:0] BV_%s = %s;' % (nm, a))
        w('  localparam LU_%s = %s;' % (nm, a))
        w('  localparam integer LI_%s = %s;' % (nm, a))
        w('  localparam int signed LS_%s = %s;' % (nm, a))
    w('  localparam int L_pk = vp73b::PA / 2;')
    w('  localparam int L_en = F_TWO * 4;')
    w('  cv2 #(.W(8)) u ();')
    w('endmodule')
    w('module cv2 #(parameter int W = 4) (); localparam int WW = W * 2; endmodule')
    return '\n'.join(o)+'\n'

# ---------------- v3: declared TYPE matrix ---------------------------------
V3TYPES = []
for wdt in (1,2,3,7,8,9,15,16,17,31,32,33,63,64,65):
    V3TYPES.append(('b%d'%wdt, 'parameter bit [%d:0] P = 3'%(wdt-1)))
    V3TYPES.append(('l%d'%wdt, 'parameter logic [%d:0] P = 3'%(wdt-1)))
    V3TYPES.append(('s%d'%wdt, 'parameter logic signed [%d:0] P = 3'%(wdt-1)))
    V3TYPES.append(('u%d'%wdt, 'parameter [%d:0] P = 3'%(wdt-1)))
for nm,t in (('byte','byte'),('shrt','shortint'),('lng','longint'),
             ('lngu','longint unsigned'),('intu','int unsigned'),
             ('itgu','integer unsigned'),('tdf','t73_t')):
    V3TYPES.append((nm, 'parameter %s P = 3' % t))
V3ACT = [('div','A / B'),('mul','A * B'),('sub','A - B'),('neg','0 - B'),
         ('pow','2 ** B'),('mod','A % B'),('add','A + B'),('addi','A + (B-1)'),
         ('ref','A'),('lit','128'),('ovf','C * C'),('shl','A << 1')]
def v3():
    o=[]; w=o.append
    w('// r10v73 v3 — declared-type matrix x arithmetic actuals. MEASUREMENT ONLY.')
    w('typedef logic [11:0] t73_t;')
    for tn,d in V3TYPES:
        w('module cv3_%s #(%s) (); localparam int U = 1; endmodule' % (tn,d))
    w('module topv3;')
    w('  parameter int A = 256;')
    w('  parameter int B = 2;')
    w('  parameter int C = 100000;')
    for tn,_ in V3TYPES:
        for nm,a in V3ACT:
            w('  cv3_%s #(.P(%s)) u_%s_%s ();' % (tn, a, tn, nm))
    w('endmodule')
    return '\n'.join(o)+'\n'

# ---------------- v4: homes, nesting, defparam, positional, arrays --------
def v4():
    o=[]; w=o.append
    w('// r10v73 v4 — homes / nested overrides / defparam / positional / arrays.')
    w('module leaf4 #(parameter int P = 7, parameter int Q = 9) ();')
    w('  localparam int LP = P * 2;')
    w('endmodule')
    w('module mid4 #(parameter int MP = 5) ();')
    w('  leaf4 #(.P(MP / 2), .Q(MP - 1)) u_l ();')     # nested: parent's override feeds child
    w('  leaf4 #(.P(MP), .Q(MP)) u_l2 ();')
    w('endmodule')
    w('module arr4 #(parameter int AP = 3) (); localparam int X = AP + 1; endmodule')
    w('module topv4;')
    w('  parameter int A = 256;')
    w('  parameter int B = 2;')
    w('  // 1..3 instances of the same module, same and different actuals')
    w('  leaf4 #(.P(A / B)) u_a ();')
    w('  leaf4 #(.P(A / B)) u_b ();')
    w('  leaf4 #(.P(A * B)) u_c ();')
    w('  // nested override: mid4 folds, leaf4 folds again')
    w('  mid4 #(.MP(A / B)) u_m ();')
    w('  mid4 #(.MP(A - B)) u_m2 ();')
    w('  // positional override')
    w('  leaf4 #(A / B, A - B) u_pos ();')
    w('  leaf4 #(A) u_pos1 ();')
    w('  // defparam')
    w('  leaf4 u_dp ();')
    w('  defparam u_dp.P = A / B;')
    w('  defparam u_dp.Q = A * B;')
    w('  // instance ARRAY')
    w('  arr4 #(.AP(A / B)) u_arr [3:0] ();')
    w('  // gen-for home')
    w('  genvar gi;')
    w('  generate for (gi = 0; gi < 2; gi++) begin : g4')
    w('    leaf4 #(.P(A / B + gi)) u_g ();')
    w('    localparam int GL = (A / B) * (gi + 1);')
    w('    if (gi == 0) begin : gi4')
    w('      leaf4 #(.P(A * B)) u_gi ();')
    w('      localparam int GIL = A - B;')
    w('      for (genvar gj = 0; gj < 2; gj++) begin : gj4')
    w('        leaf4 #(.P(A / B - gj)) u_gj ();')
    w('      end')
    w('    end')
    w('  end endgenerate')
    w('  // gen-if home')
    w('  generate if (A > B) begin : gif4')
    w('    leaf4 #(.P(A % B + 5)) u_if ();')
    w('  end else begin : gel4')
    w('    leaf4 #(.P(1)) u_el ();')
    w('  end endgenerate')
    w('endmodule')
    return '\n'.join(o)+'\n'

# ---------------- v5: real / string / enum / struct / typedef -------------
def v5():
    o=[]; w=o.append
    w('// r10v73 v5 — non-integral formals and exotic actuals. MEASUREMENT ONLY.')
    w('package vp73c;')
    w('  parameter int PC = 40;')
    w('  parameter real PR = 2.5;')
    w('  parameter string PS = "hi";')
    w('  typedef enum int { G_ONE = 1, G_TWO = 2 } g73_t;')
    w('endpackage')
    w('typedef struct packed { logic [3:0] a; logic [3:0] b; } st73_t;')
    w('typedef enum int { H_ONE = 1, H_TWO = 2 } h73_t;')
    w('module cv5_real  #(parameter real   P = 1.0) (); localparam int U=1; endmodule')
    w('module cv5_str   #(parameter string P = "x") (); localparam int U=1; endmodule')
    w('module cv5_enum  #(parameter h73_t  P = H_ONE) (); localparam int U=1; endmodule')
    w('module cv5_st    #(parameter st73_t P = 8\'h12) (); localparam int U=1; endmodule')
    w('module cv5_int   #(parameter int    P = 7) (); localparam int U=1; endmodule')
    w('module topv5;')
    w('  import vp73c::*;')
    w('  parameter int A = 256;')
    w('  parameter int B = 2;')
    w('  parameter real R = 5.0;')
    w('  cv5_real #(.P(R / 2.0))   u_rdiv ();')
    w('  cv5_real #(.P(R - 1.0))   u_rsub ();')
    w('  cv5_real #(.P(2.5))       u_rlit ();')
    w('  cv5_str  #(.P("ab"))      u_slit ();')
    w('  cv5_str  #(.P(PS))        u_sref ();')
    w('  cv5_enum #(.P(H_TWO))     u_eref ();')
    w('  cv5_st   #(.P(8\'h34))     u_stl  ();')
    w('  cv5_st   #(.P(A / B))     u_stdiv();')
    w('  cv5_int  #(.P(vp73c::PC / 2)) u_pkg ();')
    w('  cv5_int  #(.P(H_TWO * 4)) u_enm  ();')
    w('  cv5_int  #(.P(int\'(R / 2.0))) u_r2i ();')
    w('  cv5_int  #(.P($rtoi(R / 2.0))) u_rti ();')
    w('  localparam real LR = R / 2.0;')
    w('  localparam string LS = "zz";')
    w('  localparam h73_t LE = H_TWO;')
    w('endmodule')
    return '\n'.join(o)+'\n'

which = sys.argv[1]
sys.stdout.write({'v1':v1,'v2':v2,'v3':v3,'v4':v4,'v5':v5}[which]())
