#!/usr/bin/env python3
"""retvar.py <uhdm-dump text> <package>: for every package-level function of <package> (`  \\_function: (<package>::...)`), the kind of its vpiReturn variable and whether that variable is a clone-parented copy (its name starts with <package>::) or the home object; prints the tally with one example each.
Fail-closed on the fence: the four names of the FENCED= line of tools/probe/r11u107repro/canaudit.sh (read here); a
path holding one of them is refused."""
import os, re, sys, collections
_R = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
_F = next((l.split('=', 1)[1].strip().strip('"\'').split() for l in open(os.path.join(_R, 'tools/probe/r11u107repro/canaudit.sh')) if l.startswith('FENCED=')), [])
if len(_F) != 4: sys.exit('fence unreadable')
for _a in sys.argv[1:]:
    if any(re.search(r'(?<![A-Za-z0-9_])%s(?![A-Za-z0-9_])' % re.escape(f), _a) for f in _F): sys.exit('fenced path refused')
lines = open(sys.argv[1]).read().split('\n')
pkg = sys.argv[2]
c = collections.Counter(); ex = collections.defaultdict(list)
for i, l in enumerate(lines):
    m = re.match(r'^  \\_function: \((%s::[^)]*)\)' % pkg, l)
    if not m: continue
    fn = m.group(1)
    for j in range(i+1, min(i+12, len(lines))):
        if lines[j].startswith('    |vpiReturn:'):
            v = lines[j+1].strip(); p = lines[j+3].strip()
            vk = v.split(':')[0]; home = 'home' if '(%s::' % pkg not in v else 'clone'
            c[(vk, home)] += 1; ex[(vk, home)].append((fn, v[:90], p[:90]))
            break
        if lines[j].startswith('  \\_'): break
for k in sorted(c): print(k, c[k], ex[k][0])
print(sum(c.values()))
