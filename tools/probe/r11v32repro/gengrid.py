#!/usr/bin/env python3
"""v11u32 ADVERSARIAL grid: the faces r11u32's own grid does NOT carry.

One module per arm (unique signal names), a top that instantiates every one,
and for the type-parameter kinds BOTH the default binding and an explicit
override, because the corpus rows all override and the implementer's grid
tests defaults only.

Arm signal names are `y_<kind>_<dims>_<pos>`.
"""
import sys

# kind -> (parameter text or None, type text as written in the declaration)
KINDS = {
    # --- type parameters, various bindings (default binding, no override)
    'tpl':  ('parameter type T = logic [7:0]', 'T'),      # logic vector
    'tpsc': ('parameter type T = logic',       'T'),      # SCALAR logic
    'tpb':  ('parameter type T = bit [7:0]',   'T'),      # 2-STATE vector
    'tpt':  ('parameter type T = vpk::vl_t',   'T'),      # bound to a TYPEDEF
    'tpe':  ('parameter type T = vpk::ve_t',   'T'),      # enum
    'tps':  ('parameter type T = vpk::vs_t',   'T'),      # packed struct
    'tpu':  ('parameter type T = logic [7:0]', 'T'),      # OVERRIDDEN at inst
    'tpeu': ('parameter type T = logic [7:0]', 'T'),      # OVERRIDDEN with enum
    'tpsu': ('parameter type T = logic [7:0]', 'T'),      # OVERRIDDEN with struct
    # --- package typedefs beyond the vector one the implementer's grid has
    'pke':  (None, 've_t'),        # package ENUM typedef, unqualified (import)
    'pkeq': (None, 'vpk::ve_t'),   # the same, SCOPED
    'pks':  (None, 'vs_t'),        # package STRUCT typedef, unqualified
    'pkb':  (None, 'vb_t'),        # package 2-STATE vector typedef, unqualified
    # --- module-local typedefs beyond vector/enum/struct
    'tdb':  (None, 'lb_t'),        # local typedef of a BIT vector (2-state)
    'tdr':  (None, 'lr_t'),        # local typedef written `reg`
    'tde2': (None, 'le2_t'),       # local typedef of a 2-STATE enum
    'tdtp': ('parameter type T = logic [7:0]', 'ali_t'),  # typedef OF a type param
}
OVERRIDE = {'tpu': 'vpk::vl_t', 'tpeu': 'vpk::ve_t', 'tpsu': 'vpk::vs_t'}
DIMS = ['nod', 'pk', 'pk2', 'unp']
POS = ['net', 'in', 'out', 'io']


def main():
    out = ['// v11u32 adversarial grid',
           'package vpk;',
           '  typedef logic [7:0] vl_t;',
           '  typedef enum logic [2:0] { VE0, VE1, VE2 } ve_t;',
           '  typedef struct packed { logic [3:0] a; logic [3:0] b; } vs_t;',
           '  typedef bit [7:0] vb_t;',
           'endpackage',
           '']
    insts = []
    LOCAL = {'tdb', 'tdr', 'tde2', 'tdtp'}
    for k, (par, ty) in KINDS.items():
        for d in DIMS:
            positions = ['net'] if (d == 'unp' or k in LOCAL) else POS
            # an INOUT port is always a net, and a 2-state type may not be one
            if k in ('tpb', 'pkb'):
                positions = [q for q in positions if q != 'io']
            for p in positions:
                mod = f'b_{k}_{d}_{p}'
                sig = f'y_{k}_{d}_{p}'
                dimtxt = {'nod': '', 'pk': '[1:0] ', 'pk2': '[1:0][2:0] ',
                          'unp': ''}[d]
                declsuffix = ' [1:0]' if d == 'unp' else ''
                params = f' #({par})' if par else ''
                use = f'{sig}[0]' if d == 'unp' else sig
                ports = []
                if p == 'in':
                    ports.append(f'input  {ty} {dimtxt}{sig}{declsuffix}')
                elif p == 'out':
                    ports.append(f'output {ty} {dimtxt}{sig}{declsuffix}')
                elif p == 'io':
                    ports.append(f'inout  {ty} {dimtxt}{sig}{declsuffix}')
                ports.append('output logic sink')
                lines = [f'module {mod} import vpk::*;{params} (',
                         '    ' + ',\n    '.join(ports), ');']
                lines.append('  typedef logic [7:0] ll_t;')
                lines.append('  typedef bit   [7:0] lb_t;')
                lines.append('  typedef reg   [7:0] lr_t;')
                lines.append('  typedef enum bit [1:0] { LE0, LE1 } le2_t;')
                if k == 'tdtp':
                    lines.append('  typedef T ali_t;')
                if p == 'net':
                    lines.append(f'  {ty} {dimtxt}{sig}{declsuffix};')
                lines.append(f'  assign sink = |{{{use}}};')
                lines.append('endmodule')
                out.append('\n'.join(lines))
                out.append('')
                insts.append((mod, k))
    tb = ['module vtb;', '  logic sink;']
    for i, (mod, k) in enumerate(insts):
        ov = f' #(.T({OVERRIDE[k]}))' if k in OVERRIDE else ''
        tb.append(f'  {mod}{ov} i{i} (.sink(sink));')
    tb.append('endmodule')
    out.append('\n'.join(tb))
    open(sys.argv[1], 'w').write('\n'.join(out) + '\n')


main()
