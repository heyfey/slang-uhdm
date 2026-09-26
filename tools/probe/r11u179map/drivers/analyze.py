#!/usr/bin/env python3
"""r11u132 analyzer: r11u128map/drivers/analyze.py (alignment unchanged) reading
the variant comparator's dumps (drivers/strictcmp_x.cpp: one escaped line per
record, 14 fields + a 15th column rawFull\\x1frefRoot\\x1froot\\x1finCopy) and
applying the COMMITTED mode-4 rule (tools/uhdm-strictcmp fieldDiffers +
PairCtx, reimplemented in fd()/pairctx() and verified per row against the
tool's own stdout: verify()). Emits one facet row per differing (object, facet).
Alignment: GNU diff on the key (depth,type,name,defname); change hunks
sub-aligned by type (difflib)."""
import sys, os, subprocess, difflib, json, re
F = ["depth","type","name","defname","fullname","file","line","col","endline","endcol","decompile","size","value","consttype"]
RAW, REFROOT, ROOT, INCOPY = 14, 15, 16, 17

def load(p):
    out = []
    with open(p, errors='replace') as f:
        for l in f:
            x = l.rstrip('\n').split('\t')
            assert len(x) == 15 and re.fullmatch(r'\d+', x[0]), (p, x[:3])
            e = x[14].split('\x1f')
            assert len(e) in (4, 5), (p, x[:3])
            out.append(x[:14] + [e[0], e[1] == '1', e[2] == '1', e[3] == '1'])
    return out

def span(r): return f'{r[5]}:{r[6]}.{r[7]}-{r[8]}.{r[9]}'

def pairctx(A, B):
    """uhdm-strictcmp PairCtx: built over the INDEX alignment (i-th vs i-th)."""
    names, spans = {}, {}
    for i in range(min(len(A), len(B))):
        a, b = A[i], B[i]
        if b[INCOPY] and b[RAW]: names.setdefault(b[1] + '|' + b[RAW], set()).add(a[RAW])
        if b[ROOT]: spans.setdefault(b[1] + '|' + b[2] + '|' + span(b), set()).add(span(a))
    return names, spans

def fd(a, b, k, ctx):
    """uhdm-strictcmp fieldDiffers, mode 4."""
    names, spans = ctx
    if k == 4:
        if a[RAW] == b[RAW]: return False
        if a[4] != b[4]: return True
        s = names.get(b[1] + '|' + b[RAW])
        return not (s and len(s) >= 2 and b[RAW] in s)
    if a[k] == b[k]: return False
    if 5 <= k <= 9 and a[REFROOT] and b[REFROOT]:
        s = spans.get(b[1] + '|' + b[2] + '|' + span(b))
        return not (s and len(s) >= 2 and span(b) in s)
    return True

def verify(A, B, ctx, outp):
    """Re-run the tool's stage-2 loop on the dumps; compare with its stdout."""
    tally = [0] * 14; nd = 0; first = ''; structural = False
    for i in range(min(len(A), len(B))):
        f0 = -1
        for k in range(14):
            if fd(A[i], B[i], k, ctx):
                if f0 < 0: f0 = k
                tally[k] += 1
        if f0 < 0: continue
        nd += 1
        if not first: first = F[f0]
        if f0 <= 1: structural = True; break
    if len(A) != len(B) and not first: first = 'count'
    mine = 'fields:' + ''.join(f' {F[k]}={tally[k]}' for k in range(14) if tally[k]) + f' objects_differing={nd}' + (' (walk diverged)' if structural else '')
    txt = open(outp, errors='replace').read()
    m = re.search(r'^fields:.*$', txt, re.M); t = re.search(r'^STRICT_NOTEQUAL (\S+)', txt, re.M)
    tool = (m.group(0) if m else '', t.group(1) if t else '')
    return dict(ok=(tool == (mine, first)), tool_fields=tool[0], tool_first=tool[1], first=first, ndiff=nd)

def parents(recs):
    stack = {}; par = []
    for i, r in enumerate(recs):
        d = int(r[0])
        par.append(stack.get(d - 1, -1))
        stack[d] = i
        for k in [k for k in stack if k > d]: del stack[k]
    return par

def chain(recs, par, i, n=4):
    s = []; j = par[i]
    while j >= 0 and len(s) < n:
        r = recs[j]; s.append(r[1] + ('(' + r[2] + ')' if r[2] else '')); j = par[j]
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
        ra = (a1, a1) if op == 'a' else (a1 - 1, a2)
        rb = (b1, b1) if op == 'd' else (b1 - 1, b2)
        hunks.append((ra, rb))
    return hunks

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
def fshape(g, o):
    if o == '' and g != '': return 'ours-empty'
    if g == '' and o != '': return 'golden-empty'
    return 'tok:' + tokshape(g, o)
