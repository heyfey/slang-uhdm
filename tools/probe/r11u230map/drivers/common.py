"""Shared helpers (map 8's cluster key rewrite + the fence)."""
import os, re
def rekey(x):
    """analyze.py's key, with two splits: a file facet naming builtin.sv on
    either side (@builtin), and a full-name facet on a non-ref_typespec object
    inside a typespec subtree (@in-typespec, the F02 parent-policy ground)."""
    c = x['cluster']
    if x['facet'] == 'file' and ('builtin.sv' in x['golden'] or 'builtin.sv' in x['ours']):
        p = c.split('|'); p[2] += '@builtin'; c = '|'.join(p)
    if x['facet'] == 'fullname' and x['type'] != 'ref_typespec' and '_typespec' in x['chain']:
        p = c.split('|'); p[2] += '@in-typespec'; c = '|'.join(p)
    return c
def fenced():
    """r11u179: the four slang-fenced names, from the FENCED= line of tools/probe/r11u107repro/canaudit.sh
    (the brief's source; never RESUME.md by line number). Fail closed."""
    here = os.path.dirname(os.path.abspath(__file__))
    p = os.path.join(here, '..', '..', 'r11u107repro', 'canaudit.sh')
    for l in open(p):
        if l.startswith('FENCED='):
            n = re.sub(r'["\']', '', l[len('FENCED='):]).split()
            assert len(n) == 4, 'fence list unreadable: refusing to run'
            return set(n)
    raise SystemExit('fence list unreadable: refusing to run')
def is_fenced(s, F=None):
    F = F or fenced()
    return any(re.search(r'(?<![A-Za-z0-9_])' + re.escape(f) + r'(?![A-Za-z0-9_])', s) for f in F)
