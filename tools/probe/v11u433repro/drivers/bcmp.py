import sys
# bcmp.py key tagA tagB : byte-compare two outputs with the tag dir normalized
k,a,b=sys.argv[1:4]
base='/tmp/v11u433_scr/out/%s/'%k
A=open(base+a+'/ours.uhdm','rb').read().replace(('/%s/%s/'%(k,a)).encode(),b'/K/T/')
B=open(base+b+'/ours.uhdm','rb').read().replace(('/%s/%s/'%(k,b)).encode(),b'/K/T/')
print('same' if A==B else 'MOVED')
