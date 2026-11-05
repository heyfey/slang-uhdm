---
name: fix-one-test
description: "How to make one not-equal slang-uhdm test or probe case EQUAL to Surelog's golden: find the first divergence, decode Surelog's structure and source, prove the rule on a golden grid, land it as a switched law with cases, gate it. Use for any CMP_NOTEQUAL, STRICT_NOTEQUAL, DIFFERENT or NOT_EQUAL row."
---

# Fixing one test

The exporter reproduces Surelog. A fix is a transcription of what Surelog
does, proven on Surelog's own output, never a guess at what it should do.
Direction discipline in every diff and log: **LHS, `-`, golden = Surelog;
RHS, `+` = ours.** Say it in your notes each time.

Job counts below are the defaults of AGENTS.md; the user's prompt overrides them.

## 1. Reproduce and read the first divergence

Single-file case:

    WORK=$SCRATCH/x scripts/converge.sh <case>/dut.sv       # prints DUMP_MATCH|DUMP_DIFF and PASS_CMP|CMP_FAIL
    head -n 20 $SCRATCH/x/cmp.log                           # the first divergence: LHS: <Surelog object>  RHS: <ours>

Corpus or sv-tests row: run the harness with `--filter` (see claim-equal §3),
then in the row directory `<workdir>/<corpus>/<mode>/<Test>-*/` read
`cmds.txt` (line 1 names the golden cache dir, line 2 the slang-uhdm command)
and rerun the command yourself.

STRICT_NOTEQUAL (uhdm-cmp equal, strict different):

    build/uhdm-strictcmp <golden>.uhdm <ours>.uhdm | head -n 30   # first differing field, lhsPath:/rhsPath: parent chains, per-field tally

Reading `cmp.log` (UHDM's SafeCompare): `RHS: <null>` on a singular field
means ours lacks an object Surelog has at that slot; a vector size mismatch
prints both **containers**, not the element; a `hier_path` on the left with a
full object on the right is a path-element count mismatch. Read the owner
kind's generated `Compare` (`third_party/Surelog/third_party/UHDM/build/generated/src/<kind>.cpp`)
before naming the field. Compare reads VpiType, VpiName, VpiDefName and
per-kind fields, never VpiFullName, VpiFile, line or column; VpiDecompile is
read; no Compare reads VpiParent, so sharing versus copying is invisible to
uhdm-cmp and visible only to the strict comparator.

## 2. Decode Surelog's structure from its dump

    grep -n -A6 '<kind>: (<name>)' $SCRATCH/x/surelog.dump      # every occurrence with context
    awk '/\|uhdmtopModules:/{v="ELAB"} /weaklyReferenced/{v="TAIL"} {print v, $0}' $SCRATCH/x/surelog.dump | less

Both views matter: `allModules` is the definition view, `topModules` the
elaborated view, and the `weaklyReferenced` tail is unreachable to the judge
(never count it). Count what the dump hides: object multiplicity, parent
chains, `vpiInstance` occurrences. The dump synthesizes `vpiFullName` from the
parent chain, so a naming difference is often a parenting difference: check
`vpiParent` first.

## 3. Decode the rule from Surelog's source

Find the Surelog code that writes the object (`third_party/Surelog/src/`,
the UHDM writer and the elaboration listeners), and cite `file:line`. The
rule you land must name that site. If the brief or an earlier note names a
mechanism, treat it as a question: briefs have been wrong about "missing
object" versus "null vector" and "listing" versus "link".

## 4. Prove the rule on a golden grid before coding

Write cases under `tools/probe/r11u<N>repro/cases/<grid>/<case>/dut.sv`, one
axis per case: declaration order, names, scopes (package, module, generate,
function), typedef versus anonymous, parameter versus signal use, single
versus multiple instances, def view versus elab view. Run every case through
`scripts/converge.sh` on the **pristine** binary and record the verdict per
cell. Calibrate: a census or scorer that compares golden to golden must read
0 differences before its reading of ours means anything. The grid names the
predicate; a case that agrees with golden by a different mechanism is not a
case that tests the law.

## 5. Implement the smallest switched change

At the emitter site:

    // § <lawName><N> — <what Surelog does, Surelog file:line, what the grid measured, what abstains>
    if (<predicate> && lawOn(<N>, "R11U<N>_<LAW>_OFF")) {
        lawTrace(<N>, "§ <lawName><N>", <detail>);     // optional, one line per firing or abstention
        ...
    }

`lawOn`, `fixOn`, `lawFixOn` and `lawTrace` come from `src/law/LawSwitch.h`
(included by every emitter file); per-pass state goes in its own section of
`src/law/LawState.h`, never in a new header. The law name ends in the pass
number; the switch is `R11U<N>_<LAW>_OFF`; `R11U<N>_OFF` drops the whole pass.
With no variable set the output must be the same as if the switch did not
exist. Never change a default silently: anything that changes the database
on sources outside the grid is a mover you must predict.

## 6. Predict, build, gate

1. **Predict movers by name** from the pristine databases before building:
   which corpus rows, probe cases and sv-tests rows contain the shape.
2. Build (`cmake --build build -j 2`, `Built target`), freeze a copy.
3. Re-run the grid on the new binary: every case moves toward golden, none
   away; residues (cases still wrong on both binaries) are listed, not hidden.
4. Run the full gate (claim-equal §4). Every mover must be one you predicted;
   an unpredicted mover means the predicate is wider than the law.
5. Boundary: the probe stage of the sweep runs all 31943 cases; only your
   pass's cases may move, and any earlier case that moves must move toward
   golden (re-judge it against its golden by hand).

## 7. Land (the land-change skill has the master's exact steps)

- Cases that judge EQUAL or STRICT_NOTEQUAL on the new binary move to
  `tests/probe/r11u<N>repro/cases/<grid>/<case>/dut.sv` (`git mv`, source
  files only) with a `LAW` file naming the law, one name per line. A test
  exists in one place: a comment names the `tests/probe/` path for a moved
  case and the `tools/probe/` path for a grid whose README and residues stay.
- `tools/probe/r11u<N>repro/README.md`: verdict, the laws (name, switch,
  Surelog file:line, the rule, what abstains), the grid table, the predicted
  and observed movers, the residues with their first differing object, the
  sweep summary. The README is where the next agent learns why the law exists.
- `python3 scripts/law_index.py && python3 scripts/law_index.py --check`.
- Promote converted rows (claim-equal §5) and commit everything in one commit
  whose message names `§ <lawName><N>`.

## Emitter facts that break naive fixes

- `currentScope` is stale throughout `emitInstance`: a name bind during
  elaborated emission reads garbage. Resolve from the instance body instead.
- Never call `getDefaultSpecialization` in a probe or census: it mints objects.
- Do not force AST binding during the definition phase: it changes later emission.
- Surelog's naming is context-dependent (`pkg::pkg::` in one context, not in
  another). Do not "fix" names uniformly; the goldens of earlier passes break.
- `any_cast` in UHDM is IS-A: dispatch on `UhdmType()`.
- A law that helps test Y and regresses test X has found the missing
  distinguisher: X and Y differ in exactly the property the predicate lacks.
  `diff` the two sources, add the condition, re-gate. Revert-and-refine, never
  revert-and-abandon.
- Difficulty is layers, not dump lines: a 100-line dump diff has decomposed
  into three rules more than once. Fix the first divergence, re-run, repeat.
