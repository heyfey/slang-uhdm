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

    scripts/law_index.py --stamp         write a LAW file into every gate case
                                         dir whose law is determined, so the
                                         attribution no longer depends on prose

How the map stays current on its own:
  * a law is named `§ <name>` in the source, in its pass README and in its
    landing commit message (the commits column comes from `git log`);
  * every case dir under tests/probe/ carries a LAW file (one law name per
    line) or names its law in its first line as `// § <name>`; a case moved
    from tools/probe/ keeps its pass in the path and gets its LAW file from
    the README attribution when that is determined, else its author names it;
  * `scripts/law_index.py` is run before every commit that touches a law, a
    case or a README, and tests/sweep.sh fails when tests/LAWS.md is stale.

Anchors are names, never line numbers: `grep -n '§ <law>' src include` finds
a law's sites at any commit, and a switch is an environment variable name.
A case's laws are attributed at one of five levels: `file` (a LAW file in
the case dir), `text` (the case's own file names the law), `row` (a README
line names both the case and a law), `heading` (the README section whose
heading names a law mentions the case), `pass` (only the pass's own laws are
known)."""
import argparse, collections, csv, glob, io, os, re, subprocess, sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(REPO)
# A law name starts lowercase (camelCase) and usually ends in its pass number;
# older passes named laws without a number, and those are laws too.
LAW = re.compile(r'§\s*`?([a-z][A-Za-z0-9_]*(?:[0-9]+[a-z]{0,2}|[a-z0-9_][A-Z][A-Za-z0-9_]*))`?')
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
    for name in ('README.md', 'README.txt', 'README'):
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
    # gate) and every .sv, .v or .vh under tools/probe/<pass>/ (the evidence), attributed
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
        side = os.path.join(d, 'LAW')
        if os.path.exists(side):
            laws = {l.strip() for l in read(side).splitlines() if l.strip() and not l.startswith('#')}
            laws, how = laws, 'file'
        else:
            laws, how = attribute(parts[2], parts[-2], read(a))
        cases.append((d, parts[2], 'tests', laws, how))
    # Verilog-mode cases are dut.v / dut.vh (pass 235's vm grid); the index
    # reads them beside the .sv cases.
    for a in sorted(set(glob.glob('tools/probe/*/**/*.sv', recursive=True)
                        + glob.glob('tools/probe/*/**/*.v', recursive=True)
                        + glob.glob('tools/probe/*/**/*.vh', recursive=True))):
        parts = a.split('/')
        if len(parts) < 4:
            continue
        name = parts[-2] if parts[-1].startswith('dut.') else os.path.splitext(parts[-1])[0]
        laws, how = attribute(parts[2], name, read(a))
        cases.append((a, parts[2], 'tools', laws, how))
    return dict(files=files, switches=switches, primary=primary, mentioned=mentioned,
                title_tests=title_tests, commits=commits, commit_tests=commit_tests, own=own,
                verifies=verifies, ambiguous=ambiguous, cases=cases, readme=readme_of)


def render(ix):
    files, primary, commits = ix['files'], ix['primary'], ix['commits']
    cases = ix['cases']
    laws = sorted(set(files) | set(primary) | set(commits) | set(ix['mentioned']))
    # law -> [(case name, tree, sure)]: sure = the law is determined (the case's
    # text, a README row or heading, or a single-law pass); else the case is one
    # of the pass's laws and is listed under each with a trailing `?`.
    law_cases = collections.defaultdict(list)
    unattributed = []
    for path, pdir, tree, ls, how in cases:
        name = path.split('/', 2)[2]
        if not ls:
            unattributed.append((name, tree))
            continue
        sure = how in ('file', 'text', 'row', 'heading') or len(ls) == 1
        for law in ls:
            law_cases[law].append((name, tree, sure))
    verified_by = collections.defaultdict(list)
    for v, impl in ix['verifies'].items():
        verified_by[impl].append(v)
    n_gate = sum(1 for c in cases if c[2] == 'tests')
    n_sure = sum(1 for c in cases if c[2] == 'tests' and c[3] and (c[4] in ('file', 'text', 'row', 'heading') or len(c[3]) == 1))
    n_loose = sum(1 for c in cases if c[2] == 'tests' and len(c[3]) > 1 and c[4] == 'pass')
    n_none = sum(1 for c in cases if c[2] == 'tests' and not c[3])
    out = ['# The law index: laws, cases, commits', '',
           'This document records the map between the exporter\'s laws, the probe cases that',
           'exercise them and the commits that landed them. A law is `§ <name>` (the name ends',
           'in its pass number) at its source sites, in its pass README under',
           '`tools/probe/<pass>/` and in its landing commit. A probe case is one `dut.sv`',
           'written to exercise a law: under `tests/probe/` it is part of the gate, under',
           '`tools/probe/` it is evidence (older READMEs there say "arm"). The document is',
           'generated by `scripts/law_index.py` and regenerated at every landing (the sweep',
           'fails when it is stale); `scripts/law_index.py --law <name>` or `--case <dir>`',
           'prints one entry. Anchors are names, never line numbers: `grep -n \'§ <law>\' src',
           'include` finds a law\'s sites at any commit, and a switch is an environment',
           'variable name.', '',
           'How a case is tied to its law: a LAW file in its dir (one law name per line, the',
           'durable form; `--stamp` writes it wherever the law is determined), or its own text',
           'names the law, or the pass README names the law on the case\'s row or in the heading',
           'of the section that mentions it, or the pass owns a single law. When a pass owns',
           'several laws and nothing says which one a case exercises, the case is listed under',
           'each of them with a trailing `?` until its author writes its LAW file. A',
           'verification pass owns the laws of the pass it verifies.', '',
           f"Laws: {len(laws)}. Cases in the gate: {n_gate}, tied to one law {n_sure}, listed with `?`",
           f"under several {n_loose}, tied to no law {n_none} (listed at the end).",
           f"Laws with a commit on this branch: {sum(1 for l in laws if l in commits)};",
           f"laws with cases in the gate: {sum(1 for l in laws if any(t == 'tests' for _, t, _ in law_cases.get(l, [])))}.", '',
           '## 1. Laws', '']
    for law in laws:
        ps = primary.get(law, [])
        impls = [p for p in ps if p not in ix['verifies']]
        vers = [p for p in ps if p in ix['verifies']]
        gate = sorted((n + ('' if sure else '?')) for n, t, sure in law_cases.get(law, []) if t == 'tests')
        evid = sorted((n + ('' if sure else '?')) for n, t, sure in law_cases.get(law, []) if t == 'tools')
        tests = sorted(ix['title_tests'].get(law, set()) | ix['commit_tests'].get(law, set()))
        out.append(f"### `{law}`" + (' (ambiguous: two implement passes name it)' if law in ix['ambiguous'] else ''))
        out.append(f"- commits: {' '.join(commits.get(law, [])) or 'none on this branch'}")
        out.append(f"- pass: {' '.join(impls) or '-'}" + (f" (verified by {' '.join(vers)})" if vers else ''))
        if ix['switches'].get(law):
            out.append(f"- switches: {' '.join(sorted(ix['switches'][law]))}")
        out.append(f"- source: {' '.join(f'{f}({c})' for f, c in sorted(files[law].items())) or 'not in the source'}")
        if tests:
            out.append(f"- corpus tests: {' '.join(tests)}")
        out.append(f"- cases in the gate (tests/probe/): {' '.join(gate) or 'none'}")
        out.append(f"- cases in the evidence (tools/probe/): {' '.join(evid) or 'none'}")
        if ix['mentioned'].get(law):
            out.append(f"- also mentioned by: {' '.join(ix['mentioned'][law])}")
        out.append('')
    out += ['## 2. Passes', '',
            'Each pass, the pass it verifies, and the laws it owns. A case under',
            '`tests/probe/<pass>/` or `tools/probe/<pass>/` belongs to one of them (section 1',
            'lists it under the law).', '',
            '| pass | verifies | laws | cases in the gate | cases in the evidence |', '|---|---|---|---|---|']
    by_pass = collections.defaultdict(lambda: {'tests': 0, 'tools': 0})
    for path, pdir, tree, ls, how in cases:
        by_pass[pdir][tree] += 1
    for p in sorted(set(ix['own']) | set(by_pass)):
        out.append(f"| {p} | {ix['verifies'].get(p, '')} | {' '.join('`%s`' % l for l in sorted(ix['own'].get(p, [])))} | "
                   f"{by_pass[p]['tests']} | {by_pass[p]['tools']} |")
    if unattributed:
        out += ['', '## 3. Cases tied to no law', '',
                'The pass has no README, or its README names no law. Each is a residue for the',
                'pass\'s author to name.', '']
        out.append('- gate: ' + ' '.join(sorted(n for n, t in unattributed if t == 'tests')))
        out.append('- evidence: ' + ' '.join(sorted(n for n, t in unattributed if t == 'tools')))
    return '\n'.join(out).rstrip('\n') + '\n'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--check', action='store_true')
    ap.add_argument('--law')
    ap.add_argument('--case')
    ap.add_argument('--stamp', action='store_true', help='write LAW files where the law is determined')
    args = ap.parse_args()
    ix = build()
    if args.stamp:
        n = 0
        for path, pdir, tree, ls, how in ix['cases']:
            if tree != 'tests' or how == 'file' or not ls:
                continue
            if how in ('text', 'row', 'heading') or len(ls) == 1:
                with open(os.path.join(path, 'LAW'), 'w') as f:
                    f.write('\n'.join(sorted(ls)) + '\n')
                n += 1
        print(f'stamped {n} LAW files')
        return 0
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
    print('wrote tests/LAWS.md: ' + ' '.join(text.splitlines()[19:22]).strip())
    return 0


if __name__ == '__main__':
    sys.exit(main())
