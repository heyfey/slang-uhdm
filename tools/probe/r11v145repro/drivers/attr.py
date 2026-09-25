import sys,os,re,glob,shlex,subprocess,hashlib,concurrent.futures
sys.path.insert(0,'/tmp/wt_v11u145/scripts')
import verify_golden as vg
V=['pristine','law','sw_OFF','sw_DEFFILLIMP_OFF','sw_UNSPARAMTS_OFF','sw_PSBAREREF_OFF','sw_UNARYOWN_OFF','sw_LPBOUNDOWN_OFF','sw_BASESELOP_OFF','sw_IMPARITH_OFF']
movers=[l.split() for l in open('/tmp/v11u145_s/byte_movers.lst')]
disc={'surelog':vg.discover_surelog(None),'uhdm2rtlil':vg.discover_uhdm2rtlil(None)}
def run(m):
    corpus,name,mode=m
    d=[x for x in glob.glob(f'/tmp/v11u145_wdP/{corpus}/{mode}/{name}-*') if re.fullmatch(re.escape(name)+r'-[0-9a-f]{8}',os.path.basename(x))][0]
    line=[l for l in open(d+'/cmds.txt') if l.startswith('slang:')][0][len('slang:'):].strip()
    argv=shlex.split(line); oi=argv.index('-o')
    dirpath=disc[corpus][name][0]
    res={}
    k=hashlib.md5(f'{corpus}{name}{mode}'.encode()).hexdigest()[:10]
    for i,v in enumerate(V):
        out=f'/tmp/v11u145_s/att/{k}/v{i:02d}.uhdm'; os.makedirs(os.path.dirname(out),exist_ok=True)
        if os.path.exists(out): os.unlink(out)
        a=['/tmp/v11u145_bin/'+v]+argv[1:oi]+['-o',out]+argv[oi+2:]
        subprocess.run(a,cwd=dirpath,capture_output=True,timeout=900)
        res[v]=hashlib.md5(open(out,'rb').read()).hexdigest()[:10] if os.path.exists(out) else 'NONE'
    laws=[v[3:-4] for v in V[3:] if res[v]!=res['law']]
    restore=[v[3:-4] for v in V[3:] if res[v]==res['pristine']]
    return f"{corpus} {name} {mode} law!=pris={res['law']!=res['pristine']} OFF==pris={res['sw_OFF']==res['pristine']} switches_that_move={','.join(laws) or '-'} single_switch_restores={','.join(restore) or '-'}"
with concurrent.futures.ThreadPoolExecutor(3) as ex:
    for r in ex.map(run,movers): print(r,flush=True)
