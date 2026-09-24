import sys,subprocess
from concurrent.futures import ThreadPoolExecutor
cs=[l.strip() for l in open(sys.argv[1]) if l.strip()]
def one(c): return subprocess.run(['python3','/tmp/r11u141_drv/case.py',c,'ON=','A3=R11U130_OFF,R11U131_OFF,R11U134_OFF'],capture_output=True,text=True).stdout.strip()
with ThreadPoolExecutor(3) as ex, open(sys.argv[2],'w') as f:
    for l in ex.map(one,cs): f.write(l+'\n')
