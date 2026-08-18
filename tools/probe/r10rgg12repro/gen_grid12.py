#!/usr/bin/env python3
"""r10rgg12/gen_grid12.py -- THE GRID this pass's law is stated on.

  usage: gen_grid12.py <outdir> [A|B]

GRID A -- the DISCRIMINATOR grid: what makes golden keep a packed range bound
SYMBOLIC instead of folding it.  A module declares
    localparam <T> P = <INIT>;
    <DECL> [P-1:0] v;
and is instantiated TWICE with different parameters under `top`, so every cell
answers the per-instance question as well.  12 INITIALIZER shapes x 2 HOMES
(module body / generate-if block) x 2 DECLARATIONS (variable / net).

GRID B -- the REACH grid: the same twelve initializers on one home, read from
every declaration position a range bound can sit in (variable, net, port,
unpacked dimension, parameter typespec, function-local), so the boundary of
what the fix may touch is measured rather than assumed.

Every cell is a SINGLE FILE with a `top`, so `cell12.sh` can run it in the
DEFAULT mode both corpora use (`surelog -parse <src>` / `slang <src>
--single-unit`).
"""
import os, sys

# ---------------------------------------------------------------- initializers
# Each entry: (tag, extra declarations placed in the module BEFORE the
# localparam, the localparam's own type, the initializer expression).
FUNCS = {
 'f_plain': """  function automatic int f_plain(int n);
    return 4;
  endfunction
""",
 'f_for': """  function automatic int f_for(int n);
    int acc;
    acc = 0;
    for (int i = 0;i < 4;++i) acc = acc + 1;
    return acc;
  endfunction
""",
 'f_ifelse': """  function automatic int f_ifelse(int n);
    int acc;
    acc = 0;
    for (int i = 0;i < 4;++i) begin
      if (i == 0) acc = acc + 2;
      else        acc = acc + 1;
    end
    return acc;
  endfunction
""",
 'f_terneq': """  function automatic int f_terneq(bit [3:0][15:0] a);
    int acc;
    acc = 0;
    for (int i = 0;i < 4;++i) acc += ((a[i] != 0) ? 1 : 0);
    return acc;
  endfunction
""",
 'f_p2d': """  function automatic int f_p2d(bit [3:0][15:0] a);
    return 3;
  endfunction
""",
 'f_nest': """  function automatic int f_inner(int n);
    return n + 1;
  endfunction
  function automatic int f_nest(int n);
    return f_inner(n) + 1;
  endfunction
""",
 'f_while': """  function automatic bit [3:0][15:0] f_while(int n);
    bit [3:0][15:0] list;
    int idx;
    bit [15:0] cur;
    list = '0;
    idx  = 0;
    cur  = 16'(n);
    while (cur > 0) begin
      if (cur >= 4) list[idx] = 4;
      else          list[idx] = cur;
      cur -= list[idx];
      idx += 1;
    end
    return list;
  endfunction
""",
 'f_sel': """  function automatic int f_sel(int n);
    int arr[4];
    for (int i = 0;i < 4;++i) arr[i] = i;
    return arr[2];
  endfunction
""",
}

INITS = [
 ('lit',      '',                       'int', '5'),
 ('arith',    '',                       'int', 'BASE + 2'),
 ('clog2',    '',                       'int', '$clog2(N)'),
 ('f_plain',  FUNCS['f_plain'],         'int', 'f_plain(N)'),
 ('f_for',    FUNCS['f_for'],           'int', 'f_for(N)'),
 ('f_ifelse', FUNCS['f_ifelse'],        'int', 'f_ifelse(N)'),
 ('f_terneq', FUNCS['f_terneq'],        'int', 'f_terneq(SUBL)'),
 ('f_p2d',    FUNCS['f_p2d'],           'int', 'f_p2d(SUBL)'),
 ('f_nest',   FUNCS['f_nest'],          'int', 'f_nest(N)'),
 ('f_while',  FUNCS['f_while'],         'bit [3:0][15:0]', 'f_while(N)'),
 ('f_sel',    FUNCS['f_sel'],           'int', 'f_sel(N)'),
 ('pkgfn',    '',                       'int', 'gp::pf(N)'),
]

PKG = """package gp;
  function automatic int pf(int n);
    int acc;
    acc = 0;
    for (int i = 0;i < 4;++i) acc += ((i != 0) ? 1 : 0);
    return acc;
  endfunction
endpackage
"""