def vform(v):
    m = re.match(r'^([A-Z]+):', v)
    return m.group(1) if m else ('empty' if v == '' else 'raw')

def facets(a, b, ctx):
    out = []; t = a[1]
    D = {k for k in range(2, 14) if fd(a, b, k, ctx)}
    if 2 in D or 3 in D:
        fl = [F[k] for k in (2, 3) if k in D]; k = 2 if 2 in D else 3
        out.append(('name', '+'.join(fl), f"name|{t}|{fshape(a[k], b[k])}", a, b))
    if 4 in D:
        out.append(('fullname', 'fullname', f"fullname|{t}|{fshape(a[RAW], b[RAW])}", a, b))
    sp = [k for k in (6, 7, 8, 9) if k in D]
    if 5 in D:
        sh = 'ours-empty' if b[5] == '' else ('golden-empty' if a[5] == '' else 'other-file')
        if sh == 'other-file':
            out.append(('file', 'file' + ('+span' if sp else ''), f"file|{t}|other-file{'+span' if sp else ''}", a, b)); sp = []
        else:
            out.append(('file', 'file', f"file|{t}|{sh}", a, b))
    if sp:
        oz = all(b[k] == '0' for k in (6, 7, 8, 9)); gz = all(a[k] == '0' for k in (6, 7, 8, 9))
        sh = 'ours-zero' if oz else ('golden-zero' if gz else '+'.join(F[k] for k in sp))
        out.append(('span', '+'.join(F[k] for k in sp), f"span|{t}|{sh}", a, b))
    vv = [k for k in (10, 11, 12, 13) if k in D]
    if vv:
        parts = []
        if 12 in vv: parts.append(f"value:{vform(a[12])}->{vform(b[12])}")
        if 10 in vv: parts.append('decompile')
        if 11 in vv: parts.append('size')
        if 13 in vv: parts.append(f"consttype:{a[13]}->{b[13]}")
        out.append(('value', '+'.join(F[k] for k in vv), f"value|{t}|{'+'.join(parts)}", a, b))
    return out

def subtree_hashes(R):
    n = len(R); h = [0] * n; end = [0] * n; stack = []
    def close(st):
        i, d, ch = st; h[i] = hash((tuple(R[i][1:14]), tuple(ch))); return h[i]
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
    for i, p in enumerate(P): k.setdefault(p, []).append(i)
    return k

