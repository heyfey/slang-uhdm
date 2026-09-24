#!/usr/bin/env python3
"""The relabelling proof: an old (pre-flip) baseline against a new one.

    relabel_proof.py <old.csv> <new.csv>     (corpus: name,mode,status,detail,blocked_by,strict)
    relabel_proof.py --probe <old_sweep.log> <new.csv>   (probe: the old check_probe had no csv;
                                              its gate printed only non-EQUAL cases, so the old
                                              side is 'every case EQUAL' + the old strict tally)

Asserts: the same row keys; every row keeps its uhdm-cmp verdict (old CMP_EQUAL
<-> new CMP_EQUAL or STRICT_NOTEQUAL, every other status unchanged); the strict
column is unchanged; an old CMP_EQUAL row is new CMP_EQUAL exactly when its
strict verdict is 'equal', else STRICT_NOTEQUAL with detail == strict verdict.
The detail of every other row is unchanged or differs only in the checkout or
workdir path it spells (the committed csvs were swept from another checkout).
Exit 1 on any violation.
"""
import collections
import csv
import re
import sys


ROOTS = re.compile(r'/home/[^/]+/git-repos/(slang-uhdm/third_party/)?(Surelog|uhdm2rtlil)/')
TMP = re.compile(r'/tmp/[^ "]*')


def env_only(a, b):
    """The two details differ only in the checkout or workdir path they spell
    (a detail is cut at 140 characters, so the shorter normalised text must be
    a prefix of the longer)."""
    na, nb = (TMP.sub('<TMP>', ROOTS.sub('<ROOT>/', x)) for x in (a, b))
    m = min(len(na), len(nb))
    return na[:m] == nb[:m]


def rows(p):
    with open(p, newline='') as f:
        rd = csv.reader(f)
        hdr = next(rd)
        return hdr, {(r[0], r[1]): r for r in rd if r}


def corpus(old_p, new_p):
    ho, o = rows(old_p)
    hn, n = rows(new_p)
    bad = []
    assert ho == hn, (ho, hn)
    if set(o) != set(n):
        bad.append(f'keys: only-old={sorted(set(o)-set(n))[:5]} only-new={sorted(set(n)-set(o))[:5]}')
    tally = collections.Counter()
    detail = collections.Counter()
    for k in sorted(set(o) & set(n)):
        a, b = o[k], n[k]
        if a[5] != b[5]:
            bad.append(f'strict column {k}: {a[5]!r} -> {b[5]!r}')
        if a[4] != b[4]:
            bad.append(f'blocked_by {k}: {a[4]!r} -> {b[4]!r}')
        if a[2] == 'CMP_EQUAL':
            want = 'CMP_EQUAL' if a[5] == 'equal' else 'STRICT_NOTEQUAL'
            if b[2] != want:
                bad.append(f'status {k}: {a[2]}/{a[5]} -> {b[2]} (want {want})')
            elif want == 'CMP_EQUAL' and (b[3] or a[3]):
                bad.append(f'detail {k}: {a[3]!r} -> {b[3]!r}')
            elif want == 'STRICT_NOTEQUAL' and b[3] != a[5]:
                bad.append(f'detail {k}: {b[3]!r} != strict {a[5]!r}')
            tally[(a[2], b[2])] += 1
        else:
            if a[2] != b[2]:
                bad.append(f'status {k}: {a[2]} -> {b[2]}')
            tally[(a[2], b[2])] += 1
            if a[3] != b[3]:
                if env_only(a[3], b[3]):
                    detail[a[2]] += 1
                else:
                    bad.append(f'detail {k}: {a[3]!r} -> {b[3]!r}')
    print(f'{new_p}: {len(n)} rows ({len(o)} old)')
    for (x, y), c in sorted(tally.items()):
        print(f'  {x:>15} -> {y:<16} {c}')
    for st, c in sorted(detail.items()):
        print(f'  detail text differs only in the checkout/workdir path it spells on {c} {st} rows')
    return bad


def probe(log_p, new_p):
    import re
    old_counts, old_strict = None, {}
    for line in open(log_p):
        if line.startswith('probe cases:'):
            old_counts = dict(re.findall(r'(\w+)=(\d+)', line.split('(of')[0]))
            total = int(re.search(r'\(of (\d+)\)', line).group(1))
        if line.startswith('probe strict'):
            old_strict = {k: int(v) for k, v in re.findall(r'(\S+)=(\d+)', line.split(':', 1)[1])}
    with open(new_p, newline='') as f:
        rd = csv.reader(f)
        hdr = next(rd)
        n = [r for r in rd if r]
    bad = []
    st = collections.Counter(r[1] for r in n)
    sv = collections.Counter(r[3].split('(')[0] for r in n)
    print(f'{new_p}: {len(n)} cases; old gate: {old_counts} of {total}')
    print(f'  new statuses {dict(st)}')
    print(f'  strict tally old {old_strict}')
    print(f'  strict tally new {dict(sv)}')
    if hdr != ['case', 'status', 'detail', 'strict']:
        bad.append(f'header {hdr}')
    if len(n) != total or old_counts != {'EQUAL': str(total)}:
        bad.append('case count / old all-EQUAL')
    if dict(sv) != old_strict:
        bad.append('strict tally differs')
    for r in n:
        want = 'EQUAL' if r[3] == 'equal' else 'STRICT_NOTEQUAL'
        if r[1] != want or (want == 'STRICT_NOTEQUAL' and r[2] != r[3]) or (want == 'EQUAL' and r[2]):
            bad.append(f'row {r}')
    return bad


if __name__ == '__main__':
    if sys.argv[1] == '--probe':
        bad = probe(sys.argv[2], sys.argv[3])
    else:
        bad = corpus(sys.argv[1], sys.argv[2])
    for b in bad[:50]:
        print('VIOLATION', b)
    print('RELABEL PROOF', 'FAIL' if bad else 'PASS', f'violations={len(bad)}')
    sys.exit(1 if bad else 0)
