#!/usr/bin/env python3
"""Prints, per uhdm2rtlil test matching the regex, the Surelog-lane golden
(uhdm2rtlil's own Surelog, downstream flags; golden cache) and the translated
slang command line:  sdb119.py <regex>"""
import sys, os
import os
REPO = os.environ.get('REPO') or os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, os.path.join(REPO, 'scripts'))
import downstream_uhdm2rtlil as ds, verify_golden as vg
tests = vg.discover_uhdm2rtlil('^(' + sys.argv[1] + ')$')
for n, (d, p) in tests.items():
    rest = [x for x in p if x not in ('-parse', '-nobuiltin', '-nocache')]
    sl_args = ['-parse', '-nobuiltin', '-nocache'] + ds.DOWNSTREAM_FLAGS + rest
    su_args, *_ = vg.translate(sl_args)
    print(n, ds.surelog_db(d, sl_args, os.path.join(os.environ.get('SCRATCH', '/tmp/r11u119_cenw'), n), 300), d, ' '.join(su_args))
