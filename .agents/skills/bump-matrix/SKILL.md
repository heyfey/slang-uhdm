---
name: bump-matrix
description: "How to move a slang-uhdm dependency pin (slang, Surelog with its UHDM, uhdm2rtlil) or cut a release row: update the submodule, rebuild, let the golden cache rebuild, measure against the old baselines, converge every row the pin moved, then re-baseline and record the matrix. Use when a tool version changes or a release is prepared."
---

# Moving a pin or cutting a release

The equivalence result is a property of the exact pin set. Moving one pin
invalidates the claim until the gate is clean again on the new set. Never
re-baseline to make a moved pin green: every row the pin moved is either
converged or decided by the user and recorded.

## 1. Move the submodule

    cd third_party/<slang|Surelog|uhdm2rtlil> && git fetch && git checkout <tag or commit> && cd -
    git submodule update --init --recursive      # Surelog carries UHDM; uhdm2rtlil carries its Yosys fork
    git add third_party/<name>

Surelog and UHDM move together: UHDM is Surelog's submodule, and a `.uhdm`
file interops only with the UHDM commit that wrote it. A UHDM schema change
makes every old database unreadable; the cache handles that (below), but any
`.uhdm` kept outside the cache is garbage after the bump.

## 2. Rebuild everything that links the moved tool

    cmake --build build -j 2                                  # slang-uhdm and tools/uhdm-strictcmp (both link UHDM)
    make -C third_party/Surelog release                       # when Surelog/UHDM moved: producer, uhdm-cmp, uhdm-dump
    (cd third_party/uhdm2rtlil && make CPU_CORES=4)           # when uhdm2rtlil moved: its Yosys, its Surelog, the plugin

`slang-uhdm --version` must print the new versions.

## 3. Let the golden cache rebuild

The cache key holds Surelog's version line. After a Surelog or UHDM move the
first full sweep rebuilds every golden (hours at three jobs: both corpora in
two modes, every probe case, every sv-tests row); nothing to
do by hand, and the old entries stay valid for the old matrix (a different
`GOLDEN_CACHE=<dir>` per matrix keeps them apart). A slang-only move leaves
every golden valid: only our side changes.

## 4. Measure against the old baselines

    tests/sweep.sh --jobs 3 --workdir /tmp/bump > /tmp/bump.log 2>&1
    grep -E 'regressions=|CONVERSION|REGRESSION|CHANGE' /tmp/bump.log

The compare lines are the whole effect of the pin:

- slang moved: differences come from slang's model (a changed fold, a changed
  diagnostic making a test `SLANG_REJECT`, a changed location). Each is a
  convergence target (converge-group) or a scope decision for the user
  (rejects are out of scope by rule).
- Surelog or UHDM moved: the goldens changed. A row that regressed means
  Surelog now writes something else; decode the new behaviour from the new
  Surelog source and land it as a law, switched like every other, so the
  older matrix stays reproducible with the switch off.
- uhdm2rtlil moved: new tests appear as rows absent from the baseline (a
  regression unless EQUAL); the downstream verdicts may change with its Yosys.

Converge until `regressions=0` with every remaining row named as a user
decision. Only then re-baseline (`cp` the sweep's csvs over `results/`,
promotion rules as in claim-equal §5).

## 5. Record the matrix

One commit: the submodule pins, the baselines, `tests/LAWS.md`, and the
documents that state versions: README.md (a new row in the release matrix
table; the version column of Dependencies), tests/README.md counts,
GOLDEN_EQUIVALENCE.md §3.3 (`scripts/accounting.py --md`). Tag the release
on that commit. The row names the slang-uhdm release and the four tool
versions; commits are not listed, the version pins them.
