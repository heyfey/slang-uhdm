import sys,collections,re
def ms(f):
    L=[re.sub(r'^\S+uhdm: ','',l.rstrip()) for l in open(f)][1:]
    return collections.Counter(L)
g=ms(sys.argv[1])
for f in sys.argv[2:]:
    o=ms(f); d=sum(((g-o)+(o-g)).values()); print(f.split('/')[-1], d, end='  ')
print()
