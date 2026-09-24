#!/usr/bin/env python3
"""r11u128 analyzer (r11u122map/drivers/analyze.py + fullname classes, parameterised paths): align golden (A) vs ours (B) strictcmp record dumps and
emit one facet row per differing (object, facet). Alignment: GNU diff on the
key (depth,type,name,defname); change hunks sub-aligned by type (difflib)."""
import sys, os, subprocess, difflib, json, re, tempfile
F = ["depth","type","name","defname","fullname","file","line","col","endline","endcol","decompile","size","value","consttype"]

def load(p):
    # a record is 14 tab-separated fields on one line, but decompile/value/name
    # text may carry newlines: accumulate physical lines until 13 tabs are seen.
    out = []
    buf = None
    with open(p, errors='replace') as f:
        for l in f:
            l = l.rstrip('\n')
            buf = l if buf is None else buf + '\\n' + l
            if buf.count('\t') >= 13:
                x = buf.split('\t')
                if len(x) > 14: x = x[:13] + ['\t'.join(x[13:])]
                assert re.fullmatch(r'\d+', x[0]), (p, x[:3])
                out.append(x); buf = None
    assert buf is None, (p, buf[:80])
    return out

def parents(recs):
    """index of parent (latest earlier record at depth-1) for each record."""
    stack = {}
    par = []
    for i, r in enumerate(recs):
        d = int(r[0])
        par.append(stack.get(d - 1, -1))
        stack[d] = i
        # drop deeper entries
        for k in [k for k in stack if k > d]:
            del stack[k]
    return par

def chain(recs, par, i, n=4):
    s = []
    j = par[i]
    while j >= 0 and len(s) < n:
        r = recs[j]
        s.append(r[1] + ('(' + r[2] + ')' if r[2] else ''))
        j = par[j]
    return ' < '.join(s)

def diffhunks(A, B, tmp):
    fa, fb = tmp + '.ka', tmp + '.kb'
    with open(fa, 'w') as f:
        for r in A: f.write('\t'.join(r[:4]) + '\n')
    with open(fb, 'w') as f:
        for r in B: f.write('\t'.join(r[:4]) + '\n')
    p = subprocess.run(['diff', fa, fb], capture_output=True, text=True, errors='replace')
    os.unlink(fa); os.unlink(fb)
    hunks = []
    for l in p.stdout.splitlines():
        m = re.match(r'^(\d+)(?:,(\d+))?([acd])(\d+)(?:,(\d+))?$', l)
        if not m: continue
        a1 = int(m.group(1)); a2 = int(m.group(2) or a1)
        b1 = int(m.group(4)); b2 = int(m.group(5) or b1)
        op = m.group(3)
        if op == 'a': ra = (a1, a1)          # insert after a1 -> empty A range starting a1 (0-based a1)
        else: ra = (a1 - 1, a2)
        if op == 'd': rb = (b1, b1)
        else: rb = (b1 - 1, b2)
        hunks.append((ra, rb))
    return hunks

def fshape(g, o):
    if o == '' and g != '': return 'ours-empty'
    if g == '' and o != '': return 'golden-empty'
    return 'tok:' + tokshape(g, o)

def prefix_class(s):
    s2 = re.sub(r'work@', 'W@', s)
    s2 = re.sub(r'[A-Za-z_\$][A-Za-z0-9_\$]*', 'id', s2)
    s2 = re.sub(r'\d+', 'n', s2)
    return s2[:48]
TOK = re.compile(r'(::|\.|@|\[|\])')
def tokshape(g, o):
    tg = [t for t in TOK.split(g) if t != '']; to = [t for t in TOK.split(o) if t != '']
    i = 0
    while i < min(len(tg), len(to)) and tg[i] == to[i]: i += 1
    j = 0
    while j < min(len(tg), len(to)) - i and tg[-1-j] == to[-1-j]: j += 1
    return prefix_class(''.join(tg[i:len(tg)-j])) + '->' + prefix_class(''.join(to[i:len(to)-j]))

def vform(v):
    m = re.match(r'^([A-Z]+):', v)
    return m.group(1) if m else ('empty' if v == '' else 'raw')

