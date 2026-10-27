import re,sys
for l in open(sys.argv[1]):
    f=l.rstrip('\n').split('\t')
    def g(x):
        m=re.search(r'rc=(\S+) cmp=(\S+) dist=(\S+) md5=(\S*) \[(.*)\]',x); return m.groups()
    p,la,v=g(f[2]),g(f[3]),g(f[4])
    tag='law=pris' if la[3]==p[3] and la[0]==p[0] else 'LAWMOVED'
    vt='ver=law' if v[3]==la[3] and v[0]==la[0] else ('ver=pris' if v[3]==p[3] and v[0]==p[0] else 'VERMOVED')
    if len(sys.argv)>2 or tag!='law=pris' or vt!='ver=law':
        print(f[0],f[1],'p',p[0],p[1],p[2],p[4][:16],'| l',la[0],la[1],la[2],la[4][:16],'| v',v[0],v[1],v[2],v[4][:16],tag,vt)
