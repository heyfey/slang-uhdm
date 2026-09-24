#!/usr/bin/env python3
"""The law index, tests/LAWS.md: every law (a `§ name` in the exporter source,
a pass README or a commit message) mapped back to its pass, its landing
commits, its source files and switches, the probe cases that exercise it
under tests/probe/ (the gate) and tools/probe/ (the evidence), and the corpus
tests it names. One generated document; regenerate it at every landing
(`tests/sweep.sh` runs `--check` and fails when it is stale).

    scripts/law_index.py                 write tests/LAWS.md
    scripts/law_index.py --check         exit 1 when tests/LAWS.md is stale
    scripts/law_index.py --law NAME      print one law's record
    scripts/law_index.py --case PATH     print the laws of one probe case (a dir
                                         under tests/probe/ or tools/probe/)

Anchors are names, never line numbers: `grep -n '§ <law>' src include` finds
a law's sites at any commit, and a switch is an environment variable name.
A case's laws are attributed at one of four levels: `text` (the case's own
file names the law), `row` (a README line names both the case and a law),
`heading` (the README section whose heading names a law mentions the case),
`pass` (only the pass's own laws are known)."""
import argparse, collections, csv, glob, io, os, re, subprocess, sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(REPO)
LAW = re.compile(r'§\s*`?([a-z][A-Za-z0-9_]*[0-9]+[a-z]{0,2})`?')
SWITCH_SRC = re.compile(r'getenv\("([A-Z][A-Z0-9_]+)"\)')
SWITCH_TXT = re.compile(r'\b([A-Z][A-Z0-9]*[0-9][A-Z0-9_]*_(?:OFF|ON|DBG))\b')
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


def build():
    corpus = corpus_names()
    # 1. Source files per law (site counts) and the switches near a site.
    files = collections.defaultdict(collections.Counter)
    switches = collections.defaultdict(set)
    for f in SOURCES:
        lines = read(f).splitlines()
        for i, l in enumerate(lines):
            for law in LAW.findall(l):
                files[law][f] += 1
                for k in range(max(0, i - 40), min(len(lines), i + 41)):
                    switches[law] |= set(SWITCH_SRC.findall(lines[k]))

    # 2. Pass READMEs. A pass owns the laws its title names and the body
    # mentions carrying its number (a law's name ends in its pass number:
    # `...118`, `...118v`; r11u118repro is pass 118). A verification pass (its
    # title says so) owns the laws of the pass it verifies: the pass its title
    # names, else the one implement pass with the same number.
    pass_dirs = sorted(d.split('/')[2] for d in glob.glob('tools/probe/*/'))
    title, body_laws, lines_of = {}, {}, {}
    for pdir in pass_dirs:
        r = readme_of(pdir)
        if r:
            lines_of[pdir] = read(r).splitlines()
            title[pdir] = lines_of[pdir][0] if lines_of[pdir] else ''
            body_laws[pdir] = set(LAW.findall('\n'.join(lines_of[pdir])))
    verifier = {p: 'verif' in title[p].lower() for p in title}
    impls_by_num = collections.defaultdict(list)
    for p in title:
        if not verifier[p] and pass_number(p):
            impls_by_num[pass_number(p)].append(p)
    verifies = {}
    for p in title:
        if not verifier[p]:
            continue
        for tok in re.findall(r'\b([a-z][a-z0-9]+)\b', title[p]):
            q = tok + 'repro'
            if q in title and q != p and not verifier[q]:
                verifies[p] = q
                break
        if p not in verifies and len(impls_by_num.get(pass_number(p), [])) == 1:
            verifies[p] = impls_by_num[pass_number(p)][0]
        if p not in verifies:
            # The implement pass whose README title names the same law.
            for law in set(LAW.findall(title[p])):
                hits = [q for q in title if not verifier[q] and law in set(LAW.findall(title[q]))]
                if len(hits) == 1:
                    verifies[p] = hits[0]
                    break
    own = {}
    for p in title:
        s = set(LAW.findall(title[p]))
        if p not in verifies:
            s |= {l for l in body_laws[p] if law_number(l) == pass_number(p)}
        own[p] = s
    for p, impl in verifies.items():
        own[p] |= own.get(impl, set())
    primary, mentioned = collections.defaultdict(list), collections.defaultdict(list)
    title_tests = collections.defaultdict(set)
    for p in pass_dirs:
        if p not in title:
            continue
        for law in own[p]:
            primary[law].append(p)
        for law in body_laws[p] - own[p]:
            mentioned[law].append(p)
        for law in set(LAW.findall(title[p])):
            title_tests[law] |= {w for w in re.findall(r'[A-Za-z0-9_]+', title[p]) if w in corpus}
        for i, l in enumerate(lines_of[p]):
            for law in set(LAW.findall(l)) & own[p]:
                for k in range(max(0, i - 15), min(len(lines_of[p]), i + 16)):
                    switches[law] |= set(SWITCH_TXT.findall(lines_of[p][k]))
    ambiguous = {law for law, ps in primary.items()
                 if len({verifies.get(p, p) for p in ps}) > 1}

    # 3. Commits naming the law (this branch).
    log = subprocess.run(['git', 'log', '--format=%h%x00%s%x00%B%x01'], capture_output=True,
                         text=True, errors='replace').stdout
    commits, commit_tests = collections.defaultdict(list), collections.defaultdict(set)
    for entry in log.split('\x01'):
        if '\x00' not in entry:
            continue
        sha, subject, body = entry.strip('\n').split('\x00', 2)
        words = set(re.findall(r'[A-Za-z0-9_]+', subject))
        for law in set(LAW.findall(body)):
            commits[law].append(sha)
            commit_tests[law] |= {w for w in words if w in corpus}

    # 4. Probe cases: every dir under tests/probe/<pass>/ holding a dut.sv (the
    # gate) and every .sv under tools/probe/<pass>/ (the evidence), attributed
    # to laws at a level.
    cases = []   # (path, pass, tree, laws, how)
    def attribute(pdir, name, text):
        laws = set(LAW.findall(text))
        if laws:
            return laws, 'text'
        if pdir not in lines_of:
            return set(), 'none'
        row, head, cur = set(), set(), set()
        pat = re.compile(r'(?<![A-Za-z0-9_])' + re.escape(name) + r'(?![A-Za-z0-9_])')
        for l in lines_of[pdir]:
            ls = set(LAW.findall(l))
            if l.startswith('#') and ls:
                cur = ls
            if pat.search(l):
                if ls:
                    row |= ls
                elif cur:
                    head |= cur
        if row:
            return row, 'row'
        if head:
            return head, 'heading'
        if own.get(pdir):
            return own[pdir], 'pass'
        return set(), 'none'
    for a in sorted(glob.glob('tests/probe/*/**/dut.sv', recursive=True)):
        parts = a.split('/')
        d = os.path.dirname(a)
        laws, how = attribute(parts[2], parts[-2], read(a))
        cases.append((d, parts[2], 'tests', laws, how))
    for a in sorted(glob.glob('tools/probe/*/**/*.sv', recursive=True)):
        parts = a.split('/')
        if len(parts) < 4:
            continue
        name = parts[-2] if parts[-1] == 'dut.sv' else os.path.splitext(parts[-1])[0]
        laws, how = attribute(parts[2], name, read(a))
        cases.append((a, parts[2], 'tools', laws, how))
    return dict(files=files, switches=switches, primary=primary, mentioned=mentioned,
                title_tests=title_tests, commits=commits, commit_tests=commit_tests, own=own,
                verifies=verifies, ambiguous=ambiguous, cases=cases, readme=readme_of)


