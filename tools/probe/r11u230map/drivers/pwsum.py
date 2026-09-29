#!/usr/bin/env python3
"""r11u230map: pinwriter.py's jsonl -> sites_writer.json {cluster: {writer, owner, how, field, example, mint, db}} and
writer_ground.json {cluster: ground} (the writer's file: ExprEmit / EmitHelpers / StmtEmit / ParamEmit = A; TypeEmit /
ModuleEmit / UhdmExporter / TaskFuncEmit / uhdm_main = B). The writer is the LAST recorded write of the differing field
(for fullname: the last VpiFullName setter call if any stored a name, else the last vpiParent_ write, the chain UHDM
synthesizes the name from); a write inside a generic helper (setLoc, copyLoc, the UHDM setters, UHDM's DeepClone) is
attributed to its first caller outside the helpers, with the helper kept in the chain. No write after the mint = the
field keeps what the mint's function wrote (how=mint). Each frame names the nearest law above its line (sites.py's rule).
Args: <src dir> <out sites_writer.json> <out writer_ground.json> <pinwriter jsonl>... (a later file's pin of a cluster
replaces an earlier one, which is kept as alt_writer / alt_example)"""
import json, sys, re, os
SRC, OUT, GOUT = sys.argv[1:4]
HELPERS = {'setLoc', 'copyLoc', 'setLocRange', 'setLocFrom', 'copySpan', 'setSpan', 'setEndLoc', 'locFrom', 'setFileLoc',
           'VpiParent', 'VpiLineNo', 'VpiColumnNo', 'VpiEndLineNo', 'VpiEndColumnNo', 'VpiFile', 'VpiName', 'VpiFullName',
           'VpiDefName', 'VpiValue', 'VpiDecompile', 'DeepClone'}
GA = {'ExprEmit.cpp', 'EmitHelpers.h', 'StmtEmit.cpp', 'ParamEmit.cpp'}
GB = {'TypeEmit.cpp', 'ModuleEmit.cpp', 'UhdmExporter.cpp', 'TaskFuncEmit.cpp', 'uhdm_main.cpp'}
cache = {}
def law_above(f, line):
    p = os.path.join(SRC, f) if os.path.exists(os.path.join(SRC, f)) else os.path.join(SRC, '..', f)
    if not os.path.exists(p): return None
    if p not in cache: cache[p] = open(p, errors='replace').read().splitlines()
    L = cache[p]
    for i in range(min(line, len(L)) - 1, max(0, line - 600), -1):
        for m in re.finditer(r'§ ([A-Za-z][A-Za-z0-9_]*)', L[i]):
            if re.search(r'[A-Z0-9]', m.group(1)): return m.group(1)
    return None
def short(name):
    if 'operator()' in name and 'lambda' in name: return 'operator()'
    n = re.sub(r'<.*>', '', name); n = re.sub(r'\(.*$', '', n); n = n.split('::')[-1] or name
    return 'operator()' if n == 'operator' else n
def fr(f):
    fn = os.path.basename(f[2]); law = law_above(fn, f[3]) if fn.endswith(('.cpp', '.h')) and fn != 'BaseClass.h' else None
    return f"{short(f[1])} ({fn}" + (f", law {law})" if law else ")"), fn, short(f[1])
def chain(bt):
    """(owner file, text): skip the frames that are UHDM library code or generic helpers; keep the helper in the text."""
    frames = [fr(f) for f in bt]
    k = 0
    while k < len(frames) and (frames[k][1] in ('?', 'BaseClass.h') or not frames[k][1].endswith(('.cpp', '.h')) or frames[k][2] in HELPERS):
        k += 1
    if k >= len(frames): return '?', ' < '.join(x[0] for x in frames[:3])
    helper = [x[0] for x in frames[:k] if x[1].endswith(('.cpp', '.h')) and x[1] != 'BaseClass.h']
    txt = ' < '.join(x[0] for x in frames[k:k + 3])
    if helper: txt = f"[{helper[-1].split(' (')[0]}] " + txt
    return frames[k][1], txt
S = {}; G = {}
for p in sys.argv[4:]:
    for l in open(p):
        r = json.loads(l)
        k = r['cluster']
        mint = chain((r.get('mint') or [])[1:]) if r.get('mint') else ('?', 'no mint captured')
        hits = r.get('hits') or []
        how = 'mint'; w = mint
        if r.get('err') or r.get('db') != 'SAME' or r.get('rank') is None:
            S[k] = dict(writer='NOT PINNED (' + str(r.get('err') or r.get('db')) + ')', owner='?', how='-', field=r['facet'], example=r['example'], mint=mint[1]); continue
        if r['facet'] == 'fullname':
            st = [h for h in hits if 'VpiFullName' in h['bt'][0][1]]
            pw = [h for h in hits if 'VpiFullName' not in h['bt'][0][1]]
            if st and r['ours']: w = chain(st[-1]['bt'][1:]); how = 'setter'
            elif pw: w = chain(pw[-1]['bt']); how = 'parent'
        elif hits:
            h = hits[-1]; lib = h['bt'][0][2] in ('?', '') or 'basic_string_view' in h['bt'][0][1]
            w = chain(h['bt'][1:] if lib else h['bt']); how = 'setter' if lib else 'watch'
        prev = S.get(k)
        S[k] = dict(writer=w[1], owner=w[0], how=how, field=r['facet'] + ':' + r['fields'], example=f"{r['example']} #{r['rec']} {r['type']} '{r['name']}' golden={str(r['golden'])[:60]} ours={str(r['ours'])[:60]}",
                    mint=mint[1], mint_owner=mint[0], nwrites=r.get('nhits', 0), db=r.get('db'))
        if prev and not prev['writer'].startswith('NOT PINNED'):
            # a later file re-pins the cluster on another example (pinwriter.py PW_PREFER=corpus: a corpus row);
            # the earlier (probe-case) pin is kept beside it
            S[k].update(alt_writer=prev['writer'], alt_owner=prev['owner'], alt_example=prev['example'], alt_how=prev['how'])
        o = S[k]['owner']; G[k] = 'A' if o in GA else ('B' if o in GB else '?')
json.dump(S, open(OUT, 'w'), indent=1); json.dump(G, open(GOUT, 'w'), indent=1)
import collections
print(len(S), 'pinned;', dict(collections.Counter(v['how'] for v in S.values())), 'grounds', dict(collections.Counter(G.values())),
      'writer file != mint file:', sum(1 for v in S.values() if v.get('mint_owner') and v['owner'] != v['mint_owner']))
