import os
SHAPES = [
    ("bare",      "",                    "vec"),
    ("logicsc",   "logic",               "sc"),
    ("logicvec",  "logic [7:0]",         "vec"),
    ("wiresc",    "wire",                "sc"),
    ("wirevec",   "wire [7:0]",          "vec"),
    ("pkgvec",    "p77::v8_t",           "vec"),
    ("impvec",    "v8_t",                "vec"),
    ("pkgenum",   "p77::e_t",            "enum"),
    ("impenum",   "e_t",                 "enum"),
    ("pkgstruct", "p77::st_t",           "vec"),
    ("impstruct", "st_t",                "vec"),
    ("unitvec",   "u8_t",                "vec"),
    ("pkgpw",     "p77::pw_t",           "vec"),
    ("pkgmulti",  "p77::m_t",            "vec"),
    ("pkgbit",    "p77::b8_t",           "vec"),
    ("pkgscalar", "p77::s1_t",           "sc"),
    ("varvec",    "var logic [7:0]",     "vec"),
    ("pkgvecdim", "p77::v8_t [1:0]",     "vec"),
    ("regvec",    "reg [7:0]",           "vec"),
    ("varpkgvec", "var p77::v8_t",       "vec"),
]
PKG = """// r10earl77 -- purpose-built PORT-KIND grid: direction x written type shape.
// MEASUREMENT ONLY.  Golden is Surelog; the question is which Nets/Variables
// container each ANSI port's backing object lands in.
package p77;
  typedef logic [7:0]      v8_t;
  typedef logic            s1_t;
  typedef bit   [7:0]      b8_t;
  typedef enum logic [1:0] { E770, E771, E772 } e_t;
  typedef struct packed { logic [3:0] sa; logic [3:0] sb; } st_t;
  typedef logic [1:0][3:0] m_t;
  parameter int W77 = 8;
  typedef logic [W77-1:0]  pw_t;
endpackage

typedef logic [7:0] u8_t;
"""

def leaf(name, drive):
    ports = []
    for sh, decl, _ in SHAPES:
        ports.append("  input  %-18s i_%s," % (decl, sh))
    for sh, decl, _ in SHAPES:
        d = decl
        if d.startswith("wire"):        # an OUTPUT wire is still a net keyword
            pass
        ports.append("  output %-18s o_%s," % (d, sh))
    body = []
    if drive:
        for sh, decl, _ in SHAPES:
            body.append("  assign o_%s = i_%s;" % (sh, sh))
    else:
        body.append("  // no drivers")
    return ("module %s import p77::*; (\n%s\n);\n%s\nendmodule\n"
            % (name, "\n".join(ports).rstrip(","), "\n".join(body)))

def conns(pfx):
    a = []
    for sh, _, _ in SHAPES:
        a.append("    .i_%s(%s_i_%s)" % (sh, pfx, sh))
    for sh, _, _ in SHAPES:
        a.append("    .o_%s(%s_o_%s)" % (sh, pfx, sh))
    return ",\n".join(a)

def wires(pfx):
    a = []
    for sh, _, w in SHAPES:
        t = {"vec": "logic [7:0]", "sc": "logic", "enum": "p77::e_t"}[w]
        a.append("  %s %s_i_%s;" % (t, pfx, sh))
        a.append("  %s %s_o_%s;" % (t, pfx, sh))
    return "\n".join(a)

out = [PKG, leaf("leaf77d", True), leaf("leaf77u", False)]
mid = ["module mid77;"]
for pfx, mod in (("c1", "leaf77d"), ("c2", "leaf77d"), ("c3", "leaf77u")):
    mid.append(wires(pfx))
    mid.append("  %s u_%s (\n%s\n  );" % (mod, pfx, conns(pfx)))
mid.append(wires("cg"))
mid.append("  genvar gi77;")
mid.append("  generate for (gi77 = 0; gi77 < 2; gi77++) begin : gb77")
mid.append("    leaf77d u_gleaf (\n%s\n    );" % conns("cg"))
mid.append("  end endgenerate")
mid.append("endmodule")
out.append("\n".join(mid))
out.append("module top77;\n  mid77 u_mid ();\nendmodule\n")
open("/tmp/r10earl77_probe/arms/g1_portkind77.sv", "w").write("\n".join(out))
print("wrote", sum(1 for _ in open("/tmp/r10earl77_probe/arms/g1_portkind77.sv")), "lines")
