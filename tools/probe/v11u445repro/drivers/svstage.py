# usage: SLANG_UHDM=<bin> python3 svstage.py <workdir>   (the sweep's sv-tests stage, run from the worktree's
# scripts with the worktree's results/golden_svtests.csv; only UVM_DIR points at the main checkout's
# bundled UVM tree, read-only, since a worktree's submodule dirs are empty)
import sys, os
sys.path.insert(0, '/tmp/wt_v11u445/scripts')
import check_svtests as m
m.UVM_DIR = '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0'
wd = sys.argv[1]
sys.argv = ['check_svtests.py', '--jobs', '3', '--workdir', wd + '/svtests', '--out', wd + '/svtests.csv',
            '--svtests', '/home/heyfey/git-repos/sv-tests']
m.main()
