#!/usr/bin/env python3
"""r11u41 golden grid: the STRUCT-BOUND type parameter's net kind.

One module per arm so every signal name is unique across the design; a top `tb`
instantiates every arm (an arm with no elab view would read as *agreeing* while
testing nothing).  Axes:

  name kind  x  dims {none, packed, unpacked}  x  position {body net, input, output}

Name kinds (all of them reach a STRUCT leaf except the two controls):
  tps   type parameter DEFAULTED to a packed struct, all-logic members
  tpso  type parameter defaulted to `logic`, OVERRIDDEN at the instance to that
        struct                                    <- the corpus row's shape
  tpsn  type parameter bound to a struct with a NESTED STRUCT member
        (the loose scan accepts it, the strict scan does not)
  tpsb  type parameter bound to a struct with a `bit` member (both scans fail)
  tpse  type parameter bound to a struct with an ENUM member (both scans fail)
  tds   module-local typedef of the all-logic struct           (control)
  pks   package struct typedef named UNQUALIFIED via import    (control)
  pksq  the same package typedef named SCOPED                  (control)

Data ports are left UNCONNECTED on purpose (same reasoning as r11u32's grid:
a module-local struct is a distinct type from the package one, so no single top
wire can legally drive them all, and nothing under test is gated on a
connection).
"""
import sys

# kind -> (parameter decl or None, written type name, instance override or None)
KINDS = {
    'tps':  ('parameter type T_tps  = pk::ps_t',  'T_tps',  None),
    'tpso': ('parameter type T_tpso = logic',     'T_tpso', 'pk::ps_t'),
    'tpsn': ('parameter type T_tpsn = pk::psn_t', 'T_tpsn', None),
    'tpsb': ('parameter type T_tpsb = pk::psb_t', 'T_tpsb', None),
    'tpse': ('parameter type T_tpse = pk::pse_t', 'T_tpse', None),
    'tds':  (None, 's_t',       None),
    'pks':  (None, 'ps_t',      None),
    'pksq': (None, 'pk::ps_t',  None),
}
DIMS = ['nod', 'pk', 'unp']
POS = ['net', 'in', 'out']
LOCAL = {'tds'}          # a module-local typedef cannot be named in its own ANSI header


def main():
    out = ['// r11u41 golden grid: the struct-bound type parameter, kind x dims x position',
           'package pk;',
           '  typedef enum logic [2:0] { PE0, PE1, PE2 } pe_t;',
           '  typedef struct packed { logic [3:0] a; logic [3:0] b; } ps_t;',
           '  typedef struct packed { logic [3:0] a; ps_t inner; } psn_t;',
           '  typedef struct packed { logic [3:0] a; bit   [3:0] b; } psb_t;',
           '  typedef struct packed { logic [3:0] a; pe_t  e;       } pse_t;',
           'endpackage',
           '']
    insts = []
    for k, (par, ty, ovr) in KINDS.items():
        for d in DIMS:
            for p in (['net'] if (d == 'unp' or k in LOCAL) else POS):
                mod = f'a_{k}_{d}_{p}'
                sig = f'x_{k}_{d}_{p}'
                dimtxt = '[1:0] ' if d == 'pk' else ''
                declsuffix = ' [1:0]' if d == 'unp' else ''
                params = f' #({par})' if par else ''
                use = f'{sig}[0]' if d == 'unp' else sig
                ports = []
                if p == 'in':
                    ports.append(f'input  {ty} {dimtxt}{sig}{declsuffix}')
                elif p == 'out':
                    ports.append(f'output {ty} {dimtxt}{sig}{declsuffix}')
                ports.append('output logic sink')
                lines = [f'module {mod} import pk::*;{params} (',
                         '    ' + ',\n    '.join(ports), ');']
                lines.append('  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;')
                if p == 'net':
                    lines.append(f'  {ty} {dimtxt}{sig}{declsuffix};')
                lines.append(f'  assign sink = |{{{use}}};')
                lines.append('endmodule')
                out.append('\n'.join(lines))
                out.append('')
                insts.append((mod, ovr, par))
    tb = ['module tb;', '  logic sink;']
    for i, (mod, ovr, par) in enumerate(insts):
        pn = par.split()[-3] if (par and ovr) else None
        if ovr:
            pn = par.split('=')[0].split()[-1]
            tb.append(f'  {mod} #(.{pn}({ovr})) i{i} (.sink(sink));')
        else:
            tb.append(f'  {mod} i{i} (.sink(sink));')
    tb.append('endmodule')
    out.append('\n'.join(tb))
    open(sys.argv[1], 'w').write('\n'.join(out) + '\n')


main()
