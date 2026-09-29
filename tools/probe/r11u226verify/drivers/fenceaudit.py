#!/usr/bin/env python3
# (r11u226: extended from r11u221verify/drivers/fenceaudit.py with the tool-guard and scratch-path columns.)
# fenceaudit.py [dir...]: a static audit of every driver of the given tools/probe evidence directories (default: the six
# directories of passes 219, 220 and 223 and their verifiers).  Per driver:
#   ENV   sources an env.sh (which fails closed on the fence) or checks $FENCED's four names itself
#   FILT  names $FENCED / a fence regex (a filter, a skip, a --filter)
#   CORP  touches corpus sources or sweep databases (a corpus path, slang.uhdm, a sweep workdir, verify_golden, downstream)
#   TOOLS the tool variables a SHELL line runs as a command word ($UHDM_CMP a.uhdm ...), with the guard found for each:
#         x = an explicit [ -x "$V" ] / ${V:?} / test in this file or its env.sh; lit = the env.sh it sources assigns V an
#         absolute literal path (set if env.sh ran); NONE = neither (an unset V makes the shell execute the first
#         argument, a .uhdm database, as a script: passes 223 and map 14).  Python drivers pass the tool as argv[0]
#         (an unset variable raises; no database runs as a script) and are listed py.
#   TMP   absolute /tmp paths outside comments (what the driver needs to re-run).
# Never prints a fenced name.
import os, re, sys
R = os.path.realpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../..'))
dirs = sys.argv[1:] or ['r11u219repro', 'v11u219repro', 'r11u220repro', 'v11u220repro', 'r11u223repro', 'v11u223repro']
corp = re.compile(r'third_party|slang\.uhdm|golden\.uhdm|/surelog/|uhdm2rtlil|verify_golden|downstream_uhdm2rtlil|tests/sweep\.sh|\$W/|workdir|sweep', re.I)
TOOLV = ['UHDM_CMP', 'UHDM_DUMP', 'SURELOG', 'STRICT_CMP', 'SCMP', 'SC', 'STRICTCMP', 'STRICT', 'SLANG_UHDM', 'LAW', 'FIX',
         'PRIS', 'BIN', 'b', 'bin', 'X', 'CMP', 'DUMP', 'SX', 'STRICTX', 'YOSYS']
cmdpos = r'(?:^|[;&|(`]|\$\(|\bthen\b|\bdo\b|\belse\b|\btimeout\s+\d+|\benv\b(?:\s+\S+=\S*)*|\bexec\b|\btime\b|\bnice\b)\s*'
def env_assigns(envp):
    lit, guard = set(), set()
    if not os.path.exists(envp): return lit, guard
    t = open(envp, errors='replace').read()
    for v in TOOLV:
        if re.search(rf'\b{v}=["\']?(/|\$\{{?HOME|\$R|\$\{{{v}:-/)', t): lit.add(v)
        if re.search(rf'-x\s+"?\$\{{?{v}\}}?"?|\$\{{{v}:\?|\[\s*-x\s+"\$\{{!_v\}}"', t) or (re.search(r'-x "\$\{!_v\}"', t) and re.search(rf'\b{v}\b', t)): guard.add(v)
    return lit, guard
for d in dirs:
    dd = f'{R}/tools/probe/{d}/drivers'
    elit, eguard = env_assigns(f'{dd}/env.sh')
    for root, _, files in os.walk(dd):
        for fn in sorted(files):
            p = os.path.join(root, fn)
            if fn.endswith(('.pyc', '.o')) or not os.path.isfile(p): continue
            t = open(p, errors='replace').read()
            lines = t.splitlines()
            body = '\n'.join(l for l in lines if not l.lstrip().startswith('#'))
            env = bool(re.search(r'env\.sh', body)) or bool(re.search(r"FENCED.*(wc -w|len\(|!= 4|= 4|== 4)", body)) or fn == 'env.sh'
            filt = bool(re.search(r'FENCE(D|_RE|RE)', body))
            cp = bool(corp.search(body))
            shell = fn.endswith('.sh') or t.startswith('#!/bin/bash') or t.startswith('#!/usr/bin/env bash')
            tools = []
            if shell:
                used = set()
                for l in lines:
                    s = l.strip()
                    if s.startswith('#'): continue
                    for m in re.finditer(cmdpos + r'"?\$\{?([A-Za-z_]+)\}?"?\s+(?=[^=\s])', s):
                        v = m.group(1)
                        if v in TOOLV: used.add(v)
                for v in sorted(used):
                    own = re.search(rf'-x\s+"?\$\{{?{v}\}}?"?|\$\{{{v}:\?', t)
                    g = 'x' if (own or (v in eguard and 'env.sh' in body)) else 'lit' if (v in elit and 'env.sh' in body) or (fn == 'env.sh' and v in elit) else 'NONE'
                    tools.append(f'{v}:{g}')
            else:
                tools = ['py'] if re.search(r'subprocess', body) else []
            tmp = sorted(set(re.findall(r'/tmp/[A-Za-z0-9_.\-/]*', body)))
            print(f"{d}/drivers/{os.path.relpath(p, dd)} ENV={'y' if env else 'N'} FILT={'y' if filt else 'N'} CORP={'y' if cp else 'n'} TOOLS={','.join(tools) or '-'} TMP={','.join(tmp) or '-'}")
