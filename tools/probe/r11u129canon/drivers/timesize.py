#!/usr/bin/env python3
"""timesize.py <pairs.tsv> <strictcmp> <corpus/test/mode>...: question 4. For each row and mode 2, 3, 4:
verdict, records per side (the --dump files counted through a pipe, nothing kept), wall seconds, and the
child's peak RSS (one child at a time, so ru_maxrss of RUSAGE_CHILDREN after each run is that run's peak
only if it exceeds the earlier ones: each run is measured in its own forked python)."""
import os, subprocess, sys, time
pairs, sc, keys = sys.argv[1], sys.argv[2], sys.argv[3:]
P = {}
for l in open(pairs):
    f = l.rstrip('\n').split('\t'); P['/'.join([f[0], f[2], f[1]])] = (f[3], f[4])
for k in keys:
    if k not in P: print(k, 'unresolved'); continue
    g, o = P[k]
    for m in ('2', '3', '4'):
        r, w = os.pipe()
        pid = os.fork()
        if pid == 0:
            os.close(r)
            import resource
            ra, wa = os.pipe(); rb, wb = os.pipe()
            t0 = time.time()
            p = subprocess.Popen([sc, '--max', '0', '--canon-fullname', m, '--dump-a', f'/dev/fd/{wa}', '--dump-b', f'/dev/fd/{wb}', g, o],
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT, pass_fds=(wa, wb))
            os.close(wa); os.close(wb)
            import threading
            cnt = {}
            def count(fd, key):
                n = 0
                with os.fdopen(fd, 'rb') as fh:
                    for chunk in iter(lambda: fh.read(1 << 20), b''): n += chunk.count(b'\n')
                cnt[key] = n
            ta = threading.Thread(target=count, args=(ra, 'a')); tb = threading.Thread(target=count, args=(rb, 'b'))
            ta.start(); tb.start()
            out = p.communicate()[0].decode(errors='replace').strip().splitlines()
            ta.join(); tb.join()
            wall = time.time() - t0
            rss = resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss
            os.write(w, f"{k}\tm{m}\t{out[-1] if out else ''}\trecsA={cnt.get('a')}\trecsB={cnt.get('b')}\twall_s={wall:.1f}\tpeak_rss_MB={rss // 1024}\n".encode())
            os._exit(0)
        os.close(w)
        os.waitpid(pid, 0)
        with os.fdopen(r) as fh: sys.stdout.write(fh.read()); sys.stdout.flush()
