#!/usr/bin/env python3
"""The law index: every law (a `§ name` in the exporter source, a pass README
or a commit message) mapped back to its pass, its landing commits, its source
files and switches, its arms under tests/probe and tools/probe, and the corpus
tests it names; and every arm under tests/probe mapped to its laws with the
level of that attribution. Writes tests/LAWS.csv, tests/LAWS.md and
tests/ARMS.csv; `--check` exits 1 when the committed files are stale (part of
tests/sweep.sh).

Anchors are names, never line numbers: a law is found in the source with
`grep -n '§ <law>' src include`, and its switch is an environment variable
name; both survive every edit that keeps the law."""
import argparse, collections, csv, glob, io, os, re, subprocess, sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(REPO)
LAW = re.compile(r'§\s*`?([a-z][A-Za-z0-9_]*[0-9]+[a-z]{0,2})`?')
SWITCH_SRC = re.compile(r'getenv\("([A-Z][A-Z0-9_]+)"\)')
SWITCH_TXT = re.compile(r'\b([A-Z][A-Z0-9]*[0-9][A-Z0-9_]*_(?:OFF|ON|DBG))\b')
VERIFIES = re.compile(r'verification of\s+`?([a-z][a-z0-9]+)', re.I)
SOURCES = sorted(glob.glob('src/*.cpp') + glob.glob('include/*.h') + ['uhdm_main.cpp'])


def read(p):
    with open(p, errors='replace') as f:
        return f.read()


def law_number(law):
    m = re.search(r'([0-9]+)[a-z]{0,2}$', law)
    return m.group(1) if m else None


def pass_number(pdir):
    m = re.search(r'([0-9]+)[a-z]?repro$', pdir)
    return m.group(1) if m else None


def readme_of(pdir):
    for name in ('README.md', 'README.txt'):
        p = f'tools/probe/{pdir}/{name}'
        if os.path.exists(p):
            return p
    return None


