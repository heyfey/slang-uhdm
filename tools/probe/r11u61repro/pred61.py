#!/usr/bin/env python3
"""r11u61 A-PRIORI MOVER PREDICTOR — reads PRISTINE DATABASES ONLY, never a
golden and never a patched database, so its answer is a prediction and not a
measurement wearing a prediction's label.

A cell is predicted to move when BOTH halves hold:
  DUMP half   — its pristine database carries at least one ELABORATED-listing
                (`uhdmtopModules`) `param_assign` whose Rhs is an op75 over a
                STRUCT typespec.  That is the only cell shape this law's walk
                can re-produce, whatever it then writes into it.
  TYPE half   — the op's `struct_typespec` is UNPACKED.  `uhdm-dump` prints
                `|vpiPacked:1` under a PACKED struct typespec and nothing under
                an unpacked one, on both sides, so the law's
                `pctS.kind == UnpackedStructType` fence has an exact mirror in
                the pristine database alone.  A struct typespec printed with no
                NAME is treated as unpacked (over-inclusive on purpose).

The prediction is deliberately over-inclusive -- it does not check the shape
fences (concat / replication / override / `time` / `real` / >64-bit member),
only the view and the type.  Over-prediction is stated, never hidden: the gate
is that every MEASURED byte mover lies inside this set.

A FIRST CUT of this instrument used the operand SHAPE -- "an operand past the
first still at the unsized 64" -- and it MISSED `rp32_r5p_alu` /
`rp32_r5p_wbu`, whose pristine operands were already at the right widths and
whose databases still moved (byte ORDER only; the order-blind dump diff is 0
lines and the rows stay CMP_EQUAL).  The lesson is recorded here rather than in
a corrected count: a predictor keyed on the SYMPTOM cannot bound a law keyed on
the TYPE.

usage: pred61.py <workdir> <mode>    [env CENSUS_JOBS=2]
"""
import os, re, subprocess, sys, concurrent.futures
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import shape

DUMP = '/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump'
ELABSECT = ('uhdmtopModules',)
STRUCTOP = re.compile(r'op=75 ts=struct_typespec\(([^)]*)\)')
STS = re.compile(r'^(\s*)\\_struct_typespec: (\(([^)]*)\))?')


def packed_struct_names(lines):
    """the NAMES of every struct typespec printed WITH `|vpiPacked:1`, and the
    names of every struct typespec printed at all.  A name that never appears
    packed is an UNPACKED struct in this database."""
    packed, seen = set(), set()
    for i, ln in enumerate(lines):
        m = STS.match(ln)
        if not m:
            continue
        nm = m.group(3) or ''
        seen.add(nm)
        base = len(m.group(1))
        for l2 in lines[i + 1:]:
            if l2.strip() and (len(l2) - len(l2.lstrip())) <= base:
                break
            if l2.lstrip().startswith('|vpiPacked:'):
                packed.add(nm)
                break
    return packed, seen


def one(root, d):
    p = os.path.join(root, d)
    name = d.rsplit('-', 1)[0]
    o = os.path.join(p, 'slang.uhdm')
    res = {'name': name, 'cand': 0, 'hits': [], 'note': ''}
    if not os.path.exists(o):
        res['note'] = 'NOFILE'
        return res
    try:
        r = subprocess.run([DUMP, o], capture_output=True, text=True, timeout=1800)
    except subprocess.TimeoutExpired:
        res['note'] = 'TIMEOUT'
        return res
    if r.returncode:
        res['note'] = 'DUMPRC%d' % r.returncode
        return res
    tmp = '/tmp/r11u61_pred_%s_%d.txt' % (re.sub(r'\W', '_', name), os.getpid())
    open(tmp, 'w').write(r.stdout)
    packed, _seen = packed_struct_names(r.stdout.splitlines())
    for a, b, c, dd in shape.parse(tmp):
        m = STRUCTOP.match(dd)
        if a not in ELABSECT or not m:
            continue
        res['cand'] += 1
        if m.group(1) not in packed:
            res['hits'].append((a, b, c))
    os.unlink(tmp)
    return res


wd, mode = sys.argv[1], sys.argv[2]
root = os.path.join(wd, mode)
dirs = sorted(d for d in os.listdir(root) if os.path.isdir(os.path.join(root, d)))
jobs = int(os.environ.get('CENSUS_JOBS', '2'))
cand = 0
names = []
with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as ex:
    for res in ex.map(lambda d: one(root, d), dirs):
        if res['note']:
            print('NOTE %s %s %s' % (res['name'], mode, res['note']))
            continue
        cand += res['cand']
        for a, b, c in res['hits']:
            print('PRED %-34s %-17s %-32s %s' % (res['name'], a, b, c))
            names.append(res['name'])
print('== %s %s: CANDIDATE ELAB struct-op cells=%d  PREDICTED=%d cells on %d tests'
      % (wd, mode, cand, len(names), len(set(names))))
print('== PREDICTED TESTS: %s' % ' '.join(sorted(set(names))))
