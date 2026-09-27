#!/usr/bin/env python3
# dconsts.py <golden.uhdm> <ours.uhdm>: every constant of the two uhdm-dump outputs keyed by span
# (line:col-endln:endcol) -> the set of (decompile|size|value|consttype); prints the spans that differ.
import sys, subprocess, re, collections
D = '/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump'
def load(fn):
    out = subprocess.run([D, fn], capture_output=True, text=True).stdout.split('\n')
    d = collections.defaultdict(collections.Counter)
    i = 0
    while i < len(out):
        m = re.match(r'^(\s*)\\_constant: , line:(\d+):(\d+), endln:(\d+):(\d+)$', out[i])
        if m and i + 1 < len(out) and out[i+1].strip().startswith('|vpi'):
            ind = len(m.group(1)); rec = {}
            j = i + 1
            while j < len(out) and (len(out[j]) - len(out[j].lstrip())) > ind:
                s = out[j].strip()
                if len(out[j]) - len(out[j].lstrip()) == ind + 2:
                    for k in ('vpiDecompile:', 'vpiSize:', 'vpiConstType:'):
                        if s.startswith('|' + k): rec[k] = s[len(k)+1:]
                    if re.match(r'^\|(UINT|INT|BIN|HEX|DEC|OCT|STRING|REAL|SCAL):', s): rec['v'] = s[1:]
                j += 1
            key = f'{m.group(2)}:{m.group(3)}-{m.group(4)}:{m.group(5)}'
            d[key][f"{rec.get('vpiDecompile:','')}|{rec.get('vpiSize:','')}|{rec.get('v','')}|{rec.get('vpiConstType:','')}"] += 1
            i = j
        else:
            i += 1
    return d
A, B = load(sys.argv[1]), load(sys.argv[2])
for k in sorted(set(A) | set(B), key=lambda s: [int(x) for x in s.replace('-', ':').split(':')]):
    a, b = dict(A.get(k, {})), dict(B.get(k, {}))
    if a != b:
        print(f'{k:14} A {a}\n{"":14} B {b}')
