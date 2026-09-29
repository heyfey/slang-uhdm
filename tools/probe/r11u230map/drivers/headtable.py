#!/usr/bin/env python3
"""r11u230map: the head-record writer table (README section 4): one pinwriter.py jsonl per fail-list row (PW_ROWS = that
row, the row's first cluster), each summarised with pwsum.py's chain rule. Args: <src dir> <pinwriter jsonl>..."""
import sys, os, json, tempfile, subprocess
SRC = sys.argv[1]; here = os.path.dirname(os.path.abspath(__file__))
print('| row (default mode) | first cluster | head record (golden / ours) | writer of the differing field (how) | mint | ground of the writer frame |')
print('|---|---|---|---|---|---|')
for p in sys.argv[2:]:
    for l in open(p):
        r = json.loads(l)
        with tempfile.TemporaryDirectory() as d:
            open(f'{d}/one.jsonl', 'w').write(l)
            subprocess.run(['python3', f'{here}/pwsum.py', SRC, f'{d}/s.json', f'{d}/g.json', f'{d}/one.jsonl'], capture_output=True)
            s = json.load(open(f'{d}/s.json'))[r['cluster']]
        GA = {'ExprEmit.cpp', 'EmitHelpers.h', 'StmtEmit.cpp', 'ParamEmit.cpp'}; GB = {'TypeEmit.cpp', 'ModuleEmit.cpp', 'UhdmExporter.cpp', 'TaskFuncEmit.cpp', 'uhdm_main.cpp'}
        g = 'A' if s['owner'] in GA else 'B' if s['owner'] in GB else '?'
        esc = lambda x: str(x).replace('|', '\\|')
        print(f"| {r['example'].split('/')[2]} | {r['cluster']} | #{r['rec']} {r['type']} '{esc(r['name'][:36])}' {r['fields']}: {esc(str(r['golden'])[:40])} / {esc(str(r['ours'])[:40])} | {esc(s['writer'][:150])} ({s['how']}) | {esc(s['mint'][:70])} | {g} |")
