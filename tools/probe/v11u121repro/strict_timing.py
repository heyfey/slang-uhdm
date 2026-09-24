import csv, glob, os, re, subprocess, sys, time
env = dict(l.split('=', 1) for l in open('/tmp/v11u121_env.sh').read().replace('export ', '').split())
CMP = env['UHDM_CMP']; DUMP = env['UHDM_DUMP']
S = '/home/heyfey/git-repos/slang-uhdm/build/uhdm-strictcmp'
W, CSV, OUT = sys.argv[1:4]


def t(cmd):
    a = time.monotonic()
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return time.monotonic() - a


tot = [0.0, 0.0, 0.0]; n = 0
with open(OUT, 'w') as o:
    for r in csv.DictReader(open(CSV)):
        if r['status'] != 'CMP_EQUAL':
            continue
        ds = glob.glob(f"{W}/{r['mode']}/{glob.escape(r['name'])}-*")
        if not ds or not os.path.exists(ds[0] + '/slang.uhdm'):
            continue
        m = re.search(r'slang-uhdm-goldens/[0-9a-f]+', open(ds[0] + '/cmds.txt').read())
        if not m:
            continue
        g = os.path.expanduser('~/.cache/' + m.group(0) + '/golden.uhdm'); s = ds[0] + '/slang.uhdm'
        if not os.path.exists(g):
            continue
        x = [t([CMP, g, s]), t([S, '--max', '0', g, s]), t([DUMP, s])]
        for i in range(3):
            tot[i] += x[i]
        n += 1
        o.write(f"{r['name']},{r['mode']},{x[0]:.3f},{x[1]:.3f},{x[2]:.3f}\n"); o.flush()
print(f"rows={n} uhdm-cmp={tot[0]:.1f}s strictcmp={tot[1]:.1f}s uhdm-dump(slang)={tot[2]:.1f}s")
