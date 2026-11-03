import os, sys, json, subprocess, time, resource
sys.path.insert(0, '/tmp/wt_r11u481/scripts/svtests')
import svtests_matrix as sm
SVT='/home/heyfey/git-repos/sv-tests'; rel='generated/black-parrot/bp_unicore.sv'
libs=json.load(open(os.path.join(SVT,'conf','runners','libs.json')))
p=sm.parse_metadata(os.path.join(SVT,'tests',rel)); sm.apply_libs(p, libs, os.path.join(SVT,'third_party'))
args=['--sverilog']+(['--top',p['top_module'].strip()] if p['top_module'].strip() else [])+['-D'+x for x in p['defines']]+['-I'+x for x in p['incdirs']]+p['files']+['--single-unit']
os.makedirs('/tmp/r11u481_bp',exist_ok=True)
t=time.time()
r=subprocess.run([sys.argv[1]]+args+['-o','/tmp/r11u481_bp/o.uhdm'],cwd='/tmp/r11u481_bp',capture_output=True,text=True,timeout=600)
mx=resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss//1024
print('rc',r.returncode,'secs',round(time.time()-t,1),mx)
