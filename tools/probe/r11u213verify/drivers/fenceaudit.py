#!/usr/bin/env python3
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208) fenceaudit.py [dir...]: a static audit of every driver of the given tools/probe evidence directories
# (default, r11u213: r11u206repro v11u206repro r11u207repro v11u207repro).  Per driver: ENV = sources the directory's env.sh
# (which fails closed on the fence) or checks $FENCED's four names itself; FILT = names $FENCED / a fence regex in a
# filter (grep -v, a skip, --filter); CORP = touches corpus sources or sweep databases (a corpus path, slang.uhdm, a
# sweep workdir, verify_golden / downstream); RELW = a write whose target is a bare relative path (a redirection,
# -o, open(...,'w'), cp/mv/mkdir target) - each hit printed for reading by hand.  Never prints a fenced name.
import os, re, sys
R = os.path.realpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../..'))
dirs = sys.argv[1:] or ['r11u206repro', 'v11u206repro', 'r11u207repro', 'v11u207repro']   # r11u213
rel = re.compile(r"""(?:(?<![<>&0-9])>{1,2}\s*|\s-o\s+|open\(\s*['"]|\b(?:mkdir(?:\s+-p)?|cp(?:\s+-\w+)*\s+\S+|mv\s+\S+)\s+)(?!/|\$|~|&|-|\(|"\$|'\$|\{|/dev)([A-Za-z_][\w.\-]*(?:/[\w.\-]*)?)(?=[\s;'")|]|$)""")
corp = re.compile(r'third_party|slang\.uhdm|golden\.uhdm|/surelog/|uhdm2rtlil|verify_golden|downstream_uhdm2rtlil|tests/sweep\.sh|\$W/|workdir|sweep', re.I)
for d in dirs:
    dd = f'{R}/tools/probe/{d}/drivers'
    for fn in sorted(os.listdir(dd)):
        p = f'{dd}/{fn}'
        if not os.path.isfile(p) or fn.endswith('.pyc'):
            continue
        t = open(p, errors='replace').read()
        body = '\n'.join(l for l in t.splitlines() if not l.lstrip().startswith('#'))
        env = bool(re.search(r'env\.sh', body)) or bool(re.search(r"FENCED.*(wc -w|len\(|!= 4|= 4|== 4)", body)) or fn == 'env.sh'
        filt = bool(re.search(r'FENCE(D|_RE|RE)', body))
        cp = bool(corp.search(body))
        hits = []
        for i, l in enumerate(t.splitlines(), 1):
            s = l.lstrip()
            if s.startswith('#') or s.startswith('"""'):
                continue
            for m in rel.finditer(l):
                w = m.group(1)
                if w in ('null', 'x', 'i', 'n', 'w', 'r', 'a') or w.isdigit():
                    continue
                hits.append(f'{i}:{w}')
        print(f"{d}/drivers/{fn} ENV={'y' if env else 'N'} FILT={'y' if filt else 'N'} CORP={'y' if cp else 'n'} RELW={','.join(hits) if hits else '-'}")