def corpus_names():
    names = set()
    for p in ('results/golden_surelog.csv', 'results/golden_uhdm2rtlil.csv'):
        if os.path.exists(p):
            for row in csv.reader(io.StringIO(read(p))):
                if row and row[0] != 'name':
                    names.add(row[0])
    return names


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--check', action='store_true', help='exit 1 when tests/LAWS.* and tests/ARMS.csv are stale')
    args = ap.parse_args()
    corpus = corpus_names()

    # 1. Source files per law (counts, no line numbers) and the switches near a site.
    files = collections.defaultdict(collections.Counter)   # law -> {file: sites}
    switches = collections.defaultdict(set)
    for f in SOURCES:
        lines = read(f).splitlines()
        for i, l in enumerate(lines):
            for law in LAW.findall(l):
                files[law][f] += 1
                for k in range(max(0, i - 40), min(len(lines), i + 41)):
                    for sw in SWITCH_SRC.findall(lines[k]):
                        switches[law].add(sw)

    # 2. Pass READMEs. A pass's own laws: the ones its title names, then the body
    # mentions whose number is the pass's number (a law's name ends in its pass
    # number: `...118`, `...118v`; r11u118repro is pass 118). A verification pass
    # ("adversarial verification of r11u110") owns the laws of the pass it verifies.
    pass_dirs = sorted(d.split('/')[2] for d in glob.glob('tools/probe/*/'))
    title = {}
    body_laws = {}
    verifies = {}
    for pdir in pass_dirs:
        r = readme_of(pdir)
        if not r:
            continue
        lines = read(r).splitlines()
        title[pdir] = lines[0] if lines else ''
        body_laws[pdir] = set(LAW.findall('\n'.join(lines)))
        m = VERIFIES.search(title[pdir])
        if m and m.group(1) + 'repro' in pass_dirs and m.group(1) + 'repro' != pdir:
            verifies[pdir] = m.group(1) + 'repro'
    # A verification pass (its title says so) owns the laws its title names and
    # the laws of the pass it verifies: the pass dir its title names, else the
    # one implement pass with the same number.
    verifier = {pdir: 'verif' in title[pdir].lower() for pdir in title}
    impls_by_num = collections.defaultdict(list)
    for pdir in title:
        if not verifier[pdir] and pass_number(pdir):
            impls_by_num[pass_number(pdir)].append(pdir)
    for pdir in title:
        if verifier[pdir] and pdir not in verifies:
            for tok in re.findall(r'\b([a-z][a-z0-9]+)\b', title[pdir]):
                if tok + 'repro' in title and tok + 'repro' != pdir and not verifier[tok + 'repro']:
                    verifies[pdir] = tok + 'repro'
                    break
            if pdir not in verifies and len(impls_by_num.get(pass_number(pdir), [])) == 1:
                verifies[pdir] = impls_by_num[pass_number(pdir)][0]
    own = {}
    for pdir in title:
        pnum = pass_number(pdir)
        s = set(LAW.findall(title[pdir]))
        if not (verifier[pdir] and pdir in verifies):
            s |= {l for l in body_laws[pdir] if pnum and law_number(l) == pnum}
        own[pdir] = s
    for pdir, impl in verifies.items():
        own[pdir] |= own.get(impl, set())
    primary = collections.defaultdict(list)
    mentioned = collections.defaultdict(list)
    title_tests = collections.defaultdict(set)
    for pdir in pass_dirs:
        if pdir not in title:
            continue
        for law in own[pdir]:
            primary[law].append(pdir)
        for law in body_laws[pdir] - own[pdir]:
            mentioned[law].append(pdir)
        tl = set(LAW.findall(title[pdir]))
        for law in tl:
            title_tests[law] |= {w for w in re.findall(r'[A-Za-z0-9_]+', title[pdir]) if w in corpus}
        lines = read(readme_of(pdir)).splitlines()
        for i, l in enumerate(lines):
            for law in set(LAW.findall(l)) & own[pdir]:
                for k in range(max(0, i - 15), min(len(lines), i + 16)):
                    switches[law] |= set(SWITCH_TXT.findall(lines[k]))
    # A law owned by more than one implement pass (verification passes aside)
    # is ambiguous: two pass families share a number.
    ambiguous = set()
    for law, ps in primary.items():
        impls = {verifies.get(p, p) for p in ps if not verifier.get(p) or p in verifies}
        if len(impls) > 1:
            ambiguous.add(law)

    # 3. Commits naming the law (current branch).
    log = subprocess.run(['git', 'log', '--format=%h%x00%s%x00%B%x01'], capture_output=True,
                         text=True, errors='replace').stdout
    commits = collections.defaultdict(list)
    commit_tests = collections.defaultdict(set)
    for entry in log.split('\x01'):
        if '\x00' not in entry:
            continue
        sha, subject, body = entry.strip('\n').split('\x00', 2)
        words = set(re.findall(r'[A-Za-z0-9_]+', subject))
        for law in set(LAW.findall(body)):
            commits[law].append(sha)
            commit_tests[law] |= {w for w in words if w in corpus}

    # 4. Arms. Under tests/probe every arm is attributed to its laws at one of
    # four levels: `text` (the arm's own file names the law), `row` (a README
    # line names both the arm and a law), `heading` (the README section whose
    # heading names a law mentions the arm), `pass` (only the pass's own laws
    # are known). Under tools/probe arms are counted per pass.
    arms_tests = collections.Counter()
    arms_tools = collections.Counter()
    law_arms = collections.defaultdict(list)       # law -> arms under tests/probe
    arm_rows = []
    readme_lines = {}
    for a in sorted(glob.glob('tests/probe/**/*.sv', recursive=True)):
        parts = a.split('/')
        pdir, arm = parts[2], parts[-2]
        arms_tests[pdir] += 1
        text_laws = set(LAW.findall(read(a)))
        laws, how = set(), 'none'
        if text_laws:
            laws, how = text_laws, 'text'
        elif readme_of(pdir):
            if pdir not in readme_lines:
                readme_lines[pdir] = read(readme_of(pdir)).splitlines()
            row, head, cur = set(), set(), set()
            for l in readme_lines[pdir]:
                ls = set(LAW.findall(l))
                if l.startswith('#') and ls:
                    cur = ls
                if re.search(r'(?<![A-Za-z0-9_])' + re.escape(arm) + r'(?![A-Za-z0-9_])', l):
                    if ls:
                        row |= ls
                    elif cur:
                        head |= cur
            if row:
                laws, how = row, 'row'
            elif head:
                laws, how = head, 'heading'
            elif own.get(pdir):
                laws, how = own[pdir], 'pass'
        for law in laws:
            law_arms[law].append(a)
        arm_rows.append({'arm': a, 'pass': pdir, 'laws': ' '.join(sorted(laws)), 'how': how})
    for a in sorted(glob.glob('tools/probe/**/*.sv', recursive=True)):
        parts = a.split('/')
        if len(parts) > 3:
            arms_tools[parts[2]] += 1

    laws = sorted(set(files) | set(primary) | set(commits) | set(mentioned))
    rows = []
    for law in laws:
        ps = primary.get(law, [])
        rows.append({
            'law': law,
            'pass': ' '.join(ps),
            'ambiguous': 'yes' if law in ambiguous else '',
            'readme': ' '.join(readme_of(p) for p in ps if readme_of(p)),
            'commits': ' '.join(commits.get(law, [])),
            'switches': ' '.join(sorted(switches.get(law, set()))),
            'source_files': ' '.join(f'{f}({n})' for f, n in sorted(files[law].items())) if law in files else '',
            'arms_tests_probe': len(law_arms.get(law, [])),
            'arms_tools_probe': sum(arms_tools[p] for p in ps),
            'corpus_tests': ' '.join(sorted(title_tests.get(law, set()) | commit_tests.get(law, set()))),
            'mentioned_in': ' '.join(mentioned.get(law, [])),
        })

    def to_csv(fields, rs):
        buf = io.StringIO()
        w = csv.DictWriter(buf, fieldnames=fields, lineterminator='\n')
        w.writeheader()
        for r in rs:
            w.writerow(r)
        return buf.getvalue()

    law_fields = ['law', 'pass', 'ambiguous', 'readme', 'commits', 'switches', 'source_files',
                  'arms_tests_probe', 'arms_tools_probe', 'corpus_tests', 'mentioned_in']
    csv_text = to_csv(law_fields, rows)
    arms_text = to_csv(['arm', 'pass', 'laws', 'how'], arm_rows)

    n_src = sum(1 for r in rows if r['source_files'])
    n_commit = sum(1 for r in rows if r['commits'])
    n_pass = sum(1 for r in rows if r['pass'])
    n_arms = sum(1 for r in rows if r['arms_tests_probe'])
    how = collections.Counter(r['how'] for r in arm_rows)
    md = ['# The law index', '',
          'Every law is a `§ name` (the name ends in its pass number) in the exporter source,',
          'a pass README under `tools/probe/`, or a commit message. This index maps each law',
          'back to its pass, its landing commits, its source files and switches, its arms in',
          '`tests/probe/` (the gate) and `tools/probe/` (the evidence grids), and the corpus',
          'tests its title and commits name. Generated by `scripts/law_index.py`; regenerate',
          'it at every landing (`tests/sweep.sh` fails when it is stale). `tests/LAWS.csv` is',
          'the machine-readable form; `tests/ARMS.csv` maps every arm under `tests/probe/`',
          'to its laws with the level of that attribution.', '',
          'Anchors are names, never line numbers: find a law in the source with',
          '`grep -n \'§ <law>\' src include`; its switch is an environment variable name.', '',
          f'Laws: {len(rows)} ({n_src} in the source, {n_commit} with a commit on this branch,',
          f'{n_pass} with a pass README, {n_arms} with arms in tests/probe, {len(ambiguous)} ambiguous:',
          'two pass families share the number).', '',
          f"Arms under tests/probe: {len(arm_rows)}; attributed by the arm's own text {how['text']},",
          f"by a README row {how['row']}, by a README section heading {how['heading']}, to the",
          f"pass's law set only {how['pass']}, not at all (no README) {how['none']}.", '',
          '| law | pass | commits | switches | arms tests/probe | arms tools/probe | corpus tests | source files |',
          '|---|---|---|---|---|---|---|---|']
    for r in rows:
        md.append(f"| `{r['law']}`{' (ambiguous)' if r['ambiguous'] else ''} | {r['pass']} | {r['commits']} | "
                  f"{r['switches']} | {r['arms_tests_probe']} | {r['arms_tools_probe']} | {r['corpus_tests']} | "
                  f"{r['source_files']} |")
    md += ['', '## Pass -> laws', '',
           'The laws each pass owns (its README title, the body mentions carrying its number,',
           'and for a verification pass the laws of the pass it verifies). An arm under',
           '`tests/probe/<pass>/` belongs to one of these; `tests/ARMS.csv` says which when',
           'the README or the arm says.', '',
           '| pass | verifies | laws | arms tests/probe | arms tools/probe |', '|---|---|---|---|---|']
    for p in sorted(set(own) | set(arms_tests) | set(arms_tools)):
        md.append(f"| {p} | {verifies.get(p, '')} | {' '.join('`%s`' % l for l in sorted(own.get(p, [])))} | "
                  f"{arms_tests[p]} | {arms_tools[p]} |")
    md_text = '\n'.join(md) + '\n'

    outputs = (('tests/LAWS.csv', csv_text), ('tests/LAWS.md', md_text), ('tests/ARMS.csv', arms_text))
    if args.check:
        stale = [p for p, t in outputs if not os.path.exists(p) or read(p) != t]
        if stale:
            print('law index STALE: ' + ' '.join(stale) + ' (run scripts/law_index.py)')
            return 1
        print(f'law index current: {len(rows)} laws, {len(arm_rows)} arms')
        return 0
    for p, t in outputs:
        with open(p, 'w') as f:
            f.write(t)
    print(f'wrote tests/LAWS.csv + tests/LAWS.md + tests/ARMS.csv: {len(rows)} laws ({n_src} in the source, '
          f'{n_commit} with commits, {n_pass} with a pass README, {n_arms} with arms in tests/probe, '
          f'{len(ambiguous)} ambiguous); arms {len(arm_rows)}: ' +
          ' '.join(f'{k}={v}' for k, v in sorted(how.items())))
    return 0


if __name__ == '__main__':
    sys.exit(main())
