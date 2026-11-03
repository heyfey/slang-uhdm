#!/usr/bin/env python3
# timeit.py <tag> <cmd...>: wall time, max child RSS (MB) and exit code
import sys, subprocess, time, resource
t=time.time(); r=subprocess.run(sys.argv[2:], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
ru=resource.getrusage(resource.RUSAGE_CHILDREN)
print(f"{sys.argv[1]} {time.time()-t:.1f} s {ru.ru_maxrss/1024:.0f} MB rc={r.returncode}")
