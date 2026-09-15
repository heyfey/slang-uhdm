#!/usr/bin/env python3
"""r11u41 — A-PRIORI mover prediction, from the SOURCES alone, before any
patched sweep runs.

The laws all key on ONE syntactic fact: a declaration (body net, port, or
variable) whose written data type is the NAME of a `parameter type` formal in
the same module.  This scanner finds, per test directory:

  * every `parameter type <N> [= <default>]` formal, with its written default;
  * every declaration whose written data type is one of those names, with the
    dimension shape it is written at (nod / pk / unp) and its position.

A test is a PREDICTED MOVER when at least one such declaration exists.  The
report also splits by the DEFAULT's leaf kind (struct / enum / other) so the
per-law gates can be scored against it.

usage: predict41.py <corpus root> [<corpus root> ...]
"""
import os, re, sys

TP = re.compile(r'\bparameter\s+type\s+([A-Za-z_]\w*)\s*(?:=\s*([^,;)]+))?')
# a declaration/port whose written data type is a bare identifier, optionally
# carrying packed dims, followed by a declarator name
DECL = re.compile(
    r'(?m)^[ \t]*(?:(input|output|inout)\s+)?([A-Za-z_]\w*)\s*'
    r'((?:\[[^\];]*\]\s*)*)([A-Za-z_]\w*)\s*((?:\[[^\];]*\]\s*)*)[,;)]')

KEYWORDS = {'input', 'output', 'inout', 'logic', 'wire', 'reg', 'bit', 'byte',
            'int', 'integer', 'shortint', 'longint', 'real', 'shortreal',
            'time', 'string', 'parameter', 'localparam', 'typedef', 'struct',
            'union', 'enum', 'module', 'endmodule', 'function', 'task',
            'return', 'assign', 'always', 'always_comb', 'always_ff', 'begin',
            'end', 'if', 'else', 'for', 'case', 'genvar', 'generate', 'var',
            'const', 'automatic', 'static', 'signed', 'unsigned', 'import',
            'package', 'endpackage', 'interface', 'modport', 'initial',
            'default', 'type'}

SRC = ('.sv', '.v', '.svh', '.vh')


def strip(text):
    text = re.sub(r'/\*.*?\*/', ' ', text, flags=re.S)
    return re.sub(r'//[^\n]*', ' ', text)


def leafkind(default, text):
    """classify the written default of a `parameter type`."""
    if not default:
        return 'none'
    d = default.strip()
    base = d.split('::')[-1].split('[')[0].strip()
    if re.match(r'^(logic|bit|wire|reg)\b', d):
        return 'logic'
    if re.match(r'^(int|integer|byte|shortint|longint|real|shortreal|time|string)\b', d):
        return 'other'
    if re.search(r'\bstruct\b', d) or re.search(
            r'typedef\s+struct[^;]*\b' + re.escape(base) + r'\s*;', text):
        return 'struct'
    if re.search(r'\benum\b', d) or re.search(
            r'typedef\s+enum[^;]*\b' + re.escape(base) + r'\s*;', text):
        return 'enum'
    return 'unknown:' + base


def scan_test(d):
    hits = []
    for root, _, files in os.walk(d):
        for f in files:
            if not f.endswith(SRC):
                continue
            p = os.path.join(root, f)
            try:
                text = strip(open(p, errors='replace').read())
            except OSError:
                continue
            names = {}
            for m in TP.finditer(text):
                names[m.group(1)] = m.group(2)
            if not names:
                continue
            for m in DECL.finditer(text):
                direction, ty, pk, nm, unp = m.groups()
                if ty not in names or nm in KEYWORDS:
                    continue
                dims = 'unp' if unp.strip() else ('pk' if pk.strip() else 'nod')
                pos = direction or 'net'
                hits.append((os.path.basename(p), ty, nm, dims, pos,
                             leafkind(names[ty], text)))
    return hits


def main():
    for rootdir in sys.argv[1:]:
        for t in sorted(os.listdir(rootdir)):
            d = os.path.join(rootdir, t)
            if not os.path.isdir(d):
                continue
            hits = scan_test(d)
            if hits:
                kinds = sorted({h[5] for h in hits})
                shapes = sorted({h[3] + '/' + h[4] for h in hits})
                print(f'{t}\tn={len(hits)}\tleaf={",".join(kinds)}'
                      f'\tshape={",".join(shapes)}')
                for h in hits:
                    print(f'      {h[0]}: {h[1]} {h[3]} {h[4]} -> {h[2]} '
                          f'[default leaf {h[5]}]')


main()
