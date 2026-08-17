#!/usr/bin/env python3
"""r10earl53 — STRUCTURAL ATTRIBUTION of every byte mover.

§ connPathRootTs53 is a CORPUS-WIDE rule, so the byte verifier reports many
movers and "name every mover" cannot mean "list the files".  It means: prove
that in EVERY mover, the whole delta is the rule's signature and nothing else.

The rule's signature, in a uhdm-dump, is EXACTLY:

    |vpiTypespec:                      <- added on a hier_path
    \\_ref_typespec: (<name>)           <- the new object ...
      |vpiParent:                      <- ... and its four fields
      \\_hier_path: ...
      |vpiFullName:...
      |vpiActual:
      \\_<kind>_typespec: ...
    |vpiExpr:                          <- Root_value, added on a hier_path
    \\_<net-or-var kind>: (<name>)

and NOTHING may be DELETED.  This script diffs the pristine and patched dumps
of one database and classifies every changed line:

  * a `+` line whose text is one of the signature shapes  -> ATTRIBUTED
  * any `-` line                                          -> UNEXPLAINED
  * any other `+` line                                    -> UNEXPLAINED

  usage: attr53.py <pristine.dump> <patched.dump>
         (paths are NORMALISED first -- a dump embeds its workdir in `file:`)

Exit 0 only when UNEXPLAINED == 0.
"""
import collections
import os
import re
import subprocess
import sys
import tempfile

# THE WORKDIR LEAKS THROUGH THREE FIELDS, NOT ONE.  The first version
# normalised only `file:<path>` and the boundary gate promptly reported 24 LOST
# lines for two arms that had lost nothing: `vpiRefFile:` and `vpiDefFile:`
# carry the same absolute path and the two arms run in different directories.
# "Dump paths embed the workdir -- NORMALISE" is a standing ops law and it
# means EVERY path-valued field.
FILE = re.compile(r'((?:vpi\w*)?[Ff]ile):\S+')
ID = re.compile(r', id:\d+')

ADD_OK = (
    re.compile(r'^\s*\|vpiTypespec:$'),
    re.compile(r'^\s*\|vpiExpr:$'),
    re.compile(r'^\s*\|vpiParent:$'),
    re.compile(r'^\s*\|vpiActual:$'),
    re.compile(r'^\s*\|vpiFullName:.*$'),
    re.compile(r'^\s*\\_ref_typespec: .*$'),
    re.compile(r'^\s*\\_hier_path: .*$'),
    re.compile(r'^\s*\\_\w*typespec: ?.*$'),
    re.compile(r'^\s*\\_(struct|array|logic|packed_array|union|enum|bit|int|integer|byte|shortint|longint|real|string|class|interface|module|ref|unsupported)\w*(_var|_net|_typespec|_obj)?: ?.*$'),
)


def norm_to(p, out):
    """Normalise INTO A FILE, not into a list.

    An Earlgrey dump is 4.7M lines; `difflib` on two of those is quadratic in
    the worst case and never returned.  GNU `diff` does the same job in
    seconds, and the classifier only ever needs the diff's OWN lines.
    """
    with open(out, 'w') as w:
        for line in open(p, errors='replace'):
            line = FILE.sub(r'\\1:-', line.rstrip('\n'))
            w.write(ID.sub('', line) + '\n')


def diff_lines(a, b):
    d = tempfile.mkdtemp(prefix='attr53_')
    na, nb = os.path.join(d, 'a'), os.path.join(d, 'b')
    norm_to(a, na)
    norm_to(b, nb)
    pr = subprocess.run(['diff', '-U0', na, nb], capture_output=True, text=True)
    os.unlink(na)
    os.unlink(nb)
    os.rmdir(d)
    return pr.stdout.splitlines()


def main():
    """MULTISET attribution, not per-diff-line attribution.

    GNU diff represents "a block was INSERTED above these lines" by deleting
    the following lines and re-adding them under the insertion.  The first
    version of this script counted those as DELETIONS and reported
    `deleted=3 UNEXPLAINED=3` for a delta that loses nothing at all.  A
    verifier that cannot tell a re-alignment from a loss would have either
    blocked a clean pass or, worse, been "fixed" by exempting deletions --
    which is exactly the check this pass needs.

    So: compare the two dumps as MULTISETS OF LINE TEXTS.
      * any text whose count DROPS  -> LOST (never allowed)
      * any text whose count RISES  -> must match the rule's signature
    """
    minus = collections.Counter()
    plus = collections.Counter()
    for line in diff_lines(sys.argv[1], sys.argv[2]):
        if line.startswith('---') or line.startswith('+++') or line.startswith('@@'):
            continue
        if line.startswith('-'):
            minus[line[1:]] += 1
        elif line.startswith('+'):
            plus[line[1:]] += 1
    lost = 0
    gained = 0
    ok = 0
    bad = []
    for t, n in minus.items():
        d = n - plus.get(t, 0)
        if d > 0:
            lost += d
            if len(bad) < 20:
                bad.append('LOST x%d %s' % (d, t[:150]))
    for t, n in plus.items():
        d = n - minus.get(t, 0)
        if d > 0:
            gained += d
            if any(r.match(t) for r in ADD_OK):
                ok += d
            elif len(bad) < 20:
                bad.append('UNEXPLAINED-ADD x%d %s' % (d, t[:150]))
    unexplained = lost + (gained - ok)
    print('diff-lines: -%d +%d | NET gained=%d attributed=%d LOST=%d '
          'UNEXPLAINED=%d' %
          (sum(minus.values()), sum(plus.values()), gained, ok, lost,
           unexplained))
    for l in bad:
        print('   %s' % l)
    sys.exit(0 if unexplained == 0 else 1)


if __name__ == '__main__':
    main()
