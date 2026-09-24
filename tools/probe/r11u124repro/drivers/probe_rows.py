#!/usr/bin/env python3
"""probe_rows.py <probe workdir> — rows.tsv lines (probe probe rel golden ours) for a check_probe run."""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '../../../../scripts'))
import check_probe as cp  # noqa
for rel in cp.cases(None):
    print('\t'.join(['probe', 'probe', rel, os.path.join(cp.cache_dir(rel), 'golden.uhdm'), os.path.join(sys.argv[1], rel.replace('/', '__') + '.uhdm')]))