# f_terneq / f_p2d take the packed-2D list, which itself comes from a call, so
# those cells carry the SUBL localparam too (rggen's SUB_N_LIST shape).
NEEDS_SUBL = ('f_terneq', 'f_p2d')

def body(tag, funcs, ptype, pinit, home, decl):
    pre = funcs
    if tag in NEEDS_SUBL:
        pre = FUNCS['f_while'] + funcs
    lp = ''
    if tag in NEEDS_SUBL:
        lp += "    localparam bit [3:0][15:0] SUBL = f_while(N);\n"
    lp += "    localparam %s P = %s;\n" % (ptype, pinit)
    if decl == 'var':
        d = ("    logic [P-1:0] v;\n"
             "    always_comb begin\n      v = '0;\n    end\n")
        drive = ""
    else:
        d = "    wire [P-1:0] v;\n    assign v = '0;\n"
        drive = ""
    inner = lp + d + drive
    if home == 'mod':
        inner = inner.replace('\n    ', '\n  ')
        if inner.startswith('    '):
            inner = inner[2:]
        return pre + inner
    return pre + "  generate\n  if (N > 0) begin : g\n" + inner + "  end\n  endgenerate\n"

def cellA(tag, funcs, ptype, pinit, home, decl):
    src = ''
    if tag == 'pkgfn':
        src += PKG
    src += "module red #(parameter int N = 4, parameter int BASE = 1)();\n"
    src += body(tag, funcs, ptype, pinit, home, decl)
    src += "endmodule\n\nmodule top;\n"
    src += "  red #(.N(4), .BASE(1)) u_a ();\n"
    src += "  red #(.N(6), .BASE(3)) u_b ();\n"
    src += "endmodule\n"
    return src

READS = {
 'var':   "    logic [P-1:0] v;\n    always_comb begin\n      v = '0;\n    end\n",
 'net':   "    wire [P-1:0] v;\n    assign v = '0;\n",
 'unpk':  "    logic v[P-1:0];\n",
 'parm':  "    localparam logic [P-1:0] Q = '0;\n",
 'ports': "",   # handled by cellB directly
 'sub':   "    logic [P-1:0] v;\n    always_comb begin\n      v = '0;\n    end\n",
}

def cellB(tag, funcs, ptype, pinit, read):
    src = ''
    if tag == 'pkgfn':
        src += PKG
    pre = funcs
    if tag in NEEDS_SUBL:
        pre = FUNCS['f_while'] + funcs
    lp = ''
    if tag in NEEDS_SUBL:
        lp += "  localparam bit [3:0][15:0] SUBL = f_while(N);\n"
    lp += "  localparam %s P = %s;\n" % (ptype, pinit)
    if read == 'ports':
        src += "module red #(parameter int N = 4, parameter int BASE = 1)();\n"
        src += pre + lp
        src += "  logic [7:0] w;\n  sub #(.W(8)) u_s (.i(w));\n"
        src += "endmodule\nmodule sub #(parameter int W = 1)(input logic [W-1:0] i);\nendmodule\n"
    else:
        src += "module red #(parameter int N = 4, parameter int BASE = 1)();\n"
        src += pre + lp + READS[read]
        src += "endmodule\n"
    src += "\nmodule top;\n  red #(.N(4), .BASE(1)) u_a ();\n  red #(.N(6), .BASE(3)) u_b ();\nendmodule\n"
    return src

def main():
    out = sys.argv[1]
    which = sys.argv[2] if len(sys.argv) > 2 else 'A'
    os.makedirs(out, exist_ok=True)
    n = 0
    if which == 'A':
        for tag, funcs, ptype, pinit in INITS:
            for home in ('mod', 'genif'):
                for decl in ('var', 'net'):
                    name = '%s__%s__%s' % (home, tag, decl)
                    d = os.path.join(out, name)
                    os.makedirs(d, exist_ok=True)
                    open(os.path.join(d, 'top.sv'), 'w').write(
                        cellA(tag, funcs, ptype, pinit, home, decl))
                    n += 1
    else:
        for tag, funcs, ptype, pinit in INITS:
            for read in ('var', 'net', 'unpk', 'parm', 'ports'):
                name = '%s__%s' % (tag, read)
                d = os.path.join(out, name)
                os.makedirs(d, exist_ok=True)
                open(os.path.join(d, 'top.sv'), 'w').write(
                    cellB(tag, funcs, ptype, pinit, read))
                n += 1
    print('cells=%d in %s' % (n, out))

main()