def facets(a, b):
    """facets of a paired object (same type)."""
    out = []
    t = a[1]
    if a[2] != b[2] or a[3] != b[3]:
        fl = [F[k] for k in (2, 3) if a[k] != b[k]]
        k = 2 if a[2] != b[2] else 3
        out.append(('name', '+'.join(fl), f"name|{t}|{fshape(a[k], b[k])}", a, b))
    if a[4] != b[4]:
        out.append(('fullname', 'fullname', f"fullname|{t}|{fshape(a[4], b[4])}", a, b))
    sp = [k for k in (6, 7, 8, 9) if a[k] != b[k]]
    if a[5] != b[5]:
        sh = 'ours-empty' if b[5] == '' else ('golden-empty' if a[5] == '' else 'other-file')
        if sh == 'other-file':
            # a different buffer: the span moves with it -> one facet
            out.append(('file', 'file' + ('+span' if sp else ''), f"file|{t}|other-file{'+span' if sp else ''}", a, b))
            sp = []
        else:
            out.append(('file', 'file', f"file|{t}|{sh}", a, b))
    if sp:
        oz = all(b[k] == '0' for k in (6, 7, 8, 9))
        gz = all(a[k] == '0' for k in (6, 7, 8, 9))
        if oz: sh = 'ours-zero'
        elif gz: sh = 'golden-zero'
        else: sh = '+'.join(F[k] for k in sp)
        out.append(('span', '+'.join(F[k] for k in sp), f"span|{t}|{sh}", a, b))
    vv = [k for k in (10, 11, 12, 13) if a[k] != b[k]]
    if vv:
        parts = []
        if 12 in vv: parts.append(f"value:{vform(a[12])}->{vform(b[12])}")
        if 10 in vv: parts.append('decompile')
        if 11 in vv: parts.append('size')
        if 13 in vv: parts.append(f"consttype:{a[13]}->{b[13]}")
        out.append(('value', '+'.join(F[k] for k in vv), f"value|{t}|{'+'.join(parts)}", a, b))
    return out

def subtree_hashes(R):
    n = len(R); h = [0] * n; end = [0] * n
    stack = []  # (index, depth, [child hashes])
    def close(st):
        i, d, ch = st
        h[i] = hash((tuple(R[i][1:]), tuple(ch)))
        return h[i]
    for i, r in enumerate(R):
        d = int(r[0])
        while stack and stack[-1][1] >= d:
            st = stack.pop(); hv = close(st); end[st[0]] = i
            if stack: stack[-1][2].append(hv)
        stack.append((i, d, []))
    while stack:
        st = stack.pop(); hv = close(st); end[st[0]] = n
        if stack: stack[-1][2].append(hv)
    return h, end

def children(R, P):
    k = {}
    for i, p in enumerate(P):
        k.setdefault(p, []).append(i)
    return k

def first_field(a, b):
    for k in range(14):
        if a[k] != b[k]: return F[k]
    return ''

