import sys,re,subprocess
D='/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump'
def pas(f):
    out=subprocess.run([D,f],capture_output=True,text=True).stdout.splitlines()
    res=[]
    for i,l in enumerate(out):
        m=re.match(r'^(\s*)\\_param_assign: , (.*)$',l)
        if not m: continue
        ind=len(m.group(1)); rhs=None; lhs=None; val=None
        for j in range(i+1,min(i+40,len(out))):
            l2=out[j]
            if re.match(r'^\s*\\_param_assign',l2) and len(l2)-len(l2.lstrip())<=ind: break
            if rhs is None and re.search(r'\\_(constant|sys_func_call|operation|ref_obj)',l2) and 'vpiRhs' in out[j-1]:
                rhs=l2.strip()
            if rhs and val is None and re.search(r'\|(U?INT|BIN|HEX|DEC):',l2): val=l2.strip()
            if 'vpiLhs' in l2:
                lhs=out[j+1].strip(); break
        res.append((lhs,rhs,val))
    return res
for f in sys.argv[1:]:
    print('==',f)
    for r in pas(f): print('  ',r)
