#!/usr/bin/env python3
# r11u417 scan_hp.py: the by-name prediction for § hierSelParenBoundPretty417: source
# lines with a dotted reference whose last select is a range select (:, +:, -:)
# with a parenthesis or ** in its bounds.  Paths fence-filtered before opening.
import os, re, sys
fenced=[l.strip() for l in open('/tmp/r11u417_fenced.txt') if l.strip()]
RX=re.compile(r'[A-Za-z_]\w*(?:\[[^\]\[]*\])*\.[A-Za-z_]\w*(?:\.[A-Za-z_]\w*|\[[^\]\[]*\])*\[([^\]\[]*(?:\[[^\]\[]*\][^\]\[]*)*)\]')
for root in sys.argv[1:]:
    for d,_,fs in os.walk(root):
        if any(n in d for n in fenced): continue
        for f in fs:
            if not f.endswith(('.sv','.v','.svh','.vh')) or any(n in f for n in fenced): continue
            p=os.path.join(d,f)
            try: lines=open(p,errors='replace').read().split('\n')
            except Exception: continue
            for i,l in enumerate(lines,1):
                l2=re.sub(r'//.*','',l)
                for m in RX.finditer(l2):
                    b=m.group(1)
                    if re.search(r'(\+:|-:|:)',b) and ('(' in b or '**' in b):
                        print(f'{p}:{i}: {m.group(0)[:100]}')
