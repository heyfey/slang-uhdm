#!/usr/bin/env python3
"""Superset predictor for the two v11u164 refinements, by name, from sources (fail-closed on $FENCED).
rqmask: a continuous assign whose right side is exactly a $high/$low/$left/$right call.
aliasbase: a non-package enum typedef with a non-literal base bound, aliased by a later `typedef <it> <alias>;`."""
import os, re, sys, glob
F = os.environ.get('FENCED', '').split()
if len(F) != 4: sys.exit('predict: FENCED must hold four names')
fre = re.compile(r'\b(' + '|'.join(map(re.escape, F)) + r')\b')
RQ = re.compile(r'assign\s+[^;=]+=\s*\$(high|low|left|right)\s*\([^;]*\)\s*;')
EN = re.compile(r'typedef\s+enum\s+\w*\s*(?:(?:logic|bit|reg)\s*(?:signed|unsigned)?\s*)?\[([^\]:]+):([^\]]+)\]\s*\{[^}]*\}\s*(\w+)\s*;', re.S)
roots = {'surelog': ['/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/tests', '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/tests'],
         'uhdm2rtlil': ['/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test'],
         'probe': ['/tmp/wt_v11u164/tests/probe']}
lit = re.compile(r'^\s*\d+\s*$')
for corpus, rs in roots.items():
    for r in rs:
        for f in glob.glob(r + '/**/*.*v', recursive=True) + glob.glob(r + '/**/*.svh', recursive=True):
            if fre.search(f): continue
            try: t = open(f, errors='replace').read()
            except Exception: continue
            tags = []
            if RQ.search(t): tags.append('rqmask')
            for m in EN.finditer(t):
                if not (lit.match(m.group(1)) and lit.match(m.group(2))):
                    if re.search(r'typedef\s+' + re.escape(m.group(3)) + r'\s+\w+\s*;', t): tags.append('aliasbase')
            if tags: print(corpus, os.path.relpath(f, r), ' '.join(sorted(set(tags))), sep='\t')
