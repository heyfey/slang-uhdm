#!/usr/bin/env python3
"""The law index: every law (a `§ name` in the exporter source, a pass README
or a commit message) mapped back to its pass, its landing commits, its source
sites and switches, its arms under tests/probe and tools/probe, and the corpus
tests it names. Writes tests/LAWS.csv and tests/LAWS.md; `--check` exits 1
when the committed files are stale (part of tests/sweep.sh)."""
import argparse, collections, csv, glob, io, os, re, subprocess, sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(REPO)
LAW = re.compile(r'§\s*`?([a-z][A-Za-z0-9_]*[0-9]+[a-z]{0,2})`?')
SOURCES = sorted(glob.glob('src/*.cpp') + glob.glob('include/*.h') + ['uhdm_main.cpp'])
SWITCH = re.compile(r'getenv\("([A-Z][A-Z0-9_]+)"\)')
PASS_OF_DIR = re.compile(r'^(.*?)(repro)?$')


def read(p):
    with open(p, errors='replace') as f:
        return f.read()


def law_number(law):
    m = re.search(r'([0-9]+)[a-z]{0,2}$', law)
    return m.group(1) if m else None


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
    ap.add_argument('--check', action='store_true', help='exit 1 when tests/LAWS.* are stale')
    args = ap.parse_args()

    # 1. Source sites and the switches near them.
    sites = collections.defaultdict(list)      # law -> [file:line]
    switches = collections.defaultdict(set)    # law -> {ENV}
    for f in SOURCES:
        lines = read(f).splitlines()
        for i, l in enumerate(lines):
            for law in LAW.findall(l):
                sites[law].append(f'{f}:{i + 1}')
                lo, hi = max(0, i - 40), min(len(lines), i + 41)
                for k in range(lo, hi):
                    for sw in SWITCH.findall(lines[k]):
                        switches[law].add(sw)

    # 2. Pass READMEs: the title names the pass's own laws; the body mentions others.
    # A pass's own laws: those its README title names, then those its body
    # names whose number is the pass's number (a law's name ends in its pass
    # number: `...118`, `...118v`; the dir r11u118repro is pass 118).
    primary = collections.defaultdict(list)    # law -> [pass dir]
    mentioned = collections.defaultdict(list)
    title_tests = collections.defaultdict(set)
    corpus = corpus_names()
    for r in sorted(glob.glob('tools/probe/*/README.md')):
        pdir = r.split('/')[2]
        pnum = re.search(r'([0-9]+)[a-z]?repro$', pdir)
        pnum = pnum.group(1) if pnum else None
        text = read(r)
        lines = text.splitlines()
        title = lines[0] if lines else ''
        tl = set(LAW.findall(title))
        own = set(tl)
        for law in set(LAW.findall(text)) - tl:
            if pnum and law_number(law) == pnum:
                own.add(law)
        for law in own:
            primary[law].append(pdir)
        for law in tl:
            for w in re.findall(r'[A-Za-z0-9_]+', title):
                if w in corpus:
                    title_tests[law].add(w)
        for law in set(LAW.findall(text)) - own:
            mentioned[law].append(pdir)
        # Switches the README names within 15 lines of a law's mention.
        for i, l in enumerate(lines):
            for law in set(LAW.findall(l)) & own:
                for k in range(max(0, i - 15), min(len(lines), i + 16)):
                    for sw in re.findall(r'\b([A-Z][A-Z0-9]*[0-9][A-Z0-9_]*_(?:OFF|ON|DBG))\b', lines[k]):
                        switches[law].add(sw)

    # 3. Commits naming the law (current branch).
    log = subprocess.run(['git', 'log', '--format=%h%x00%s%x00%B%x01'], capture_output=True,
                         text=True, errors='replace').stdout
    commits = collections.defaultdict(list)    # law -> [(sha, subject)]
    commit_tests = collections.defaultdict(set)
    for entry in log.split('\x01'):
        if '\x00' not in entry:
            continue
        sha, subject, body = entry.strip('\n').split('\x00', 2)
        laws = set(LAW.findall(body))
        words = set(re.findall(r'[A-Za-z0-9_]+', subject))
        for law in laws:
            commits[law].append((sha, subject))
            commit_tests[law] |= {w for w in words if w in corpus}

    # 4. Arms per pass dir, in both trees; arms naming a law in their own text.
    arms_tests = collections.Counter()
    arms_tools = collections.Counter()
    arm_names_law = collections.defaultdict(list)
    for a in sorted(glob.glob('tests/probe/**/*.sv', recursive=True)):
        arms_tests[a.split('/')[2]] += 1
        for law in set(LAW.findall(read(a))):
            arm_names_law[law].append(a)
    for a in sorted(glob.glob('tools/probe/**/*.sv', recursive=True)):
        parts = a.split('/')
        if len(parts) > 2:
            arms_tools[parts[2]] += 1
        for law in set(LAW.findall(read(a))):
            arm_names_law[law].append(a)

    laws = sorted(set(sites) | set(primary) | set(commits) | set(mentioned))
    rows = []
    for law in laws:
        passes = primary.get(law) or []
        pass_dirs = passes if passes else []
        tp = sum(arms_tests[p] for p in pass_dirs)
        tl = sum(arms_tools[p] for p in pass_dirs)
        tests = sorted(title_tests.get(law, set()) | commit_tests.get(law, set()))
        rows.append({
            'law': law,
            'pass': ' '.join(passes) if passes else '',
            'readme': ' '.join(f'tools/probe/{p}/README.md' for p in passes),
            'commits': ' '.join(sha for sha, _ in commits.get(law, [])),
            'switches': ' '.join(sorted(switches.get(law, set()))),
            'source_sites': ' '.join(sites.get(law, [])),
            'arms_tests_probe': tp,
            'arms_tools_probe': tl,
            'arms_naming_law': ' '.join(arm_names_law.get(law, [])),
            'corpus_tests': ' '.join(tests),
            'mentioned_in': ' '.join(mentioned.get(law, [])),
        })

    fields = ['law', 'pass', 'readme', 'commits', 'switches', 'source_sites', 'arms_tests_probe',
              'arms_tools_probe', 'arms_naming_law', 'corpus_tests', 'mentioned_in']
    buf = io.StringIO()
    w = csv.DictWriter(buf, fieldnames=fields, lineterminator='\n')
    w.writeheader()
    for r in rows:
        w.writerow(r)
    csv_text = buf.getvalue()

    # The Markdown view: a compact table plus the pass -> laws reverse map.
    n_src = sum(1 for r in rows if r['source_sites'])
    n_commit = sum(1 for r in rows if r['commits'])
    n_pass = sum(1 for r in rows if r['pass'])
    n_arms = sum(1 for r in rows if r['arms_tests_probe'])
    md = ['# The law index', '',
          'Every law is a `§ name` (the name ends in its pass number) in the exporter source,',
          'a pass README under `tools/probe/`, or a commit message. This index maps each law',
          'back to its pass, its landing commits, its source sites and switches, its arms in',
          '`tests/probe/` (the gate) and `tools/probe/` (the evidence grids), and the corpus',
          'tests its title and commits name. Generated by `scripts/law_index.py`; regenerate',
          'it at every landing (`tests/sweep.sh` fails when it is stale). `tests/LAWS.csv` is',
          'the machine-readable form with the full source-site and arm lists.', '',
          f'Laws: {len(rows)} ({n_src} with source sites, {n_commit} with a commit on this branch,',
          f'{n_pass} with a pass README, {n_arms} with arms in tests/probe).', '',
          '| law | pass | commits | switches | arms tests/probe | arms tools/probe | corpus tests | first source site |',
          '|---|---|---|---|---|---|---|---|']
    for r in rows:
        first = r['source_sites'].split(' ')[0] if r['source_sites'] else ''
        md.append(f"| `{r['law']}` | {r['pass']} | {r['commits']} | {r['switches']} | "
                  f"{r['arms_tests_probe']} | {r['arms_tools_probe']} | {r['corpus_tests']} | {first} |")
    md += ['', '## Pass -> laws', '',
           'The laws each pass README names in its title (an arm under `tests/probe/<pass>/`',
           'or `tools/probe/<pass>/` belongs to these laws; the README says which arm is which).', '',
           '| pass | laws | arms tests/probe | arms tools/probe |', '|---|---|---|---|']
    by_pass = collections.defaultdict(list)
    for law, ps in primary.items():
        for p in ps:
            by_pass[p].append(law)
    for p in sorted(set(by_pass) | set(arms_tests) | set(arms_tools)):
        md.append(f"| {p} | {' '.join('`%s`' % l for l in sorted(by_pass.get(p, [])))} | "
                  f"{arms_tests[p]} | {arms_tools[p]} |")
    md_text = '\n'.join(md) + '\n'

    if args.check:
        stale = [p for p, t in (('tests/LAWS.csv', csv_text), ('tests/LAWS.md', md_text))
                 if not os.path.exists(p) or read(p) != t]
        if stale:
            print('law index STALE: ' + ' '.join(stale) + ' (run scripts/law_index.py)')
            return 1
        print(f'law index current: {len(rows)} laws')
        return 0
    with open('tests/LAWS.csv', 'w') as f:
        f.write(csv_text)
    with open('tests/LAWS.md', 'w') as f:
        f.write(md_text)
    print(f'wrote tests/LAWS.csv + tests/LAWS.md: {len(rows)} laws, {n_src} with source sites, '
          f'{n_commit} with commits, {n_pass} with a pass README, {n_arms} with arms in tests/probe')
    return 0


if __name__ == '__main__':
    sys.exit(main())
