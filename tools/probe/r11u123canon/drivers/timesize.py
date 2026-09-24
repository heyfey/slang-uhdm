#!/usr/bin/env python3
"""Time and peak RSS of uhdm-strictcmp raw vs canonical on named rows (no dumps,
--max 0, one process at a time).  usage: timesize.py <pairs.tsv> <regex over corpus/mode/test>"""
import os, re, resource, subprocess, sys, time
SC = '/tmp/r11u123_bin/uhdm-strictcmp'
rx = re.compile(sys.argv[2])
print('row\tmode\traw_s\traw_rss_mb\tcanon_s\tcanon_rss_mb\traw_tail\tcanon_tail')
for l in open(sys.argv[1]):
    f = l.rstrip('\n').split('\t')
    k = '/'.join(f[:3])
    if not rx.search(k):
        continue
    out = []
    for x in (['--no-canon'], []):
        pid = os.fork()
        if pid == 0:
            fd = os.open('/tmp/r11u123_ts.out', os.O_WRONLY | os.O_CREAT | os.O_TRUNC)
            os.dup2(fd, 1); os.dup2(fd, 2)
            os.execv(SC, [SC, '--max', '0'] + x + [f[5], f[6]])
        t0 = time.time()
        _, st, ru = os.wait4(pid, 0)
        dt = time.time() - t0
        tail = open('/tmp/r11u123_ts.out').read().strip().splitlines()[-1]
        out += [f'{dt:.2f}', f'{ru.ru_maxrss / 1024:.0f}', tail]
    print('\t'.join([f[0] + '/' + f[2], f[1], out[0], out[1], out[3], out[4], out[2], out[5]]), flush=True)
