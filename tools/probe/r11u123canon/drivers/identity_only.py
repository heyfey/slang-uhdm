#!/usr/bin/env python3
"""Mechanical proof, row by row, that canonicalisation hides only identity.

For every row-mode whose raw walk differs (old != equal) and whose canonical
walk is equal (new == equal), given the four record dumps
  rawA/rawB  = uhdm-strictcmp --no-canon --dump-a/--dump-b  (golden / ours)
  canA/canB  = uhdm-strictcmp            --dump-a/--dump-b
check:
  (1) canA == canB byte for byte (the canonical walks are one sequence C);
  (2) for each side X: rawX is C with WHOLE SUBTREES deleted (a deleted block is
      a record plus every following record deeper than it), every surviving
      record identical in all 14 fields (depth included) and in order;
  (3) every deleted subtree root is a RE-LISTING: its record (all fields but
      depth) already occurred earlier in C (the object, or a copy with equal
      content, was listed before).  Reported too: whether the whole deleted block
      (relative depths, all fields) equals an earlier block (strong form).
If (1)-(3) hold, rawA and rawB differ only by which re-listings each side
omits: an object the walk already listed is shared on one side and a copy with
equal content on the other.  That is an identity difference and nothing else.

usage: identity_only.py <runall.csv> <dumps dir>   (prints one line per row + totals)"""
import csv, os, sys


def load(p):
    out = []
    with open(p, encoding='utf-8', errors='surrogateescape') as f:
        for line in f:
            line = line.rstrip('\n')
            d, _, rest = line.partition('\t')
            out.append((int(d), rest))
    return out


def subtree_end(C, i):
    d = C[i][0]
    k = i + 1
    while k < len(C) and C[k][0] > d:
        k += 1
    return k


def block_key(C, i, k):
    d0 = C[i][0]
    return tuple((d - d0, r) for d, r in C[i:k])


def embed(C, R):
    """Greedy: match equal records, otherwise delete the subtree at C[i].
    Returns (ok, deletions[(i,k)], why)."""
    i = j = 0
    dels = []
    while i < len(C):
        if j < len(R) and C[i] == R[j]:
            i += 1
            j += 1
            continue
        k = subtree_end(C, i)
        dels.append((i, k))
        i = k
    if j != len(R):
        return False, dels, f'raw has {len(R) - j} unmatched records from #{j}'
    return True, dels, ''


def check(d):
    C = load(os.path.join(d, 'canA'))
    CB = load(os.path.join(d, 'canB'))
    if C != CB:
        return 'FAIL', 'canA != canB', {}
    first_rec = {}
    for idx, (_, r) in enumerate(C):
        first_rec.setdefault(r, idx)
    stats = {}
    for side in ('A', 'B'):
        R = load(os.path.join(d, 'raw' + side))
        ok, dels, why = embed(C, R)
        if not ok:
            return 'FAIL', f'side {side}: {why}', stats
        seen_blocks = {}
        strong = relist = 0
        bad = []
        # blocks that start before position i (any earlier subtree), keyed lazily
        for (i, k) in dels:
            r = C[i][1]
            if first_rec.get(r, i) < i:
                relist += 1
            else:
                bad.append(i)
        # strong form: an earlier subtree with identical relative content
        if dels:
            starts = {}
            for idx in range(len(C)):
                starts.setdefault(C[idx][1], []).append(idx)
            for (i, k) in dels:
                key = block_key(C, i, k)
                for q in starts[C[i][1]]:
                    if q >= i:
                        break
                    if block_key(C, q, subtree_end(C, q)) == key:
                        strong += 1
                        break
        stats[side] = (len(R), len(dels), sum(k - i for i, k in dels), relist, strong)
        if bad:
            return 'FAIL', f'side {side}: deleted root #{bad[0]} never listed earlier: {C[bad[0]]}', stats
    return 'OK', '', stats


def main():
    rows = [r for r in csv.DictReader(open(sys.argv[1]))
            if r['raw_v'] != 'equal' and r['can_v'] == 'equal']
    dumps = sys.argv[2]
    nok = nfail = 0
    for r in rows:
        d = os.path.join(dumps, f"{r['corpus']}_{r['mode']}_{r['test']}")
        st, why, stats = check(d)
        nok += st == 'OK'
        nfail += st != 'OK'
        s = ' '.join(f"{k}:raw={v[0]},del_subtrees={v[1]},del_records={v[2]},relisted={v[3]},same_block_earlier={v[4]}"
                     for k, v in stats.items())
        print(f"{st}\t{r['corpus']}\t{r['mode']}\t{r['test']}\t{r['raw_v']}\tcanon={r['can_nA']}\t{s}\t{why}")
    print(f'TOTAL rows={len(rows)} OK={nok} FAIL={nfail}')


if __name__ == '__main__':
    main()
