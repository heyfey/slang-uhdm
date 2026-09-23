#!/usr/bin/env python3
"""mkgrid116.py <outdir> — writes grid/f1 (substituted parameter read: literal
base x home x container x position) and grid/f2 (package parameter read in a
generate-scope process/CA: nesting depth x container x parameter kind, every
arm holding LHS and RHS positions).  One dut.sv per arm."""
import os, sys
OUT = sys.argv[1]

def w(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, 'w').write(text)

# ---------------------------------------------------------------- face 1
BASES = {'h': "32'h00000FFF", 'o': "32'o7777", 'b': "32'b111111111111",
         'd': "32'd4095", 'u': "4095", 'x': "'hFFF", 'n': "12'hFFF"}
HOMES = ['mh', 'ml', 'pk', 'mu', 'mv', 'gl']
CTRS = ['lg', 'ig', 'ms', 'ac', 'ch']

def f1(home, lit, ctr):
    pkg = ''
    imp = ''
    hdr = ''
    body = ''
    glp = ''
    if home == 'mh':
        hdr = '#(parameter int unsigned M = %s) ' % lit
    elif home == 'ml':
        body = '  localparam int unsigned M = %s;\n' % lit
    elif home == 'pk':
        pkg = 'package p;\n  parameter int unsigned M = %s;\nendpackage\n' % lit
        imp = 'import p::*; '
    elif home == 'mu':
        hdr = '#(parameter M = %s) ' % lit
    elif home == 'mv':
        hdr = '#(parameter logic [31:0] M = %s) ' % lit
    elif home == 'gl':
        glp = '    localparam int unsigned M = %s;\n' % lit
    decl = ('  logic [31:0] a [2];\n  logic o1 [2];\n  logic [31:0] o2 [2];\n'
            '  logic o3 [2];\n  logic o4 [2];\n  logic [31:0] o5 [2];\n'
            '  logic [31:0] o6 [2];\n  logic [31:0] o7 [2];\n')
    stm = ['o1[c] = (a[c] & ~M) == 32\'d0;', 'o2[c] = M;',
           'o3[c] = a[c][M % 32];', 'o4[c] = a[c] == M;', 'o5[c] = a[c] + M;',
           'o6[c] = a[c][M-4064:M-4065];', 'o7[c][M % 32] = a[c][0];']
    if ctr == 'lg' or ctr == 'ch':
        gen = '  for (genvar c = 0; c < 2; c++) begin : g\n' + glp
        gen += ''.join('    assign %s\n' % s for s in stm)
        gen += '  end\n'
    elif ctr == 'ig':
        gen = '  if (1) begin : g\n' + glp + '    localparam int c = 0;\n'
        gen += ''.join('    assign %s\n' % s for s in stm)
        gen += '  end\n'
    elif ctr == 'ms':
        gen = '  localparam int c = 0;\n' + (glp.replace('    ', '  ') if glp else '')
        gen += ''.join('  assign %s\n' % s for s in stm)
    elif ctr == 'ac':
        gen = '  for (genvar c = 0; c < 2; c++) begin : g\n' + glp
        gen += '    always_comb begin\n'
        gen += ''.join('      %s\n' % s for s in stm)
        gen += '    end\n  end\n'
    name = 'dut' if ctr != 'ch' else 'leaf'
    src = pkg + 'module %s %s%s();\n' % (name, imp, hdr) + body + decl + gen + 'endmodule\n'
    if ctr == 'ch':
        src += 'module dut;\n  leaf u();\nendmodule\n'
    return src

for home in HOMES:
    for bk, lit in BASES.items():
        for ctr in CTRS:
            w(os.path.join(OUT, 'f1', '%s_%s_%s' % (home, bk, ctr), 'dut.sv'),
              f1(home, lit, ctr))

# ---------------------------------------------------------------- face 2
# depth: g1 top-level for; g2 for-in-for; g3 if-in-for-in-for (ibex shape);
#        gi if-in-for
KINDS = ['w', 'q', 'm', 'l', 'e']   # wildcard pkg, qualified pkg, module param, module localparam, explicit import
CTR2 = ['ff', 'cb', 'ca', 'in']

