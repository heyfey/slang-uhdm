#!/usr/bin/env python3
# depth-keyed identity census of class_typespec (and any kind) objects:
# key = path of ancestor "kind(name)" through the dump tree, value = the object's name.
import re, sys, collections
OBJ = re.compile(r'^(\s*)\\_([a-zA-Z_]+): (\(([^)]*)\))?')
def census(path, kinds):
    out = collections.Counter()
    stack = []  # (indent, label)
    for line in open(path, errors='replace'):
        m = OBJ.match(line.rstrip('\n'))
        if not m: continue
        ind = len(m.group(1)); kind = m.group(2); nm = m.group(4) or ''
        while stack and stack[-1][0] >= ind: stack.pop()
        label = f'{kind}({nm})'
        if kind in kinds:
            p = '/'.join(x[1] for x in stack[-3:])
            out[f'{p} => {label}'] += 1
        stack.append((ind, label))
    return out
if __name__ == '__main__':
    kinds = set(sys.argv[1].split(','))
    for f in sys.argv[2:]:
        c = census(f, kinds)
        with open(f + '.cen', 'w') as fh:
            for k in sorted(c): fh.write(f'{c[k]}\t{k}\n')
        print(f, sum(c.values()), len(c))
