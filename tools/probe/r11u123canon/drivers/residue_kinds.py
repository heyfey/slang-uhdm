#!/usr/bin/env python3
"""Classify every row whose CANONICAL verdict is still structural
(depth / count / type): align canA/canB with GNU diff, take every hunk, and say
for each hunk whether it is an IDENTITY hunk (a pure insertion on one side of
whole subtrees, each of which re-lists an object the same walk listed earlier:
same record, same relative subtree) or a CONTENT hunk (anything else).  For every
hunk: the root kind(s), the walk container (the nearest shallower record) and the
side holding the extra records (A = golden, B = ours).

usage: residue_kinds.py <runall.csv> <dumps dir>  -> TSV on stdout + summary"""
import collections, csv, os, re, subprocess, sys


def load(p):
    out = []
    with open(p, encoding='utf-8', errors='surrogateescape') as f:
        for line in f:
            d, _, rest = line.rstrip('\n').partition('\t')
            out.append((int(d), rest))
    return out


def container(C, i):
    d = C[i][0]
    for k in range(i - 1, -1, -1):
        if C[k][0] < d:
            return C[k][1].split('\t')[0]
    return '-'


def subtrees(C, i, k):
    """Split C[i:k] into whole subtrees at the block's minimum depth; None if not whole."""
    if i >= k:
        return []
    d0 = min(C[x][0] for x in range(i, k))
    if C[i][0] != d0:
        return None
    roots = [x for x in range(i, k) if C[x][0] == d0]
    # the block must also end where the subtree ends (next record not deeper)
    if k < len(C) and C[k][0] > d0:
        return None
    return roots


TS = re.compile(r'(_typespec|^enum_const)$')


def in_canon(C, i):
    """True when a typespec / enum_const encloses record i (walk ancestors by depth)
    with no class_typespec between: the canonical walk re-expands record i at every
    reach of that ancestor, so the other side can only omit it if the relation is absent
    there, or if its object was first visited OUTSIDE a canonical context (the leak)."""
    d = C[i][0]
    for k in range(i - 1, -1, -1):
        if C[k][0] < d:
            kind = C[k][1].split('\t')[0]
            if kind == 'class_typespec':
                return False
            if TS.search(kind):
                return True
            d = C[k][0]
    return False


def earliest_same(C, starts, r, end):
    blk = [(C[x][0] - C[r][0], C[x][1]) for x in range(r, end)]
    for q in starts.get(C[r][1], []):
        if q >= r:
            break
        e = q + 1
        while e < len(C) and C[e][0] > C[q][0]:
            e += 1
        if [(C[x][0] - C[q][0], C[x][1]) for x in range(q, e)] == blk:
            return q
    return None


def relisted(C, first, starts, r, end):
    key = C[r][1]
    idxs = starts.get(key, [])
    blk = [(C[x][0] - C[r][0], C[x][1]) for x in range(r, end)]
    for q in idxs:
        if q >= r:
            break
        e = q + 1
        while e < len(C) and C[e][0] > C[q][0]:
            e += 1
        if [(C[x][0] - C[q][0], C[x][1]) for x in range(q, e)] == blk:
            return 'same-block'
    return 'same-record' if first.get(key, r) < r else 'new'


def analyse(d):
    A, B = load(os.path.join(d, 'canA')), load(os.path.join(d, 'canB'))
    fa, fb = d + '/.ka', d + '/.kb'
    # diff on the full record (depth included)
    with open(fa, 'w') as f:
        f.writelines(f'{x}\t{y}\n' for x, y in A)
    with open(fb, 'w') as f:
        f.writelines(f'{x}\t{y}\n' for x, y in B)
    out = subprocess.run(['diff', fa, fb], capture_output=True, text=True, errors='surrogateescape').stdout
    os.remove(fa); os.remove(fb)
    hunks = []
    for m in re.finditer(r'^(\d+)(?:,(\d+))?([acd])(\d+)(?:,(\d+))?$', out, re.M):
        a1, a2, op, b1, b2 = m.groups()
        a1 = int(a1); a2 = int(a2 or a1); b1 = int(b1); b2 = int(b2 or b1)
        hunks.append((op, a1, a2, b1, b2))
    res = []
    idx = {}
    for side, C in (('A', A), ('B', B)):
        first, starts = {}, {}
        for i, (_, r) in enumerate(C):
            first.setdefault(r, i)
            starts.setdefault(r, []).append(i)
        idx[side] = (first, starts)
    for op, a1, a2, b1, b2 in hunks:
        if op == 'c':
            i = a1 - 1
            res.append(('content', 'A/B', A[i][1].split('\t')[0] + '|' + B[b1 - 1][1].split('\t')[0],
                        container(A, i), a2 - a1 + 1, b2 - b1 + 1))
            continue
        side, C, i, k = ('A', A, a1 - 1, a2) if op == 'd' else ('B', B, b1 - 1, b2)
        roots = subtrees(C, i, k)
        if roots is None:
            res.append(('content', side, C[i][1].split('\t')[0] + '(partial)', container(C, i), k - i, 0))
            continue
        kinds = []
        cls = 'identity'
        for n, r in enumerate(roots):
            end = roots[n + 1] if n + 1 < len(roots) else k
            how = relisted(C, idx[side][0], idx[side][1], r, end)
            if how == 'new':
                cls = 'content'
            elif in_canon(C, r):
                q = earliest_same(C, idx[side][1], r, end)
                if q is not None and not in_canon(C, q):
                    how += '~leak'        # first listed outside a canonical context
                else:
                    how = 'relation-absent'
                    cls = 'content'       # re-expanded here, so the other side lacks the relation
            kinds.append(C[r][1].split('\t')[0] + ('' if how == 'same-block' else '~' + how))
        res.append((cls, side, '+'.join(sorted(set(kinds))), container(C, i), k - i, len(roots)))
    return res


def main():
    rows = [r for r in csv.DictReader(open(sys.argv[1]))
            if r['can_v'].split('(')[0] in ('differ:depth', 'differ:count', 'differ:type')]
    summ = collections.Counter()
    rowcls = collections.Counter()
    print('corpus\tmode\ttest\tcanon\thunks\tidentity_hunks\tcontent_hunks\tfirst_hunk\tidentity kinds (root<container,side)')
    for r in rows:
        d = os.path.join(sys.argv[2], f"{r['corpus']}_{r['mode']}_{r['test']}")
        res = analyse(d)
        ids = [x for x in res if x[0] == 'identity']
        con = [x for x in res if x[0] == 'content']
        for x in ids:
            summ[(x[2], x[3], x[1])] += 1
        rowcls['all-identity' if not con else 'has-content'] += 1
        fh = res[0] if res else ('-',)
        kinds = collections.Counter(f'{x[2]}<{x[3]},{x[1]}' for x in ids)
        print('\t'.join([r['corpus'], r['mode'], r['test'], r['can_v'], str(len(res)), str(len(ids)),
                         str(len(con)), '/'.join(map(str, fh)),
                         '; '.join(f'{k} x{v}' for k, v in kinds.most_common(6))]))
    print('#ROWS', dict(rowcls))
    print('#IDENTITY HUNK KINDS (root kind < walk container, side with the extra records): count')
    for k, v in summ.most_common(40):
        print('#', k, v)


main()