def f2(depth, ctr, kind):
    P = 'p::P' if kind == 'q' else 'P'
    pkg = 'package p;\n  parameter int unsigned P = 32;\nendpackage\n'
    imp = {'w': 'import p::*; ', 'q': '', 'm': '', 'l': '', 'e': 'import p::P; '}[kind]
    hdr = '#(parameter int unsigned P = 32) ' if kind == 'm' else ''
    body = '  localparam int unsigned P = 32;\n' if kind == 'l' else ''
    decl = ('  logic clk;\n  logic [4*32-1:0] q [4];\n  logic [4*32-1:0] d [4];\n'
            '  logic [63:0] v [4];\n')
    # statements: LHS ips (base op + width), RHS ips; bare LHS index; LHS part-select bounds
    st = ['q[f][b*%s+:%s] <= d[f][b*%s+:%s];' % (P, P, P, P),
          'v[f][%s] <= d[f][%s];' % (P, P),
          'v[f][%s-1:0] <= d[f][%s-1:0];' % (P, P),
          'q[f][%s*b] <= d[f][b+%s];' % (P, P)]
    if ctr == 'cb' or ctr == 'ca' or ctr == 'in':
        st = [s.replace('<=', '=') for s in st]
    ind = '      '
    if ctr == 'ff':
        proc = ind + 'always_ff @(posedge clk) begin\n' + ''.join(ind + '  ' + s + '\n' for s in st) + ind + 'end\n'
    elif ctr == 'cb':
        proc = ind + 'always_comb begin\n' + ''.join(ind + '  ' + s + '\n' for s in st) + ind + 'end\n'
    elif ctr == 'in':
        proc = ind + 'initial begin\n' + ''.join(ind + '  ' + s + '\n' for s in st) + ind + 'end\n'
    else:
        proc = ''.join(ind + 'assign ' + s + '\n' for s in st[:1])
    if depth == 'g1':
        gen = ('  for (genvar f = 0; f < 2; f++) begin : gf\n    localparam int b = 1;\n' +
               proc.replace('      ', '    ') + '  end\n')
    elif depth == 'g2':
        gen = ('  for (genvar f = 0; f < 2; f++) begin : gf\n    for (genvar b = 0; b < 2; b++) begin : gb\n' +
               proc + '    end\n  end\n')
    elif depth == 'g3':
        gen = ('  for (genvar f = 0; f < 2; f++) begin : gf\n    for (genvar b = 0; b < 2; b++) begin : gb\n'
               '      if (1) begin : gn\n' + proc.replace('      ', '        ') +
               '      end\n    end\n  end\n')
    else:
        gen = ('  for (genvar f = 0; f < 2; f++) begin : gf\n    localparam int b = 1;\n'
               '    if (1) begin : gn\n' + proc + '    end\n  end\n')
    return pkg + 'module dut %s%s();\n' % (imp, hdr) + body + decl + gen + 'endmodule\n'

for depth in ['g1', 'g2', 'g3', 'gi']:
    for ctr in CTR2:
        for kind in KINDS:
            w(os.path.join(OUT, 'f2', '%s_%s_%s' % (depth, ctr, kind), 'dut.sv'),
              f2(depth, ctr, kind))

# ---------------------------------------------------------------- face 3
# R1: reads of a concat-bearing imported parameter outside case items;
# R3: case items reading a literal-valued typed imported parameter.
PK3 = ('package pk;\n'
       '  typedef enum logic [6:0] { OP_SYS = 7\'h73, OP_LUI = 7\'h37 } op_e;\n'
       '  typedef logic [31:0] w_t;\n'
       '  parameter logic [31:0] P_CAT = { 12\'b0, 13\'b0, {OP_SYS} };\n'
       '  parameter logic [31:0] P_REP = { {25{1\'b0}}, 7\'h37 };\n'
       '  parameter logic [31:0] P_NOT = ~{ 25\'h0, 7\'h37 };\n'
       '  parameter logic [31:0] P_LIT = 32\'h00000073;\n'
       '  parameter int P_INT = 115;\n'
       '  parameter w_t P_TD = 32\'h37;\n'
       '  parameter P_UNT = 32\'h73;\n'
       'endpackage\n')
