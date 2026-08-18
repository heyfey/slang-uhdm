#!/usr/bin/env python3
"""r10earl61 -- extract every assignment-pattern (op75) block at a given span
and summarise its tagged_pattern members.

  usage: ptblock61.py <dump> <span e.g. 129:17, endln:142:4> [ownerSubstring]

Emits one line per MEMBER: pattern-name | value kind | value | size | constType
| span, grouped per block occurrence, with the dump section (DEF/ELAB/TAIL) and
the enclosing owner line so the two views can be told apart.
"""
import re, sys

HDR = re.compile(r'^( *)\\_([A-Za-z_0-9]+): (.*)$')
REL = re.compile(r'^( *)\|([A-Za-z_0-9]+):(.*)$')

def sectionof(rel):
    if rel.startswith('uhdmall'):  return 'DEF'
    if rel.startswith('uhdmtop'):  return 'ELAB'
    if rel == 'weaklyReferenced':  return 'TAIL'
    return None

def main():
    path, span = sys.argv[1], sys.argv[2]
    want = sys.argv[3] if len(sys.argv) > 3 else ''
    key = '\\_operation: , line:%s' % span
    section = 'PRE'; cur_rel = None
    block = None; bcol = 0; nblk = 0
    for line in open(path, errors='replace'):
        line = line.rstrip('\n')
        if line == '\\_weaklyReferenced:':
            section = 'TAIL'
        m = HDR.match(line)
        if m and len(m.group(1)) == 0:
            s = sectionof(cur_rel or '')
            if s: section = s
        m2 = REL.match(line)
        if m2 and len(m2.group(1)) == 0 and m2.group(3) == '':
            cur_rel = m2.group(2)
        if block is not None:
            if (m and len(m.group(1)) <= bcol) or (m2 and len(m2.group(1)) <= bcol):
                emit(block, want); block = None
            else:
                block.append(line)
        if block is None and line.strip().startswith(key.strip()):
            bcol = len(line) - len(line.lstrip()); block = [section + ' ' + line]
            nblk += 1
    if block is not None: emit(block, want)
    sys.stderr.write('%s: %d blocks at %s\n' % (path, nblk, span))

def emit(block, want):
    txt = '\n'.join(block)
    if want and want not in txt: return
    print('==== BLOCK', block[0].split()[0])
    # walk members: a tagged_pattern header, then its |vpiPattern (name) and the
    # value object that follows
    cur = None
    for ln in block:
        m = HDR.match(ln)
        if not m:
            mm = REL.match(ln)
            if mm and cur is not None and mm.group(3):
                cur.setdefault(mm.group(2), mm.group(3))
            continue
        kind, hdr = m.group(2), m.group(3)
        if kind == 'tagged_pattern':
            if cur: pr(cur)
            cur = {'_members': [], '_span': hdr}
        elif cur is not None:
            cur['_members'].append((kind, re.sub(r', file:[^,]*', '', hdr)))
    if cur: pr(cur)

def pr(cur):
    ms = cur['_members']
    name = ms[1][1] if len(ms) > 1 else '?'
    print('  member %-70s' % name[:70])
    for k, h in ms[2:6]:
        print('      %-12s %s' % (k, h))

if __name__ == '__main__':
    main()
