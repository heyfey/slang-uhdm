#!/usr/bin/env python3
"""r10rgg11/gen_grid11.py — GRID A: what constant does GOLDEN put at an
instance PORT CONNECTION whose actual is a BARE PARAMETER NAME?

Axes: home (where the parameter is declared) x declared type x initializer.
Read is fixed at `portplain` (.i_value(IV)).  MEASUREMENT ONLY.

Every cell is a single self-contained top.sv with exactly ONE `sink` instance,
so the census key (instance path, port index, port name) is stable across cells.

usage: gen_grid11.py <outdir> [gridB]
"""
import os, sys

HOMES = ['mod', 'genif', 'genfor', 'pkg']

TYPES = {
    'bit8':    'bit [7:0]',
    'logic8':  'logic [7:0]',
    'sbit8':   'bit signed [7:0]',
    'int':     'int',
    'untyped': '',
    'bit1':    'bit',
    'bit32':   'bit [31:0]',
    'byte':    'byte',
}

INITS = {
    'hex8':     "8'hab",
    'bin8':     "8'b10101011",
    'dec8':     "8'd171",
    'unsized':  "171",
    'neg':      "-3",
    'expr':     "8'h0a + 8'ha1",
    'pexpr':    "BASE + 1",
    'cat':      "{4'ha, 4'hb}",
    'call':     "f8(8'hab)",
    'clog2':    "$clog2(300)",
    'uhex':     "'hab",
    'sizedone': "1'b1",
}

# read kind -> (port actual text, extra lines inside the home scope,
#               parameter-override text for the sink instance)
READS = {
    'portplain': ('IV',                  [],                          '8'),
    'portcat':   ("{4'h0, IV[3:0]}",     [],                          '8'),
    'portcall':  ('f8(IV)',              [],                          '8'),
    'portcast':  ("8'(IV)",              [],                          '8'),
    'portsel':   ('IV[3:0]',             [],                          '8'),
    'pov':       ("'0",                  [],                          '.W(IV)'),
    'ca':        ("'0",                  ['wire [7:0] w;',
                                          'assign w = IV;'],          '8'),
    'proc':      ("'0",                  ['logic [7:0] x;',
                                          'always_comb x = IV;'],     '8'),
    'none':      ("'0",                  [],                          '8'),
}

FUNC = ("  function automatic bit [7:0] f8(input bit [7:0] a);\n"
        "    return a;\n"
        "  endfunction\n")


def cell(home, tname, iname, rname):
    ty = TYPES[tname]
    ini = INITS[iname]
    actual, extra, povr = READS[rname]
    decl = ('  localparam int BASE = 170;\n'
            '  localparam %s IV = %s;\n' % (ty, ini) if ty else
            '  localparam int BASE = 170;\n  localparam IV = %s;\n' % ini)
    src = []
    src.append('// r10rgg11 grid cell %s__%s__%s__%s' % (home, tname, iname, rname))
    if home == 'pkg':
        src.append('package pk;')
        src.append(FUNC.replace('  function', '  function'))
        src.append(decl)
        src.append('endpackage')
    src.append('module sink #(parameter int W = 8) (input logic [W-1:0] i_value);')
    src.append('endmodule')
    src.append('module top;')
    src.append(FUNC)
    body = []
    if home == 'pkg':
        # the parameter lives in the package; the READ is spelled pk::IV
        body.append('  localparam int BASE = 170;')
        inner = ['  sink #(%s) u (.i_value(%s));' %
                 (povr.replace('IV', 'pk::IV'), actual.replace('IV', 'pk::IV'))]
        for e in extra:
            inner.append('  ' + e.replace('IV', 'pk::IV'))
        body += inner
    else:
        inner = [decl.rstrip('\n')]
        inner.append('  sink #(%s) u (.i_value(%s));' % (povr, actual))
        for e in extra:
            inner.append('  ' + e)
        if home == 'mod':
            body += inner
        elif home == 'genif':
            body.append('  if (1) begin : g')
            body += ['  ' + l for l in inner]
            body.append('  end')
        elif home == 'genfor':
            body.append('  for (genvar gi = 0; gi < 1; gi++) begin : g')
            body += ['  ' + l for l in inner]
            body.append('  end')
    src += body
    src.append('endmodule')
    return '\n'.join(src) + '\n'


def main():
    out = sys.argv[1]
    which = sys.argv[2] if len(sys.argv) > 2 else 'A'
    os.makedirs(out, exist_ok=True)
    n = 0
    if which == 'A':
        homes = ['mod', 'genif']
        reads = ['portplain']
        types = list(TYPES)
        inits = list(INITS)
    else:
        homes = HOMES
        reads = list(READS)
        types = ['bit8', 'int', 'untyped']
        inits = ['hex8', 'unsized', 'expr']
    for h in homes:
        for t in types:
            for i in inits:
                for r in reads:
                    nm = '%s__%s__%s__%s' % (h, t, i, r)
                    d = os.path.join(out, nm)
                    os.makedirs(d, exist_ok=True)
                    with open(os.path.join(d, 'top.sv'), 'w') as f:
                        f.write(cell(h, t, i, r))
                    n += 1
    print('-- cells written =', n, 'grid', which, '->', out)


main()
