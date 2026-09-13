#!/usr/bin/env python3
"""r11u10 — generate the unpacked-struct-array pattern grid.

One arm per (elements x members x member kinds x holder x port-pass) cell.
Every arm is a self-contained dut.sv with ONE package parameter
`P` of type `s_t Arr[N]` initialised by a nested assignment pattern.
"""
import os
import sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else '/tmp/r11u10_grid'

# (arm, nelem, members, portpass, note)
#   members: list of (type-spelling, value-spelling)
LIT = ('logic', "1'b0")
ENUM = ('mode_e', 'M_OFF')
VEC = ("logic [1:0]", "2'b01")
SUB = ('sub_t', "'{q: 1'b1}")

ARMS = [
    ('h1_1e1m',   1, [LIT],                False),
    ('h2_1e3m',   1, [LIT, LIT, LIT],      False),
    ('h3_4e1m',   4, [LIT],                False),
    ('h4_4e3m',   4, [LIT, LIT, LIT],      False),
    ('h5_2e1m',   2, [LIT],                False),
    ('h6_1e2m',   1, [LIT, LIT],           False),
    ('h7_1e1menum', 1, [ENUM],             False),
    ('h8_4e3menum', 4, [LIT, ENUM, LIT],   False),
    ('h9_1e1m_port', 1, [LIT],             True),
    ('hA_4e3m_port', 4, [LIT, LIT, LIT],   True),
    ('hB_1e1msub', 1, [SUB],               False),
    ('hC_4e1msub', 4, [SUB],               False),
    ('hD_1e1mvec', 1, [VEC],               False),
    ('hE_4e2mvec', 4, [VEC, LIT],          False),
    ('hF_2e3m',   2, [LIT, LIT, LIT],      False),
    ('hG_3e2m',   3, [LIT, LIT],           False),
]

TMPL = """package p;
  typedef enum logic [1:0] {{
    M_OFF = 2'b00,
    M_TOR = 2'b01
  }} mode_e;

  typedef struct packed {{
    logic q;
  }} sub_t;

  typedef struct packed {{
{fields}
  }} s_t;

  parameter s_t P[{n}] = '{{
{elems}
  }};
endpackage

module leaf import p::*; (input s_t a [{n}], output logic x);
  assign x = a[0].m0;
endmodule

module dut(output logic o);
  import p::*;
{body}
endmodule
"""

BODY_PORT = "  leaf #() u (.a(P), .x(o));\n"
BODY_PLAIN = "  leaf #() u (.a(P), .x(o));\n"


def main():
    for arm, n, members, port in ARMS:
        fields = '\n'.join('    %s m%d;' % (t, i)
                           for i, (t, _) in enumerate(members))
        one = "'{" + ', '.join('m%d: %s' % (i, v)
                               for i, (_, v) in enumerate(members)) + '}'
        elems = ',\n'.join('    ' + one for _ in range(n))
        src = TMPL.format(fields=fields, n=n, elems=elems,
                          body=BODY_PORT if port else BODY_PLAIN)
        # `leaf`'s port reads m0, so every arm needs an m0 that is readable
        d = os.path.join(ROOT, arm)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'w') as f:
            f.write(src)
        print(arm)


main()
