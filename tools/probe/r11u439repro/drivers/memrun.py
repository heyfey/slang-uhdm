import subprocess, resource, time, sys, shlex
cmd = shlex.split(open(sys.argv[1]).read())
t = time.time()
p = subprocess.run(cmd, capture_output=True, text=True)
el = time.time() - t
ru = resource.getrusage(resource.RUSAGE_CHILDREN)
print(f"rc={p.returncode} elapsed={el:.1f}s maxrss={ru.ru_maxrss/1024:.0f}MB")
err = (p.stderr or '') + (p.stdout or '')
for l in err.splitlines():
    if 'substr' in l or 'error' in l.lower():
        print(l[:200]); break