def render(ix):
    files, primary, commits = ix['files'], ix['primary'], ix['commits']
    cases = ix['cases']
    laws = sorted(set(files) | set(primary) | set(commits) | set(ix['mentioned']))
    by_law = collections.defaultdict(lambda: {'tests': 0, 'tools': 0})
    by_pass = collections.defaultdict(lambda: {'tests': 0, 'tools': 0})
    exact = collections.defaultdict(lambda: collections.defaultdict(list))  # pass -> law -> [case names]
    for path, pdir, tree, ls, how in cases:
        by_pass[pdir][tree] += 1
        for law in ls:
            by_law[law][tree] += 1
        if how in ('text', 'row', 'heading') and tree == 'tests':
            for law in ls:
                exact[pdir][law].append(path.split('/', 3)[3])
    how_count = collections.Counter(c[4] for c in cases if c[2] == 'tests')
    n_tests_cases = sum(1 for c in cases if c[2] == 'tests')
    n = dict(src=sum(1 for l in laws if l in files), commit=sum(1 for l in laws if l in commits),
             readme=sum(1 for l in laws if l in primary), cases=sum(1 for l in laws if by_law[l]['tests']))
    out = ['# The law index', '',
           'A law is an exporter rule named `§ <name>` (the name ends in its pass number) at',
           'its source sites, in its pass README under `tools/probe/<pass>/` and in its',
           'landing commit. This document maps every law back to its pass, its commits on',
           'this branch, its source files and switches, the probe cases that exercise it',
           '(`tests/probe/`, the gate; `tools/probe/`, the evidence grids) and the corpus',
           'tests it names. It is generated by `scripts/law_index.py` and regenerated at',
           'every landing (`tests/sweep.sh` fails when it is stale). Ask the script for one',
           'record: `scripts/law_index.py --law <name>` or `--case <dir>`.', '',
           'Anchors are names, never line numbers: `grep -n \'§ <law>\' src include` finds',
           'a law\'s sites at any commit, and a switch is an environment variable name.',
           'Older pass READMEs call a probe case an "arm".', '',
           f"Laws: {len(laws)} ({n['src']} in the source, {n['commit']} with a commit on this branch,",
           f"{n['readme']} with a pass README, {n['cases']} with cases in tests/probe, {len(ix['ambiguous'])}",
           'ambiguous: two implement passes share the number and both name the law).', '',
           f"Probe cases in the gate: {n_tests_cases}, attributed to a law by the case's own text",
           f"{how_count['text']}, by a README row {how_count['row']}, by a README section heading",
           f"{how_count['heading']}, to the pass's law set only {how_count['pass']}, not at all (no",
           f"README or a README naming no law) {how_count['none']}. Section 2 lists the exact ones.", '',
           '## 1. Laws', '',
           '| law | pass | commits | switches | cases tests/probe | cases tools/probe | corpus tests | source files |',
           '|---|---|---|---|---|---|---|---|']
    for law in laws:
        ps = primary.get(law, [])
        tests = sorted(ix['title_tests'].get(law, set()) | ix['commit_tests'].get(law, set()))
        src = ' '.join(f'{f}({c})' for f, c in sorted(files[law].items())) if law in files else ''
        out.append(f"| `{law}`{' (ambiguous)' if law in ix['ambiguous'] else ''} | {' '.join(ps)} | "
                   f"{' '.join(commits.get(law, []))} | {' '.join(sorted(ix['switches'].get(law, set())))} | "
                   f"{by_law[law]['tests']} | {by_law[law]['tools']} | {' '.join(tests)} | {src} |")
    out += ['', '## 2. Passes: their laws and cases', '',
            'Each pass owns the laws its README title names, the body mentions carrying its',
            'number, and for a verification pass the laws of the pass it verifies. A case',
            'under `tests/probe/<pass>/` belongs to one of the pass\'s laws; where the README',
            'or the case itself says which, the case is listed under that law.', '']
    for p in sorted(set(ix['own']) | set(by_pass)):
        own = sorted(ix['own'].get(p, []))
        v = ix['verifies'].get(p)
        out.append(f"### {p}" + (f" (verifies {v})" if v else ''))
        out.append('')
        rd = ix['readme'](p)
        out.append(f"README: {rd if rd else 'none'}. Laws: " +
                   (' '.join(f'`{l}`' for l in own) if own else 'none named') +
                   f". Cases: {by_pass[p]['tests']} in tests/probe, {by_pass[p]['tools']} in tools/probe.")
        for law in sorted(exact.get(p, {})):
            out.append(f"- `{law}`: " + ' '.join(sorted(exact[p][law])))
        out.append('')
    return '\n'.join(out).rstrip('\n') + '\n'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--check', action='store_true')
    ap.add_argument('--law')
    ap.add_argument('--case')
    args = ap.parse_args()
    ix = build()
    if args.law:
        law = args.law
        print(f"law {law}\n  pass: {' '.join(ix['primary'].get(law, [])) or '-'}"
              f"\n  commits: {' '.join(ix['commits'].get(law, [])) or '-'}"
              f"\n  switches: {' '.join(sorted(ix['switches'].get(law, set()))) or '-'}"
              f"\n  source: {' '.join(f'{f}({c})' for f, c in sorted(ix['files'].get(law, {}).items())) or '-'}"
              f"\n  corpus tests: {' '.join(sorted(ix['title_tests'].get(law, set()) | ix['commit_tests'].get(law, set()))) or '-'}"
              f"\n  mentioned in: {' '.join(ix['mentioned'].get(law, [])) or '-'}")
        for path, pdir, tree, ls, how in ix['cases']:
            if law in ls:
                print(f'  case ({how}): {path}')
        return 0
    if args.case:
        want = os.path.relpath(os.path.abspath(args.case), REPO).rstrip('/')
        hit = [c for c in ix['cases'] if c[0] == want or c[0] == want + '/dut.sv' or os.path.dirname(c[0]) == want]
        if not hit:
            print(f'{want}: not a probe case')
            return 1
        for path, pdir, tree, ls, how in hit:
            print(f"{path}: pass {pdir}; laws ({how}): {' '.join(sorted(ls)) or '-'}")
        return 0
    text = render(ix)
    if args.check:
        if not os.path.exists('tests/LAWS.md') or read('tests/LAWS.md') != text:
            print('law index STALE: tests/LAWS.md (run scripts/law_index.py)')
            return 1
        print('law index current')
        return 0
    with open('tests/LAWS.md', 'w') as f:
        f.write(text)
    print('wrote tests/LAWS.md: ' + text.splitlines()[15].strip())
    return 0


if __name__ == '__main__':
    sys.exit(main())