def analyze(corpus, mode, test, pa, pb, tmp, outp):
    from collections import Counter
    A, B = load(pa), load(pb)
    ctx = pairctx(A, B)
    ver = verify(A, B, ctx, outp)
    parA, parB = parents(A), parents(B)
    sigA = Counter((r[1], r[2], r[6], r[7], r[8], r[9]) for r in A)
    sigB = Counter((r[1], r[2], r[6], r[7], r[8], r[9]) for r in B)
    hunks = diffhunks(A, B, tmp)
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
    for i, r in enumerate(A): fnA.setdefault(akA[i], set()).add(r[RAW])
    for i, r in enumerate(B): fnB.setdefault(akB[i], set()).add(r[RAW])
    rows = []; pairs = []
    def gv(fc, r):
        if fc == 'name': return r[2] + '|' + r[3]
        if fc == 'fullname': return r[RAW]
        if fc == 'file': return r[5] + ' ' + ':'.join(r[6:10])
        if fc == 'span': return ':'.join(r[6:10])
        if fc == 'value': return '|'.join([r[10], r[11], r[12], r[13]])
        return ''
    def emit_pair_real(i, j):
        pt_ = A[parA[i]][1] if parA[i] >= 0 else '-'
        for fc, fl, cl, a, b in facets(A[i], B[j], ctx):
            d = dict(facet=fc, fields=fl, cluster=cl + '|under:' + pt_, ia=i, ib=j, type=A[i][1], name=A[i][2],
                     chain=chain(A, parA, i), golden=gv(fc, A[i]), ours=gv(fc, B[j]))
            if fc == 'fullname':
                d['gnames'] = len(fnA.get(akA[i], ())); d['onames'] = len(fnB.get(akB[j], ()))
                d['incopy'] = bool(B[j][INCOPY])
                d['fnclass'] = ('TAIL' if A[i][4] != B[j][4] else 'STABLE') if B[j][INCOPY] else 'OUT'
            if fc in ('span', 'file') and A[i][REFROOT] and B[j][REFROOT]: d['refroot'] = True
            rows.append(d)
    ia = ib = 0
    def matched_until(ea, eb):
        nonlocal ia, ib
        while ia < ea and ib < eb:
            pairs.append((ia, ib)); ia += 1; ib += 1
        assert ia == ea and ib == eb, (test, ia, ea, ib, eb)
    for (a1, a2), (b1, b2) in hunks:
        matched_until(a1, b1)
        ka = [r[1] for r in A[a1:a2]]; kb = [r[1] for r in B[b1:b2]]
        if len(ka) * len(kb) > 4_000_000: ops = [('replace', 0, len(ka), 0, len(kb))]
        else: ops = difflib.SequenceMatcher(None, ka, kb, autojunk=False).get_opcodes()
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
                    pairs.append((i, j))
            else:
                extraA += range(a1 + x1, a1 + x2); extraB += range(b1 + y1, b1 + y2)
        for side, ex, R, P in (('golden', extraA, A, parA), ('ours', extraB, B, parB)):
            s = set(ex)
            for i in ex:
                p = P[i]
                if p in s: continue
                d = int(R[i][0]); n = 1; k = i + 1
                while k < len(R) and int(R[k][0]) > d and k in s: n += 1; k += 1
                pt = R[p][1] if p >= 0 else '-'
                sg = (R[i][1], R[i][2], R[i][6], R[i][7], R[i][8], R[i][9])
                mine, other = (sigA, sigB) if side == 'golden' else (sigB, sigA)
                how = 'absent' if other[sg] == 0 else ('fewer-copies' if other[sg] < mine[sg] else 'elsewhere')
                rows.append(dict(facet='struct', fields=f'{side}-only', cluster=f"struct|{side}-only:{how}|{R[i][1]}|under:{pt}",
                                 ia=i if side == 'golden' else -1, ib=i if side == 'ours' else -1, type=R[i][1], name=R[i][2],
                                 chain=chain(R, P, i), golden=(f'{n} objs' if side == 'golden' else ''),
                                 ours=(f'{n} objs' if side == 'ours' else ''), nobj=n))
        ia, ib = a2, b2
    matched_until(len(A), len(B))
    hA, endA = subtree_hashes(A); hB, endB = subtree_hashes(B)
    kidsA = children(A, parA); kidsB = children(B, parB)
    pairs.sort(); skipA = -1; skipB = -1
    for i, j in pairs:
        if i < skipA or j < skipB: continue
        if not any(fd(A[i], B[j], k, ctx) for k in range(1, 14)): continue
        if hA[i] != hB[j]:
            sibB = {hB[k] for k in kidsB.get(parB[j], ())}; sibA = {hA[k] for k in kidsA.get(parA[i], ())}
            if hA[i] in sibB and hB[j] in sibA:
                pt = A[parA[i]][1] if parA[i] >= 0 else '-'
                rows.append(dict(facet='order', fields='order', cluster=f"order|{A[i][1]}|under:{pt}", ia=i, ib=j,
                                 type=A[i][1], name=A[i][2], chain=chain(A, parA, i), golden=A[i][2] or ':'.join(A[i][6:10]),
                                 ours=B[j][2] or ':'.join(B[j][6:10]), nobj=endA[i] - i))
                if endA[i] - i == endB[j] - j: skipA, skipB = endA[i], endB[j]
                continue
        emit_pair_real(i, j)
    return dict(nA=len(A), nB=len(B), rows=rows, verify=ver)

if __name__ == '__main__':
    jobs, outp, DUMPS = sys.argv[1:4]; NP = int(sys.argv[4]) if len(sys.argv) > 4 else 2
    TMP = os.environ.get('R11U138_TMP', '/tmp/r11u138_work'); os.makedirs(TMP, exist_ok=True)
    import multiprocessing as mp
    lines = [l.rstrip('\n').split('\t') for l in open(jobs)]
    def work(x):
        c, m, n = x[0], x[1], x[2]; D = f'{DUMPS}/{c}/{m}'
        try:
            r = analyze(c, m, n, f'{D}/{n}.a', f'{D}/{n}.b', f'{TMP}/tmp_{os.getpid()}', f'{D}/{n}.out')
        except Exception as e:
            return dict(corpus=c, mode=m, test=n, error=repr(e))
        r.update(corpus=c, mode=m, test=n, strict=x[5])
        return r
    with mp.Pool(NP) as pool, open(outp, 'w') as f:
        for r in pool.imap_unordered(work, lines, chunksize=1):
            f.write(json.dumps(r) + '\n')
