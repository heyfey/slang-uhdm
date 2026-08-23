KINDS = [
 ("LIT",  "parameter  int LIT  = 20;"),
 ("XREF", "parameter  int XREF = pz_earl71::ZA;"),
 ("CLGL", "parameter  int CLGL = $clog2(16);"),
 ("DIVP", "parameter  int DIVP = pz_earl71::ZW / pz_earl71::ZB;"),
 ("CLGP", "parameter  int CLGP = $clog2(DIVP);"),
 ("TERN", "parameter  int TERN = DIVP == 1 ? 1 : CLGP;"),
 ("SUBP", "parameter  int SUBP = XREF - CLGP;"),
 ("LLIT", "localparam int LLIT = 20;"),
 ("LCLG", "localparam int LCLG = $clog2(16);"),
]
out = []
w = out.append
w("// r10earl71 arm d1 — MEASUREMENT ONLY.  ONE axis: the RHS SHAPE of the")
w("// imported package parameter named in a port-actual select bound.")
w("package pz_earl71;")
w("  parameter int ZW = 64;")
w("  parameter int ZB = 32;")
w("  parameter int ZA = 10;")
w("endpackage")
w("")
w("package pp_earl71;")
for n, d in KINDS:
    w("  " + d)
w("endpackage")
w("")
w("module lf71 (")
w("  input [31:0] p0, input [31:0] p1, input [31:0] p2, input p3,")
w("  input [31:0] p4, input [31:0] p5, input [31:0] p6, input [31:0] p7);")
w("endmodule")
w("")
w("module m1_earl71 import pp_earl71::*; (")
w("  input [31:0] sig, output logic [31:0] o0);")
def body(k, inst, ind):
    s = []
    s.append(ind+"lf71 %s (" % inst)
    s.append(ind+"    .p0(sig[%s+2:1])," % k)
    s.append(ind+"    .p1(sig[0 +: %s])," % k)
    s.append(ind+"    .p2(sig[%s +: 4])," % k)
    s.append(ind+"    .p3(sig[%s])," % k)
    s.append(ind+"    .p4(sig[%s+1:0])," % k)
    s.append(ind+"    .p5(sig[31:%s])," % k)
    s.append(ind+"    .p6(%s)," % k)
    s.append(ind+"    .p7(sig[LIT+2:%s])" % k)
    s.append(ind+");")
    return s
for k, _ in KINDS:
    w("  // ---- %s : module-body home" % k)
    out.extend(body(k, "i_mod_%s" % k, "  "))
    w("  logic [31:0] c_%s; assign c_%s = sig[31:%s];" % (k, k, k))
for k, _ in KINDS:
    w("  for (genvar g_%s = 0; g_%s < 2; g_%s++) begin: gf_%s" % (k,k,k,k))
    out.extend(body(k, "i_gen_%s" % k, "    "))
    w("    logic [31:0] t_%s; assign t_%s = sig[31:%s];" % (k, k, k))
    w("  end")
w("  assign o0 = sig;")
w("endmodule")
w("")
w("module top_earl71 (input [31:0] sig, output logic [31:0] o0);")
w("  m1_earl71 i_m1 (.sig(sig), .o0(o0));")
w("endmodule")
open("/tmp/r10earl71_s/d1_earl71.sv","w").write("\n".join(out)+"\n")
print(len(out))
