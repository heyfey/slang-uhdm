#!/usr/bin/env python3
# (r11u213: adapted from v11u207repro/drivers/calls.py) calls.py <name> <db>...: every func_call / task_call /
# method_func_call NAMED <name> with its link and its argument list (object kind, name, value), per database, in dump
# order.  Reads only the databases given (case databases; never a corpus database).
import sys, subprocess, re, os
name = sys.argv[1]
def calls(f):
    t = subprocess.run([os.environ['UHDM_DUMP'], f], capture_output=True, text=True, errors='replace').stdout.split('\n')
    out = []
    for i, l in enumerate(t):
        m = re.match(r'^(\s*)\\_(func_call|task_call|method_func_call|method_task_call): \(' + name + r'\), line:(\S+), endln:(\S+)', l)
        if not m: continue
        ind = len(m.group(1)); args = []; fn = ''
        j = i + 1
        while j < len(t) and (len(t[j]) - len(t[j].lstrip())) > ind:
            s = t[j].strip()
            if s == '|vpiArgument:':
                a = t[j + 1].strip(); v = ''
                k = j + 2
                while k < len(t) and (len(t[k]) - len(t[k].lstrip())) > (len(t[j + 1]) - len(t[j + 1].lstrip())):
                    if re.match(r'\|(UINT|INT|STRING|REAL|BIN|HEX):', t[k].strip()): v = t[k].strip()
                    k += 1
                args.append(re.sub(r', id:\d+', '', a) + v)
            if s in ('|vpiFunction:', '|vpiTask:'): fn = t[j + 1].strip()
            j += 1
        out.append(f'{m.group(2)} {m.group(3)} [{re.sub(r", id:[0-9]+", "", fn)[:60]}] ' + ' | '.join(args))
    return out
for f in sys.argv[2:]:
    print('==', f)
    for c in calls(f): print('  ', c)
