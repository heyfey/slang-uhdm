import sys, re
path, fn = sys.argv[1], sys.argv[2]
lines = open(path, errors='replace').read().split('\n')
# top-level package section boundaries: lines starting with '\_package:' at col 0
sec = [i for i,l in enumerate(lines) if l.startswith('\\_package:') or l.startswith('\\_class_defn:') or l.startswith('\\_module_inst:')]
sec.append(len(lines))
out=[]
for si in range(len(sec)-1):
    a,b = sec[si], sec[si+1]
    hdr = lines[a][:70]
    blk = lines[a:b]
    for i,l in enumerate(blk):
        if ('function: (%s)' % fn) in l and l.strip().startswith('\\_function:'):
            # find the return_stmt inside and the next object line after 'vpiCondition' style
            for j in range(i, min(i+120, len(blk))):
                if '\\_return_stmt:' in blk[j]:
                    # the condition is the next '\_<kind>:' line at deeper indent that is not vpiParent target
                    for k in range(j+1, min(j+30, len(blk))):
                        m = re.match(r'^(\s*)\\_([a-z_]+):', blk[k])
                        if m and m.group(2) not in ('return_stmt',) and 'vpiParent' not in blk[k-1]:
                            out.append('%-4d %-60s COND=%s' % (a, hdr, m.group(2)))
                            break
                    break
            break
for o in out: print(o)
print('-- total listings with %s: %d' % (fn, len(out)))
