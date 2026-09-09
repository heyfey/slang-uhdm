# r11v1 — adversarial verification of § `ifacePortViewParamAssignsOnly` (r11u1)

Independent worktrees, independent builds, independent instruments. Everything
here is MEASUREMENT-ONLY; the judge is `uhdm-cmp` through
`scripts/verify_golden.py`. The production surface of the pass is unchanged by
this directory — `src/ModuleEmit.cpp` is byte-identical to what r11u1 shipped,
so the patched binary md5 is the same one every gate below was measured on.

## 1. What was reproduced, from scratch

| gate | measured here |
|---|---|
| pristine binary | md5 `2ac8447d58a0fb9e4d9ef6da9292b053`, byte-identical to the main tree at the base commit |
| patched binary | md5 `3f6d690887219fc3b2aa46da8c4f30f6` |
| build | rc 0, 0 errors, 20 warnings on BOTH binaries — the same 20 narrowing warnings at the same lines |
| goldens | patched 23 PASS / 0 FAIL; pristine 23/0; `SLANG_UHDM=/bin/false` 0 PASS / 23 FAIL |
| u2r pristine | 719 / 85 / 67 both modes — `ct8rows` PASS, every row byte-identical to the committed CSVs |
| u2r patched | **733 / 71 / 67** both modes; 28 rows moved, all `CMP_NOTEQUAL -> CMP_EQUAL` |
| surelog pristine | default 455/28, testflags 451/26 — only the two `SURELOG_FAIL` detail cells that embed the workdir path differ |
| surelog patched | **default 459/24, testflags 455/22**; 8 rows moved, all `CMP_NOTEQUAL -> CMP_EQUAL` |
| dump column | `match` unchanged in all four arms (523 / 527 / 225 / 166) — no `match -> differ` demotion |
| cmds.txt audit | u2r 1742/1742 name the frozen binary; surelog 1531/1531 that ran slang, plus 50 golden-side failures with no slang line, identical on both sides |
| canaries | u2r `ok=8 changed=0` + ctcan2 PASS; surelog `ok=52 changed=0` + ctcan2 `ok=58` PASS; `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| hard byte pins | SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, both modes, exact |
| status pins | InterfaceModPort / BlackParrotComplex / YosysOldOr **byte-identical**, both modes — the interface canary did not move at all |

## 2. Movers, and the proof that none moved WRONG

`byteverify.sh SELFCHECK=1`: u2r **36 / 1608**, surelog **21 / 960**.
`predict.py` run against the verifier's OWN pristine databases names 36 and 17.
The four unpredicted surelog movers are MiniAmiq and SeqDriver in both modes.

**Every single mover — all 27 tests, both corpora — was already
`CMP_NOTEQUAL` at the baseline. Not one `CMP_EQUAL` database moved a byte.**

The coin is proved, not asserted. Three consecutive runs of the PRISTINE
binary on MiniAmiq and SeqDriver give three different md5s each, and one of
them (`SeqDriver/default`, `68cc3d64d0ec`) is EXACTLY the hash `byteverify`
attributed to the patched binary — the "patched" database is reachable from
the pristine binary. Their order-blind sorted-dump delta is 4 lines: one
`UINT:` constant and its `vpiDecompile`, the `__LINE__`-class constant in a UVM
macro expansion. The law touches no such object.

`rowheads.sh` on both workdirs: ONE head per row everywhere, and only
`Rggen/default` changes — 531 -> 801 cmp lines.

## 3. `agree.sh` — the scorer that convicts, and why the obvious one lies

Rggen's cmp output GREW. A directional read of that number would call the pass
a regression. It is not: a vector SIZE mismatch prints the whole golden vector,
so fixing one field of an object and leaving another wrong prints MORE lines
than getting both wrong.

`agree.sh <pristine-wd> <patched-wd> <name>...` scores the only thing that
matters — per test, the interface_inst census rows that agreed with golden
BEFORE and do not agree AFTER.

    Rggen/default   agree_pris 1170 -> agree_pat 1837   LOST 0

Measured over all 27 mover tests plus `InterfaceModPort` as a control:

    u2r     18 tests   TOTAL-LOST = 0
    surelog  9 tests   TOTAL-LOST = 0   (InterfaceModPort 6 -> 6, untouched)

Positive control: swap the two workdir arguments and every gain reads back as
a loss, naming the exact rows (`agree.sh <patched> <pristine> InterfType
InterfaceElab OneNetRange` -> TOTAL-LOST=6, FAIL).

**Do not score this law with a raw sorted-dump multiset diff.** An object
golden has that we never emit donates lines that our DELETED port-view
parameter objects used to match by accident, so deleting a wrong object reads
as a loss. Arm `vM` (a 2-D interface array we do not emit) scores LOST=35 that
way; the same arm with the array removed scores LOST=0, and the per-object
subtree diff shows every port view strictly closer to golden. That is the
multiset trap, and it is the reason `agree.sh` joins on census ROWS keyed by
instance name instead of on dump lines.

## 4. Adversarial arms (real Surelog v1.87, `[ERROR] : 0` on every arm)

`run.sh <armdir> <binary> <tag>` builds the golden and our database for one arm
and records the Surelog rc, the slang rc, the cmp rc and the head count.
`cen.py <dump>` is the verifier's own census (written independently of
`r11u1repro/ifcen.py`); `sub.py <golden> <ours> <name>` diffs one
interface_inst subtree; `mover.py` is the multiset scorer kept only to
demonstrate the trap in §3.

| arm | what it attacks | result |
|---|---|---|
| `vA` | single parameterization + a REAL override + all four port forms — the shape where the restamp actually writes a value | no home/def view disturbed; W restamped correctly to the default on all three default-folding views; derived localparam `BYT` still the instance value (R1) |
| `vC` | negative `int`, `logic [7:0]`, `real`, `int unsigned` parameters | the restamp fires only for `UINT:`/`INT:`-valued parameter objects; see the residues |
| `vD` | non-parameter faces — a var, a wire, a cont_assign, a packed-struct var, a function, a task, two modports (one with `import`), an interface input port, a wildcard package import | every non-parameter face unchanged pristine -> patched; the only census delta is the param_assign vector the law adds |
| `vE` | a PROGRAM with an interface port, plus a module control | home and def views exact; golden emits NO interface_inst for a program's interface port and we emit one — pre-existing on both binaries |
| `vF` | nested interface port, generic `interface` port, interface-ARRAY port | port views gain their param_assigns; array-port elements still empty (R2/R3) |
| `vJ` | two-level RE-PASS: `mid(bif.mp q)` and `mid(bif q)` each instantiating an inner `.s(q)` and `.s(q.mp)` | see residue R0 |
| `vK` | array elements addressed by literal index and by genvar, inside and outside a generate block | patched exact except the derived localparam |
| `vL` | the actual lives inside a generate block — the shape the deleted `actualOutOfScope16` predicate named | see residue R0 |
| `vM` | `parameter type`, a 2-D interface array, a type override | the multiset trap of §3 |

`vB` (a hierarchical name in a constant expression) is NOT an arm: slang
rejects it as illegal SV, correctly, on both binaries.

The pass's own `grid1/grid2/grid3` were regenerated here from the committed
sources against this machine's Surelog v1.87: the published par/pa/W/vpiOverriden
table reproduces cell for cell, and **grid2's golden-vs-patched census diff is
empty**, as claimed.

## 5. One deliverable defect, fixed here

`tools/probe/r11u1repro/cen.sh` invoked `python3 /tmp/r11u1_grid/ifcen.py` — the
implementer's own scratch directory, not the committed copy beside it. It works
only until `/tmp` is pruned, which the ops rules mandate at every landing, and
then it prints an EMPTY diff for every test: a silently green census. Fixed to
resolve `ifcen.py` next to the script. Positive control after the fix: it
prints clean for the converted tests and still names
`interface_array_fanout`'s two missing `work@dut.f.m[i]` rows.

No production line was changed by the verifier.
