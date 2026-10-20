import sys, os
base = sys.argv[1]
cur = None; buf = []
def flush():
    if cur:
        os.makedirs(os.path.join(base, cur), exist_ok=True)
        open(os.path.join(base, cur, 'dut.sv'), 'w').write(''.join(buf))
for line in sys.stdin:
    if line.startswith('=== '):
        flush(); cur = line[4:].strip(); buf = []
    else:
        buf.append(line)
flush()
