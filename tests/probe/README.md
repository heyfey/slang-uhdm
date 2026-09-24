# tests/probe — the probe-arm regression set

4087 single-file SystemVerilog arms, each judged EQUAL by `uhdm-cmp`
against the golden database the pinned Surelog writes for it. They are the
equal subset of the campaign's evidence grids, moved here from
`tools/probe/` on 2026-09-23: every arm keeps its `<pass>/<grid>/<arm>`
path, so a failing arm names the pass and the law that owns the shape (that
pass's README under `tools/probe/`).

Goldens are not committed. The first check builds each one with the pinned
Surelog (about 8 minutes at three jobs) and stores it in the golden cache
the corpus sweep uses (`~/.cache/slang-uhdm-goldens`, `GOLDEN_CACHE=`
relocates), keyed by Surelog's version line and the arm's path; later
checks take about 15 seconds. A Surelog or UHDM pin bump changes the key,
so the goldens rebuild themselves on the next check.

Selection: every unique `tools/probe/**/dut.sv` that judged EQUAL in both
sweep modes on the converged binary (2838), minus 4 arms that duplicate a
uhdm2rtlil corpus test and 1 arm that embeds `__FILE__` (its golden would
carry the checkout path); then (2026-09-24) every single-file arm with
another name (`s1_scope113.sv` and the like, 4966 files in 609 pass dirs
the first census never judged): 1463 judged EQUAL, of which 1254 moved to
`tests/probe/<pass>/<file stem>/dut.sv` (204 repeated the text of an arm
already moved, 5 repeated a corpus test). The arms that judge NOT_EQUAL
(2373 + 3290) stay in `tools/probe/` only: they map the shapes the
exporter does not model yet (each pass's residues), and none of them
occurs in either corpus. `tests/ARMS.csv` names every arm's laws.

Check (part of `tests/sweep.sh`):

    python3 scripts/check_probe.py [--jobs N] [--filter REGEX]

Each arm is exported with `dut.sv --single-unit --nobuiltin` and compared
with `uhdm-cmp <golden> <out>`; an "unsupported constructs" exit with a
written database is judged like any other, as the corpus harness does.
Any arm not EQUAL fails the gate.