def analyze(corpus, mode, test, pa, pb, tmp):
    A, B = load(pa), load(pb)
    parA, parB = parents(A), parents(B)
    from collections import Counter
    sigA = Counter((r[1], r[2], r[6], r[7], r[8], r[9]) for r in A)
    sigB = Counter((r[1], r[2], r[6], r[7], r[8], r[9]) for r in B)
    hunks = diffhunks(A, B, tmp)
    # Anchored identity signature: a located record is keyed by its own
    # fields (type name defname file span decompile value); an unlocated one
    # (0:0:0:0, e.g. every ref_typespec) by its nearest located ancestor's key
    # plus its own non-span fields. Records with one key = one source object
    # listed at several uses (a producer copy, or our re-expanded share).
    SIG = lambda r: (r[1], r[2], r[3], r[5], r[6], r[7], r[8], r[9], r[10], r[12])
    def akeys(R, P):
        h = [0] * len(R)
        for i, r in enumerate(R):
            if r[6] == '0' and r[7] == '0' and r[8] == '0' and r[9] == '0':
                h[i] = hash((h[P[i]] if P[i] >= 0 else 0, r[1], r[2], r[3], r[10], r[12]))
            else:
                h[i] = hash(SIG(r))
        return h
    akA, akB = akeys(A, parA), akeys(B, parB)
    fnA = {}; fnB = {}
    for i, r in enumerate(A): fnA.setdefault(akA[i], set()).add(r[4])
    for i, r in enumerate(B): fnB.setdefault(akB[i], set()).add(r[4])
    rows = []   # (facet, fields, cluster, idxA, idxB, detail)
    pairs = []
    def emit_pair(i, j):
        pairs.append((i, j))
    def emit_pair_real(i, j):
        pt_ = A[parA[i]][1] if parA[i] >= 0 else '-'
        for fc, fl, cl, a, b in facets(A[i], B[j]):
            cl = cl + '|under:' + pt_
            d = dict(facet=fc, fields=fl, cluster=cl, ia=i, ib=j, type=A[i][1], name=A[i][2],
                             chain=chain(A, parA, i), golden=gv(fc, A[i]), ours=gv(fc, B[j]))
            if fc == 'fullname':
                d['gnames'] = len(fnA.get(akA[i], ())); d['onames'] = len(fnB.get(akB[j], ()))
                d['gn'] = sorted(fnA.get(akA[i], ()))[:4]; d['on'] = sorted(fnB.get(akB[j], ()))[:4]
            rows.append(d)
    def gv(fc, r):
        if fc == 'name': return r[2] + '|' + r[3]
        if fc == 'fullname': return r[4]
        if fc == 'file': return r[5] + ' ' + ':'.join(r[6:10])
        if fc == 'span': return ':'.join(r[6:10])
        if fc == 'value': return '|'.join([r[10], r[11], r[12], r[13]])
        return ''
    ia = ib = 0
    def matched_until(ea, eb):
        nonlocal ia, ib
        while ia < ea and ib < eb:
            emit_pair(ia, ib); ia += 1; ib += 1
        assert ia == ea and ib == eb, (test, ia, ea, ib, eb)
    for (a1, a2), (b1, b2) in hunks:
        matched_until(a1, b1)
        sa, sb = A[a1:a2], B[b1:b2]
        ka = [r[1] for r in sa]; kb = [r[1] for r in sb]
        if len(ka) * len(kb) > 4_000_000:
            ops = [('replace', 0, len(ka), 0, len(kb))]
        else:
            ops = difflib.SequenceMatcher(None, ka, kb, autojunk=False).get_opcodes()
        extraA, extraB = [], []
        for op, x1, x2, y1, y2 in ops:
            if op == 'equal':
                for d in range(x2 - x1):
                    i, j = a1 + x1 + d, b1 + y1 + d
                    if A[i][0] != B[j][0]:
                        pa_ = parA[i]; pb_ = parB[j]
                        cl = f"depth|{A[i][1]}|{A[pa_][1] if pa_>=0 else '-'}->{B[pb_][1] if pb_>=0 else '-'}"
                        rows.append(dict(facet='depth', fields='depth', cluster=cl, ia=i, ib=j, type=A[i][1], name=A[i][2],
                                         chain=chain(A, parA, i), golden=A[i][0] + ' ' + chain(A, parA, i, 2), ours=B[j][0] + ' ' + chain(B, parB, j, 2)))
                        continue
                    emit_pair(i, j)
            else:
                extraA += range(a1 + x1, a1 + x2)
                extraB += range(b1 + y1, b1 + y2)
        for side, ex, R, P in (('golden', extraA, A, parA), ('ours', extraB, B, parB)):
            s = set(ex)
            for i in ex:
                p = P[i]
                if p in s: continue   # inside an extra subtree: counted with its root
                # subtree size
                d = int(R[i][0]); n = 1; k = i + 1
                while k < len(R) and int(R[k][0]) > d and k in s: n += 1; k += 1
                pt = R[p][1] if p >= 0 else '-'
                sg = (R[i][1], R[i][2], R[i][6], R[i][7], R[i][8], R[i][9])
                mine, other = (sigA, sigB) if side == 'golden' else (sigB, sigA)
                if other[sg] == 0: how = 'absent'
                elif other[sg] < mine[sg]: how = 'fewer-copies'
                else: how = 'elsewhere'
                cl = f"struct|{side}-only:{how}|{R[i][1]}|under:{pt}"
                rows.append(dict(facet='struct', fields=f'{side}-only', cluster=cl, ia=i if side == 'golden' else -1,
                                 ib=i if side == 'ours' else -1, type=R[i][1], name=R[i][2], chain=chain(R, P, i),
                                 golden=(f'{n} objs' if side == 'golden' else ''), ours=(f'{n} objs' if side == 'ours' else ''), nobj=n))
        ia, ib = a2, b2
    matched_until(len(A), len(B))
    # order detection: a paired object whose whole subtree (fields minus depth)
    # equals the subtree of a SIBLING of its partner is a reordering.
    hA, endA = subtree_hashes(A); hB, endB = subtree_hashes(B)
    kidsA = children(A, parA); kidsB = children(B, parB)
    pairs.sort()
    skipA = -1; skipB = -1
    for i, j in pairs:
        if i < skipA or j < skipB: continue
        if A[i][1:] == B[j][1:]: continue
        if hA[i] != hB[j]:
            sibB = {hB[k] for k in kidsB.get(parB[j], ())}
            sibA = {hA[k] for k in kidsA.get(parA[i], ())}
            if hA[i] in sibB and hB[j] in sibA:
                pt = A[parA[i]][1] if parA[i] >= 0 else '-'
                rows.append(dict(facet='order', fields='order', cluster=f"order|{A[i][1]}|under:{pt}", ia=i, ib=j,
                                 type=A[i][1], name=A[i][2], chain=chain(A, parA, i), golden=A[i][2] or ':'.join(A[i][6:10]),
                                 ours=B[j][2] or ':'.join(B[j][6:10]), nobj=endA[i] - i))
                if endA[i] - i == endB[j] - j:
                    skipA, skipB = endA[i], endB[j]
                continue
        emit_pair_real(i, j)
    return dict(nA=len(A), nB=len(B), rows=rows)

if __name__ == '__main__':
    jobs = sys.argv[1]; outp = sys.argv[2]; DUMPS = sys.argv[3]; NP = int(sys.argv[4]) if len(sys.argv) > 4 else 2
    import multiprocessing as mp
    lines = [l.rstrip('\n').split('\t') for l in open(jobs)]
    def work(x):
        c, m, n = x[0], x[1], x[2]
        D = f'{DUMPS}/{c}/{m}'
        try:
            r = analyze(c, m, n, f'{D}/{n}.a', f'{D}/{n}.b', f'/tmp/r11u128_work/tmp_{os.getpid()}')
        except Exception as e:
            return dict(corpus=c, mode=m, test=n, error=repr(e))
        r.update(corpus=c, mode=m, test=n, strict=x[5])
        return r
    with mp.Pool(NP) as pool, open(outp, 'w') as f:
        for r in pool.imap_unordered(work, lines, chunksize=4):
            f.write(json.dumps(r) + '\n')
