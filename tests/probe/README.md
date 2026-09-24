# tests/probe — the probe-case regression set

4087 single-file SystemVerilog cases (a probe case: one `dut.sv` written to
exercise one law; older pass READMEs under `tools/probe/` say "arm"), each
judged EQUAL by `uhdm-cmp`
against the golden database the pinned Surelog writes for it. They are the
equal subset of the campaign's evidence grids, moved here from
`tools/probe/` on 2026-09-23: every case keeps its `<pass>/<grid>/<case>`
path, so a failing case names its pass, and `tests/LAWS.md` names its laws.

Goldens are not committed. The first check builds each one with the pinned
Surelog (about 8 minutes at three jobs) and stores it in the golden cache
the corpus sweep uses (`~/.cache/slang-uhdm-goldens`, `GOLDEN_CACHE=`
relocates), keyed by Surelog's version line and the case's path; later
checks take about 15 seconds. A Surelog or UHDM pin bump changes the key,
so the goldens rebuild themselves on the next check.

Selection: every unique `tools/probe/**/dut.sv` that judged EQUAL in both
sweep modes on the converged binary (2838), minus 4 cases that duplicate a
uhdm2rtlil corpus test and 1 case that embeds `__FILE__` (its golden would
carry the checkout path); then (2026-09-24) every single-file case with
another name (`s1_scope113.sv` and the like, 4966 files in 609 pass dirs
the first census never judged): 1463 judged EQUAL, of which 1254 moved to
`tests/probe/<pass>/<file stem>/dut.sv` (204 repeated the text of an case
already moved, 5 repeated a corpus test). The cases that judge NOT_EQUAL
(2373 + 3290) stay in `tools/probe/` only: they map the shapes the
exporter does not model yet (each pass's residues), and none of them
occurs in either corpus. `tests/CASES.csv` names every case's laws.

Check (part of `tests/sweep.sh`):

    python3 scripts/check_probe.py [--jobs N] [--filter REGEX]

Each case is exported with `dut.sv --single-unit --nobuiltin` and compared
with `uhdm-cmp <golden> <out>`; an "unsupported constructs" exit with a
written database is judged like any other, as the corpus harness does.
A case is EQUAL only when `uhdm-cmp` and `uhdm-strictcmp` both read
equal; a judge-equal case the strict comparator rejects reads
STRICT_NOTEQUAL. The gate compares the run's csv against the committed
baseline `results/golden_probe.csv`: a case leaving EQUAL is a regression
and fails the gate; a case entering EQUAL is a conversion the landing
commits by re-baselining.
