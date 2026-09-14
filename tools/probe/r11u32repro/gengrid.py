#!/usr/bin/env python3
"""r11u32 golden grid generator: <name kind> x <dims> x <position>.

Each arm is its OWN module so every signal name is unique across the design and
the census can key on the fullname.  A top `tb` instantiates every arm, so the
ELABORATED view exists for all of them (an arm with no elab view would read as
'agreeing' while testing nothing).

UNPACKED dims are tested at the body-declaration position only: an unpacked
port connected to a packed top wire is not legal and the arm would never
compile on either side.
"""
import sys

KINDS = {
    'tp':   ('parameter type T_tp  = logic [7:0]', 'T_tp'),   # type param -> logic vector
    'tpe':  ('parameter type T_tpe = pk::pe_t',    'T_tpe'),  # type param -> enum
    'tps':  ('parameter type T_tps = pk::ps_t',    'T_tps'),  # type param -> packed struct
    'tdl':  (None, 'l_t'),       # module-local typedef of a logic vector
    'tde':  (None, 'e_t'),       # module-local typedef of an enum
    'tds':  (None, 's_t'),       # module-local typedef of a packed struct
    'pkl':  (None, 'pl_t'),      # PACKAGE typedef of a logic vector, unqualified via import
    'pklq': (None, 'pk::pl_t'),  # the same package typedef written SCOPED
}
DIMS = ['nod', 'pk', 'unp']
POS = ['net', 'in', 'out']

def main():
    out = ['// r11u32 golden grid: the named-type declaration, kind x dims x position',
           'package pk;',
           '  typedef logic [7:0] pl_t;',
           '  typedef enum logic [2:0] { PE0, PE1, PE2 } pe_t;',
           '  typedef struct packed { logic [3:0] a; logic [3:0] b; } ps_t;',
           'endpackage',
           '']
    insts = []
    # A MODULE-LOCAL typedef cannot be named in an ANSI port list (it is
    # declared after it), so tdl/tde/tds are body-declaration arms only; the
    # package kinds and the type parameters cover the port positions.
    LOCAL = {'tdl', 'tde', 'tds'}
    for k, (par, ty) in KINDS.items():
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
                # the import must precede the parameter/port lists so an
                # UNQUALIFIED package type is visible in an ANSI port header
                lines = [f'module {mod} import pk::*;{params} (',
                         '    ' + ',\n    '.join(ports), ');']
                lines.append('  typedef logic [7:0] l_t;')
                lines.append('  typedef enum logic [2:0] { E0, E1, E2 } e_t;')
                lines.append('  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;')
                if p == 'net':
                    lines.append(f'  {ty} {dimtxt}{sig}{declsuffix};')
                lines.append(f'  assign sink = |{{{use}}};')
                lines.append('endmodule')
                out.append('\n'.join(lines))
                out.append('')
                insts.append((mod, sig, p))
    # The data ports are left UNCONNECTED on purpose: the arm types are
    # module-local (a module-local enum/struct is a distinct type from the
    # package one), so no single top wire can legally drive them all, and an
    # unconnected port still elaborates.  Nothing in the two halves under test
    # is gated on a connection: the emitter's only connection-sensitive
    # var/net flips are `childDrivenOut9` (an OUT port driven by the child's
    # OWN continuous assign — none here) and `genReadPort9` (a read from a
    # GENERATE scope — none here).
    tb = ['module tb;', '  logic sink;']
    for i, (mod, sig, p) in enumerate(insts):
        tb.append(f'  {mod} i{i} (.sink(sink));')
    tb.append('endmodule')
    out.append('\n'.join(tb))
    open(sys.argv[1], 'w').write('\n'.join(out) + '\n')

main()
