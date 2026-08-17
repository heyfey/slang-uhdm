#!/usr/bin/env python3
"""r10buvm4 — print every CALL node in a uhdm-dump with its vpiArgument list
compacted to one line, so golden and ours can be read side by side.

Each argument prints as its vpiDecompile when it has one, else its object kind;
an argument with NO line: span prints [NOLOC] (that is how golden's
formal-slot PLACEHOLDER constant is recognised)."""
import re, sys
CALL = re.compile(r'\\_(method_func_call|func_call|task_call|method_task_call): \(([^)]*)\)(, line:(\d+):(\d+))?')
def go(path):
    lines = open(path).read().split('\n')
    seen, out = set(), []
    for i, l in enumerate(lines):
        m = CALL.search(l)
        if not m:
            continue
        ind = len(l) - len(l.lstrip())
        args = []
        j = i + 1
        while j < len(lines):
            l2 = lines[j]
            if l2.strip() and len(l2) - len(l2.lstrip()) <= ind:
                break
            if len(l2) - len(l2.lstrip()) == ind + 2 and l2.strip() == '|vpiArgument:':
                o = lines[j + 1].strip()
                dec = None
                k = j + 2
                while k < len(lines):
                    l3 = lines[k]
                    if len(l3) - len(l3.lstrip()) <= ind + 2:
                        break
                    if '|vpiDecompile:' in l3 and dec is None:
                        dec = l3.split('|vpiDecompile:')[1]
                    k += 1
                kind = o.split(':')[0].replace('\\_', '')
                loc = re.search(r'line:(\d+):(\d+)', o)
                args.append('%s%s' % (dec if dec is not None else kind,
                                      '' if loc else '[NOLOC]'))
            j += 1
        rec = '%-18s %-12s @%-5s %s' % (m.group(1), m.group(2), m.group(4) or '-',
                                        ' | '.join(args))
        if rec not in seen:
            seen.add(rec)
            out.append(rec)
    return out
for p in sys.argv[1:]:
    print('== ' + p)
    for r in go(p):
        print('   ' + r)
