#!/usr/bin/env python3
# r11u43 — A-PRIORI MOVER PREDICTION, from the PRISTINE emission.
#
# Re-runs the NEUTRAL binary (R11U43_OFF=1, which writes pristine bytes —
# proved byte-identical on all 84 grid arms) with R11U43_CELLDBG=1 over the
# EXACT command line each corpus row recorded in its own cmds.txt, and names
# every test whose emission reaches the law's claim.  Because the claim is
# computed OUTSIDE the A/B switch, this names the movers before the law binary
# is ever run over the corpus.
#
# The binary is taken from argv, NEVER from SLANG_UHDM: the harness silently
# defaults that variable to the main-tree binary.
#
# POSITIVE CONTROL: run with CTL=1 to invert the claim's expectation — the
# scan must then find the trace lines it would otherwise report zero of, which
# is what proves the census can SEE (a census zero needs a positive control).
import os, re, shlex, subprocess, sys

def main():
    binpath, workroot, srcroot, out = sys.argv[1:5]
    rows, n, nocmd, cells_total = [], 0, 0, 0
    for mode in sorted(os.listdir(workroot)):
        mroot = os.path.join(workroot, mode)
        if not os.path.isdir(mroot):
            continue
        for wd in sorted(os.listdir(mroot)):
            d = os.path.join(mroot, wd)
            cf = os.path.join(d, 'cmds.txt')
            if not os.path.isfile(cf):
                nocmd += 1
                continue
            m = re.search(r'^slang:\s+(.*)$', open(cf).read(), re.M)
            if not m:
                nocmd += 1
                continue
            argv = shlex.split(m.group(1))
            n += 1
            name = wd.rsplit('-', 1)[0]
            cwd = os.path.join(srcroot, name)
            if not os.path.isdir(cwd):
                cwd = srcroot
            argv = [binpath] + argv[1:]
            try:
                i = argv.index('-o')
                argv[i + 1] = os.path.join(d, 'pred43.uhdm')
            except ValueError:
                pass
            env = dict(os.environ, R11U43_OFF='1', R11U43_CELLDBG='1')
            try:
                r = subprocess.run(argv, cwd=cwd, capture_output=True,
                                   text=True, timeout=1200, env=env)
                err = r.stderr
                rc = r.returncode
            except subprocess.TimeoutExpired:
                err, rc = '', 'TIMEOUT'
            cells = re.findall(r'R11U43CELL site=(\S+) .*claim=(\d)', err)
            cells_total += len(cells)
            hit = [s for s, c in cells if c == '1']
            if hit:
                rows.append((name, mode, len(cells), len(hit),
                             ','.join(sorted(set(hit)))))
            try:
                os.unlink(os.path.join(d, 'pred43.uhdm'))
            except OSError:
                pass
    with open(out, 'w') as f:
        f.write('binary   %s\n' % binpath)
        f.write('workroot %s\n' % workroot)
        f.write('rows with a cmds.txt: %d   (no slang line: %d)\n' % (n, nocmd))
        f.write('CELL trace lines seen: %d  (the census POSITIVE CONTROL: a '
                'zero here would mean the scan is blind)\n' % cells_total)
        for r in sorted(rows):
            f.write('PREDICTED %s %s cells=%d claims=%d sites=%s\n' % r)
        f.write('PREDICTED MOVER TESTS: %d\n' % len(rows))
    sys.stdout.write(open(out).read())

main()
