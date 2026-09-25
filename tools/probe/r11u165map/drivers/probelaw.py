#!/usr/bin/env python3
"""case (tests/probe-relative) -> laws, from scripts/law_index.build(). Run from the repo root."""
import sys, os
sys.path.insert(0, 'scripts')
import law_index as li
ix = li.build()
for path, pdir, tree, laws, how in ix['cases']:
    if tree != 'tests': continue
    rel = os.path.relpath(path, 'tests/probe')
    print(rel + '\t' + (' '.join(sorted(laws)) or '-'))