R1NAMES = ['P_CAT', 'P_REP', 'P_NOT', 'P_LIT']
def f3r1(ctx, imp):
    impt = {'w': 'import pk::*; ', 'e': 'import pk::P_CAT, pk::P_REP, pk::P_NOT, pk::P_LIT; '}[imp]
    hdr = '(input logic [31:0] x, output logic [3:0] y, output logic [31:0] z, output logic [31:0] w, output logic u)'
    b = ''
    if ctx == 'ac':
        b = '  always_comb begin\n    y = 4\'d0; z = 32\'d0; u = 1\'b0;\n'
        for i, n in enumerate(R1NAMES):
            b += '    if (x == %s) y = 4\'d%d;\n' % (n, i + 1)
        b += '    z = P_CAT;\n    z = x & P_REP;\n    u = (x != P_NOT);\n  end\n'
        b += '  assign w = P_CAT | P_LIT;\n'
    elif ctx == 'ff':
        b = '  logic clk;\n  always_ff @(posedge clk) begin\n'
        for i, n in enumerate(R1NAMES):
            b += '    if (x == %s) y <= 4\'d%d;\n' % (n, i + 1)
        b += '    z <= P_CAT ^ x;\n  end\n'
    elif ctx == 'fn':
        b = '  function automatic logic [31:0] f(input logic [31:0] a);\n    if (a == P_CAT) return P_REP;\n    return a & P_NOT;\n  endfunction\n'
        b += '  assign z = f(x);\n'
    elif ctx == 'gs':
        b = '  if (1) begin : g\n    always_comb begin\n      z = x & P_CAT;\n      if (x == P_REP) y = 4\'d1; else y = 4\'d0;\n    end\n    assign w = P_NOT;\n  end\n'
    elif ctx == 'in':
        b = '  initial begin\n    if (x == P_CAT) y = 4\'d1;\n    z = P_REP;\n  end\n'
    elif ctx == 'ch':
        return (PK3 + 'module leaf %s%s;\n' % (impt, hdr) +
                '  always_comb begin\n    y = 4\'d0;\n    if (x == P_CAT) y = 4\'d1;\n    z = P_REP;\n  end\n'
                '  assign w = P_NOT;\n  assign u = 1\'b0;\nendmodule\n'
                'module top (input logic [31:0] x, output logic [3:0] y, output logic [31:0] z, output logic [31:0] w, output logic u);\n'
                '  leaf l(.x(x), .y(y), .z(z), .w(w), .u(u));\nendmodule\n')
    return PK3 + 'module top %s%s;\n' % (impt, hdr) + b + 'endmodule\n'
for ctx in ['ac', 'ff', 'fn', 'gs', 'in', 'ch']:
    for imp in ['w', 'e']:
        w(os.path.join(OUT, 'f3', 'r1_%s_%s' % (ctx, imp), 'dut.sv'), f3r1(ctx, imp))

def f3r3(ctx, imp):
    impt = {'w': 'import pk::*; ', 'e': 'import pk::P_LIT, pk::P_INT, pk::P_TD, pk::P_UNT, pk::P_CAT; '}[imp]
    hdr = '(input logic [31:0] x, output logic [3:0] y)'
    items = '      P_LIT: y = 4\'d1;\n      P_INT: y = 4\'d2;\n      P_TD: y = 4\'d3;\n      P_UNT: y = 4\'d4;\n      P_CAT: y = 4\'d5;\n      default: y = 4\'d0;\n'
    if ctx == 'ac':
        b = '  always_comb begin\n    case (x)\n' + items + '    endcase\n  end\n'
    elif ctx == 'ff':
        b = '  logic clk;\n  always_ff @(posedge clk) begin\n    case (x)\n' + items.replace('y =', 'y <=') + '    endcase\n  end\n'
    elif ctx == 'fn':
        b = ('  function automatic logic [3:0] f(input logic [31:0] a);\n    logic [3:0] y;\n    case (a)\n' + items +
             '    endcase\n    return y;\n  endfunction\n  assign y = f(x);\n')
    elif ctx == 'gs':
        b = '  if (1) begin : g\n    always_comb begin\n      case (x)\n' + items + '      endcase\n    end\n  end\n'
    elif ctx == 'lg':
        b = '  for (genvar i = 0; i < 1; i++) begin : g\n    always_comb begin\n      case (x)\n' + items + '      endcase\n    end\n  end\n'
    elif ctx == 'in':
        b = '  initial begin\n    case (x)\n' + items + '    endcase\n  end\n'
    elif ctx == 'ui':
        b = '  always_comb begin\n    unique case (x)\n' + items + '    endcase\n  end\n'
    elif ctx == 'ch':
        return (PK3 + 'module leaf %s%s;\n' % (impt, hdr) + '  always_comb begin\n    case (x)\n' + items +
                '    endcase\n  end\nendmodule\nmodule top (input logic [31:0] x, output logic [3:0] y);\n  leaf l(.x(x), .y(y));\nendmodule\n')
    return PK3 + 'module top %s%s;\n' % (impt, hdr) + b + 'endmodule\n'
for ctx in ['ac', 'ff', 'fn', 'gs', 'lg', 'in', 'ui', 'ch']:
    for imp in ['w', 'e']:
        w(os.path.join(OUT, 'f3', 'r3_%s_%s' % (ctx, imp), 'dut.sv'), f3r3(ctx, imp))
