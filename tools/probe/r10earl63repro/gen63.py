#!/usr/bin/env python3
"""r10earl63 — GRID GENERATOR for the param_assign Rhs ENCODING law.

MEASUREMENT ONLY.  Writes one .sv per (home x family); every cell is one
parameter/localparam whose ELAB param_assign Rhs constant is read back by
pacen63.  Cell name encodes the key:  <home>__<kind>__<type>__<shape>.
"""
import sys, os

FUNCS = """
function automatic integer f_clog(integer value);
  return (value == 1) ? 1 : $clog2(value);
endfunction
function automatic integer f_loop(integer value);
  integer r;
  r = 0;
  for (int i = 0; i < value; i++) r = r + 1;
  return r;
endfunction
function automatic int f_int(int value);
  return value + 1;
endfunction
function automatic int unsigned f_uint(int unsigned value);
  return value + 1;
endfunction
function automatic bit [7:0] f_bit8(int value);
  return value[7:0];
endfunction
function automatic logic [31:0] f_log32(int value);
  return value;
endfunction
function automatic int f_neg(int value);
  return -value;
endfunction
"""

TYPES = [
    ("int",     "int"),
    ("intu",    "int unsigned"),
    ("integer", "integer"),
    ("byte",    "byte"),
    ("shortint","shortint"),
    ("longint", "longint"),
    ("bitp",    "bit"),
    ("bit8",    "bit [7:0]"),
    ("log32",   "logic [31:0]"),
    ("logs32",  "logic signed [31:0]"),
    ("untyped", ""),
    ("rng",     "[31:0]"),
]

CALLS = [
    ("clog",  "f_clog(NBASE)"),
    ("loop",  "f_loop(NB4)"),
    ("fint",  "f_int(NB4)"),
    ("fuint", "f_uint(NB4)"),
    ("fbit8", "f_bit8(NB4)"),
    ("flog32","f_log32(NB4)"),
    ("fneg",  "f_neg(NB4)"),
]

SHAPES = [
    ("dec",   "171"),
    ("hex8",  "8'hab"),
    ("bin8",  "8'b10101011"),
    ("oct8",  "8'o253"),
    ("dec8",  "8'd171"),
    ("cast",  "8'(171)"),
    ("neg",   "-3"),
    ("sdec",  "8'sd3"),
    ("arith", "4+4"),
    ("pmul",  "NBASE*2"),
    ("clogs", "$clog2(300)"),
    ("bits",  "$bits(int)"),
    ("cat",   "{4'ha,4'hb}"),
    ("repl",  "{2{4'ha}}"),
    ("tern",  "(NBASE==16384) ? 8'hab : 8'hcd"),
    ("pref",  "NBASE"),
]

def cells(fam):
    out = []
    src = CALLS if fam == "F" else SHAPES
    for tn, td in TYPES:
        for sn, se in src:
            out.append((tn, td, sn, se))
    return out

def decl(kind, tn, td, sn, se, home):
    nm = "%s_%s_%s_%s" % (home, kind[0], tn, sn)
    t = (" " + td) if td else ""
    return nm, "  %s%s %s = %s;" % (kind, t, nm, se)

def build(home, fam, kind):
    cs = cells(fam)
    lines = []
    if home == "port":
        # parameter port list: parameters first, then the cells
        body = []
        for tn, td, sn, se in cs:
            nm, d = decl(kind, tn, td, sn, se, home)
            body.append("  " + d.strip()[:-1])   # drop trailing ';'
        head = ["module sub_%s_%s_%s #(" % (home, fam, kind[0]),
                "  parameter int NBASE = 512,",
                "  parameter int NB4 = 4,"]
        head += [b + "," for b in body[:-1]] + [body[-1]]
        head += [") (output logic o);", "  assign o = 1'b0;", "endmodule"]
        lines = head
    elif home == "body":
        lines = ["module sub_%s_%s_%s #(parameter int NBASE = 512, parameter int NB4 = 4) (output logic o);" % (home, fam, kind[0])]
        for tn, td, sn, se in cs:
            nm, d = decl(kind, tn, td, sn, se, home)
            lines.append(d)
        lines += ["  assign o = 1'b0;", "endmodule"]
    else:  # genif
        lines = ["module sub_%s_%s_%s #(parameter int NBASE = 512, parameter int NB4 = 4) (output logic o);" % (home, fam, kind[0]),
                 "  if (1) begin : g"]
        for tn, td, sn, se in cs:
            nm, d = decl(kind, tn, td, sn, se, home)
            lines.append("  " + d)
        lines += ["  end", "  assign o = 1'b0;", "endmodule"]
    return "\n".join(lines)

def main():
    outdir = sys.argv[1]
    os.makedirs(outdir, exist_ok=True)
    for home in ("port", "body", "genif"):
        for fam in ("F", "S"):
            kinds = ["localparam"] if home == "port" else ["localparam", "parameter"]
            txt = [FUNCS]
            insts = []
            for kind in kinds:
                txt.append(build(home, fam, kind))
                insts.append("  sub_%s_%s_%s #(.NBASE(16384), .NB4(4)) u_%s (.o(o1_%s));"
                             % (home, fam, kind[0], kind[0], kind[0]))
            txt.append("module top_%s_%s (output logic o1_l, output logic o1_p);" % (home, fam))
            for i in insts:
                txt.append(i)
            if len(kinds) == 1:
                txt.append("  assign o1_p = 1'b0;")
            txt.append("endmodule")
            open(os.path.join(outdir, "g_%s_%s.sv" % (home, fam)), "w").write("\n".join(txt) + "\n")

main()
