# runs the worktree's scripts/check_svtests.py with UVM read from the main
# checkout (the worktree's submodule dirs are empty by rule)
import sys, runpy
sys.path.insert(0, '/tmp/wt_r11u435/scripts')
import check_svtests as cs
cs.UVM_DIR = '/home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0'
sys.argv = ['check_svtests.py'] + sys.argv[1:]
sys.exit(cs.main())
