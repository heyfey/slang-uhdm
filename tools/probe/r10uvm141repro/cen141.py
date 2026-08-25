#!/usr/bin/env python3
"""r10uvm141 — census of CLASS-METHOD objects out of a uhdm-dump.

One row per method object listed under a class_defn's `vpiMethod`, keyed by
  OWNER (the class's vpiFullName) x KIND (function/task) x NAME
and carrying the TOP-LEVEL FIELD NAMES the object prints, so the qualifier+
lifetime stub (`§ qualifiedLifetimeMethodLosesNamePortsBody46`: no name, no
io_decls, no body) can be told apart from a full method WITHOUT keying on any
span or file (our objects and golden's disagree on both by construction).

The row payload is COMPARE-VISIBLE only: field names plus, for vpiVariables,
the NAMES of the variables listed.  Reading `sys.argv[1]` as `-` reads stdin.

  usage: uhdm-dump x.uhdm | cen141.py -            > x.cen
"""
import sys, re

def indent(l):
    return len(l) - len(l.lstrip(' '))

def main():
    src = sys.stdin if sys.argv[1] == '-' else open(sys.argv[1])
    lines = [l.rstrip('\n') for l in src]
    # class_defn stack: remember the enclosing class fullname by indent
    rows = []
    n = len(lines)
    for i, l in enumerate(lines):
        m = re.match(r'^(\s*)\\_(function|task): \(([^)]*)\)(.*)$', l)
        if not m:
            continue
        ind = len(m.group(1))
        # is the PREVIOUS line `|vpiMethod:` at the same indent?
        if i == 0 or lines[i-1].strip() != '|vpiMethod:':
            continue
        if indent(lines[i-1]) != ind:
            continue
        # find the owning class_defn: nearest preceding `\_class_defn:` at ind-2
        owner = '?'
        for j in range(i-1, -1, -1):
            mm = re.match(r'^(\s*)\\_class_defn: \(([^)]*)\)', lines[j])
            if mm and len(mm.group(1)) == ind - 2:
                owner = mm.group(2)
                break
        kind = m.group(2)
        fields = []
        name = ''
        vnames = []
        j = i + 1
        while j < n and indent(lines[j]) > ind:
            s = lines[j].strip()
            if indent(lines[j]) == ind + 2 and s.startswith('|'):
                f = s.split(':', 1)[0][1:]
                fields.append(f)
                if f == 'vpiName':
                    name = s.split(':', 1)[1]
            if indent(lines[j]) == ind + 2 and s.startswith('\\_') and \
               fields and fields[-1] == 'vpiVariables':
                vm = re.match(r'^\\_\w+: \(([^)]*)\)', s)
                vnames.append(vm.group(1) if vm else '?')
            j += 1
        # collapse repeated vector field names into name*count
        out, prev, cnt = [], None, 0
        for f in fields:
            if f == prev:
                cnt += 1
            else:
                if prev is not None:
                    out.append(prev if cnt == 1 else '%s*%d' % (prev, cnt))
                prev, cnt = f, 1
        if prev is not None:
            out.append(prev if cnt == 1 else '%s*%d' % (prev, cnt))
        rows.append('OWNER=%s|KIND=%s|NAME=%s|FIELDS=%s|VARS=%s'
                    % (owner, kind, name, ','.join(out), ','.join(sorted(vnames))))
    for r in rows:
        print(r)

main()
