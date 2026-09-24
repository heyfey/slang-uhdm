#!/usr/bin/env python3
"""r11u142: what changed since map 4 r11u138map (e562f4d4 -> a7bee711, passes 133 + 134 + r11u141):
clusters gone / still present by their map-4 coverage, row-modes and probe
cases that left the fail list, first-cluster moves. Args: <repo> <out dir>."""
import csv, sys, collections
REPO, OUT = sys.argv[1:3]
M = f'{REPO}/tools/probe/r11u138map'
oci = {r['cluster_id']: r for r in csv.DictReader(open(f'{M}/cluster_index.csv'))}
nci = {r['cluster_id']: r for r in csv.DictReader(open(f'{OUT}/cluster_index.csv'))}
ofl = {(r['corpus'], r['test'], r['mode']): r for r in csv.DictReader(open(f'{M}/fail_list.csv'))}
nfl = {(r['corpus'], r['test'], r['mode']): r for r in csv.DictReader(open(f'{OUT}/fail_list.csv'))}
# both editions spell the tests/probe grid dir `arms/` as `cases/` (run.sh rewrites the artifacts)
opf = {r['case']: r for r in csv.DictReader(open(f'{M}/probe_fail_list.csv'))}
npf = {r['case']: r for r in csv.DictReader(open(f'{OUT}/probe_fail_list.csv'))}
P = print
gone = [c for c in oci if c not in nci]
cov = lambda r: r['coverage'].split(' (')[0]
P('== clusters: map4', len(oci), 'now', len(nci), 'gone', len(gone), 'new', sum(1 for c in nci if c not in oci))
P('gone by map4 coverage:', dict(collections.Counter(cov(oci[c]) for c in gone)))
P('gone with corpus rows:', sum(1 for c in gone if int(oci[c]['rows']) > 0))
for tag in ('COVERED r11u133', 'COVERED r11u134', 'COVERED r11u133+r11u134'):
    s = [c for c in oci if cov(oci[c]) == tag]
    P(f'  {tag}: {len(s)} clusters; gone {sum(1 for c in s if c not in nci)}; still present:',
      ' '.join(f"{c}({oci[c]['rows']}->{nci[c]['rows']})" for c in s if c in nci))
P('== corpus fail list: map4', len(ofl), 'now', len(nfl), 'left the list', len(set(ofl) - set(nfl)), 'entered', len(set(nfl) - set(ofl)))
for k in sorted(set(nfl) - set(ofl)): P('  ENTERED', k, nfl[k]['strict'])
left = sorted(set(ofl) - set(nfl))
P('  left (strict-equal now):', ' '.join(f'{c}/{m}/{t}' for c, t, m in left))
P('  left, by their map4 first cluster coverage:', dict(collections.Counter(ofl[k]['first_cluster_coverage'].split(' (')[0] for k in left)))
P('  left, whose map4 row cleared with the pairs:', sum(1 for k in left if 'A+B' in ofl[k]['clears_with_pairs']), 'of', len(left),
  '; map4 predicted A+B clears', sum(1 for k in ofl if 'A+B' in ofl[k]['clears_with_pairs']))
same = [k for k in nfl if k in ofl]
P('  first cluster unchanged', sum(1 for k in same if nfl[k]['first_cluster'] == ofl[k]['first_cluster']), 'of', len(same),
  '; strict cell unchanged', sum(1 for k in same if nfl[k]['strict'] == ofl[k]['strict']))
P('== probe fail list: map4', len(opf), 'now', len(npf), 'left', len(set(opf) - set(npf)), 'entered', len(set(npf) - set(opf)))
for k in sorted(set(npf) - set(opf)): P('  ENTERED', k, npf[k]['strict'])
P('  left (strict-equal now), by map4 first-cluster coverage:', dict(collections.Counter(opf[k]['first_cluster_coverage'].split(' (')[0] for k in set(opf) - set(npf))))
