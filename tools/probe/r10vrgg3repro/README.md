# r10vrgg3 — ADVERSARIAL VERIFICATION of r10rgg3
### § portViewRangeRecvParams + § ifaceArrayElemViewFoldsDefault

**MEASUREMENT-ONLY.**  The official `uhdm-cmp`
(`~/git-repos/UHDM/build/bin/uhdm-cmp`, md5 `2ad8015175758e918de1789b86ef1ea5`)
is the sole acceptance judge here, exactly as in the campaign's gates.  LHS is
ALWAYS golden (real Surelog); RHS is ALWAYS ours.

## What this directory is

r10rgg3 shipped a 37-cell grid of its own (`tools/probe/r10rgg3repro/`).  This
directory is a **second, independent grid** whose cells are deliberately the
shapes that one does NOT contain, built to make the law FAIL:

| series | what it attacks |
|---|---|
| `v*` | HOSTILE substituted values — the design is legal SV but the receiving module's same-named parameter makes the *substituted* interface body degenerate: `AW = 0`, `-3`, `100000`, `2147483647`, a division by zero, a reversed range, a generate condition that flips, a genvar-loop bound of 3000, an unpacked dimension of 65536, `$clog2`-derived |
| `w*` | MEMBER KINDS under the substitution — `logic`/`wire`/`reg`/`bit`/`byte`/typedef/packed-struct/unpacked array/2-D packed/signed, enum-with-substituted-base, `real`, `string`, `event`, a function whose return and argument use the parameter, a continuous assign whose RHS *is* the parameter |
| `x*` | CONNECTION and OVERRIDE forms — partial-named `#(.AW(8), .VW(64))`, all-named, plain positional, 2-D interface array, interface instantiated inside a generate, receiver inside a generate, two receivers with different parameters on ONE array, one receiver instantiated twice with different overrides, a port passed down a level, an interface instantiated INSIDE an interface, a module array as the CONTRAST, receiver whose only same-named symbol is a localparam, receiver params typed `string`/`real`/4-state-X, an interface `type` parameter, an interface localparam name clash, an untyped interface parameter, a 4-deep transitive chain, a modport EXPRESSION |
| `y*` | element-INDEX connection `.p(arr[1])`, a MODPORT-ACCESSED port view (read in an `always_comb`), a receiver that shares only `BW` |
| `z*` | THE BYPASS BOUNDARY — the four exceptions `arrElemPortView9` newly overrides (multi-parameterised def, text-multi def, aggregate-override view, generate-bearing interface) exercised **with NO receiving parameter at all**, which r10rgg3's grid covers for `multiParamIface` only; plus a single interface inside a genfor with a named modport connection (the HOME-LIKE control), and a receiver MODULE ARRAY |

`boundary2.sh` is `r10rgg3repro/boundary.sh` **with a hole closed** — see §2 of
`GRID.txt`.

## Files

| file | what it is |
|---|---|
| `gen.py` | writes all 49 cells (`<cell>/dut.sv`); round-trip-checked against the measured tree |
| `run.sh` | `BASE=<bin> PAT=<bin> ./run.sh <cell>...` — golden + both binaries, verdict = the OFFICIAL `uhdm-cmp` status PAIR, so a pristine-right -> patched-wrong cannot be missed |
| `score2.sh` | golden RANGE-line agreement per binary, read only as a DIRECTION (`DELTA`, `BETTER`/`WORSE`); it reuses `r10rgg3repro/ranges.py` with a PERMISSIVE member pattern |
| `boundary2.sh` | the boundary gate with the ASYMMETRIC-DATABASE hole closed |
| `GRID.txt` | the verdict, the reproduced numbers, the measured table and the ranked residues |
| `GRID.raw` | `run.sh` + `score2.sh` + `score.sh` + both `boundary2.sh` runs, verbatim |
| `crashclass.sh` | `BASE=<bin> [FIX=<bin>] ./crashclass.sh` — the 15-shape no-top matrix that characterises the PRE-EXISTING segfault class (§5 of GRID.txt) and gates the § defPortsNullDefInstGuard fix; 8 of 15 shapes crash at 05d9c8f, all 8 fixed, and golden emits a database for every one |

## Guards these drivers carry

* `run.sh` distinguishes `CRASH_rc139` from `NO_DB_rc3` — a crash must never
  read as a plain rejection;
* a cell whose GOLDEN side produced no database prints `NO-GOLDEN` and is never
  scored;
* `score2.sh` prints the golden line COUNT beside every score, and a `-1`
  (no database) can never read as agreement;
* `boundary2.sh` counts the two sides' databases SEPARATELY and is FATAL on any
  asymmetry;
* the range score has a known systematic floor (golden and ours disagree on a
  handful of `int_typespec` PARENT names in every cell, base included), so it is
  used for DIRECTION only and never quoted as an absolute.

## The two patches this verification produced

| patch | surface | gates |
|---|---|---|
| `/tmp/r10rgg3.verified.patch` | r10rgg3's production change **unchanged** (its production diff is byte-identical to `/tmp/r10rgg3.patch`'s) + `tools/probe/r10rgg3repro/` + `tools/probe/r10vrgg3repro/` | all five green, every headline number reproduced |
| `/tmp/r10vrgg3_crashguard.patch` | ONE hunk, `src/ModuleEmit.cpp` § defPortsNullDefInstGuard | byte-neutral on all 1358 u2r and all 953 shared surelog databases, but it moves **2 of the 1588 surelog rows** (`MiniAmiq` SLANG_REJECT -> CMP_NOTEQUAL in both modes) because that test used to SEGFAULT.  Shipped separately for the master to promote with the rows quoted |

Applying both, in that order, on a fresh 05d9c8f reproduces
`src/ModuleEmit.cpp` md5 `6a518e1436db7f2cf179e0d52e144abb`, the exact file that
built the FIX binary md5 `2c1c08fe5194d829ddc36716b3746d78`.
