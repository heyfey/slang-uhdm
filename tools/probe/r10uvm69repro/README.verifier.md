# r10uvm69 — ADVERSARIAL VERIFICATION of § retNameRecvCollapse69

**VERDICT: PASS.** Every number in the implementer's report reproduces exactly
on binaries I built myself from a fresh 6e1c27a. The head is cleared on all
three target rows, the five gates are green, both refutations hold, and the law
survives seven axes the implementer's own grid never measured. Four findings
below are documentation/driver-hygiene defects; **none changes a measurement or
the verdict**, and none blocks landing.

This file is **THIS pass's** verifier record (landing-hygiene requirement). The
delivered patch carried **no** `README.verifier.md` at all — there was no stale
one to displace.

* Verifier worktrees: `/tmp/wt_v69` (patched), `/tmp/wt_v69pris` (pristine
  6e1c27a), `/tmp/wt_v69cmp` (landing-composability probe). All created by me
  with `git worktree add --detach 6e1c27a`.
* `git stash` never used. `results/*.csv` **read only**. `GOLDEN_DEFER` unset.
  All sweeps `--jobs 2` with my own `--out`/`--workdir`. No fenced test
  (`UnsignedParam`, `HierPathEval`, `FileLocalParam`, `TopParam`) dispatched.
* LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

---

## 1. INDEPENDENT REPRODUCTION — the binaries are bit-identical to the claim

I applied `/tmp/r10uvm69.patch` (md5 `104ea95896023d91e26a911f180f61e5`,
2262 lines) to a fresh detached 6e1c27a and configured/built both trees myself.

```
git apply --check /tmp/r10uvm69.patch      -> clean
cmake --build build -j 8                   -> [100%] Linking CXX executable slang-uhdm
                                              [100%] Built target slang_uhdm   (BOTH trees)
md5sum (asserted in a SEPARATE command, after the link line):
  f1fee994fffdfc1e2d7883d791e1621f  /tmp/wt_v69pris/build/slang-uhdm      <- CONTROL
  3088f565cd6b93c67c8f85441a3e79fc  /tmp/wt_v69/build/slang-uhdm          <- FINAL
  f1fee994fffdfc1e2d7883d791e1621f  /home/heyfey/git-repos/slang-uhdm/build/slang-uhdm
```

Both md5s equal the implementer's **to the digit**, and my pristine twin is
byte-identical to the main-tree binary — the control anchor holds independently.
Both are 32-hex. Every binary BASE below was printed and grep-checked.

**The implementer's OPS NOTE (stray main-tree writes) checks out.** Main tree at
6e1c27a carries only r10earl40's live `§ pkgScopedMultiSelVarSelect40` edits
(`include/UhdmExporter.h` + `src/TypeEmit.cpp` — I read the whole diff; it
contains no `retNameRecvCollapse69` text), `results/` is unmodified, no
`tools/probe/r10uvm69repro/` exists there, and `build/slang-uhdm` is still
pristine `f1fee994…`. The revert was complete.

---

## 2. THE FIVE GATES, re-run by me

| gate | claimed | **measured by me** | |
|---|---|---|---|
| 1 BUILD | `f1fee994…` → `3088f565…` | identical | ✅ |
| 2 GOLDENS | 23/0; `/bin/false` 0/23 | **23 PASS / 0 FAIL**; `/bin/false` **0 PASS / 23 FAIL** | ✅ |
| 3 u2r testflags j2 | 679/50/2, dump 496/183/52, 0 rows | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL**; dump **496 match / 183 differ / 52 blank**; ct8rows **0 differing ROWS (0 sides)**, both histograms unchanged | ✅ |
| 4 surelog both j2 | 469/11 + 465/8, FAIL 25/23, DEFER 5/5, 0 rows | **default 469/11, testflags 465/8**, SURELOG_FAIL **25/23**, DEFERRED **5/5**, dump match **225/165**; ct8rows **0 differing ROWS** | ✅ |
| 5 BYTE VERIFIER | u2r 0/679, surelog 7/953 | **u2r MOVERS 0/679**, **surelog MOVERS 7/953**; SELFCHECK **678/679** and **952/953**; SELFCHECK1 **1** and **8**; PATH_SETS_IDENTICAL both | ✅ |

Gate 5's 7 movers are **exactly** the 7 predicted UVM databases and nothing
else (Scoreboard/testflags is `SLANG_REJECT`, no database).

### 2.1 Movers are REAL by size-delta, and Scoreboard is MULTI-STABLE

`detcheck.sh`, 3 reps, **both** binaries, run from the Scoreboard source dir:

| binary | distinct hashes / 3 | bytes (all three runs) |
|---|---|---|
| PRISTINE `f1fee994…` | **3** | **11122738** |
| FINAL `3088f565…` | **3** | **11122938** |

Size **stable within** each binary, **differs between** them: the mover is real
and the 3-distinct-hash nondeterminism is pre-existing and untouched
(MEMORY.md's emitter-nondeterminism note). Under the standing law
*same-size = flake, size-delta = real*, **no mover has delta 0**:

| mover | patched | pristine | delta |
|---|---|---|---|
| default/SimpleUVM | 11118646 | 11118095 | +551 |
| default/Scoreboard | 11122938 | 11122738 | +200 |
| default/SeqDriver | 17962372 | 17960936 | +1436 |
| default/BuildUVMPkg | 11097319 | 11097017 | +302 |
| testflags/SimpleUVM | 11118958 | 11118485 | +473 |
| testflags/SeqDriver | 17962804 | 17961341 | +1463 |
| testflags/BuildUVMPkg | 11097319 | 11097017 | +302 |

All seven equal the implementer's table exactly. A first `detcheck.sh` run of
mine from the wrong cwd printed `NO_OUTPUT ×3` and **failed** rather than
reading as "all identical" — the driver's guard demonstrably works.

### 2.2 Movers per-shape vs GOLDEN by MULTISET, ADDED/REMOVED separately

LHS always golden. All fourteen numbers reproduce **exactly**:

| mover | msdist pristine | msdist patched | gain | ADDED | REMOVED |
|---|---|---|---|---|---|
| default/SimpleUVM | 143682 | 143558 | **124** | 107 | 77 |
| default/Scoreboard | 134032 | 133908 | **124** | 107 | 77 |
| default/SeqDriver | 365900 | 365670 | **230** | 199 | 125 |
| default/BuildUVMPkg | 80324 | 80150 | **174** | 119 | 113 |
| testflags/SimpleUVM | 143678 | 143554 | **124** | 107 | 77 |
| testflags/SeqDriver | 365900 | 365670 | **230** | 199 | 125 |
| testflags/BuildUVMPkg | 80324 | 80150 | **174** | 119 | 113 |

Every mover moves **toward** golden; none regresses. `mv1.sh`'s
"ADD-ONLY FALSIFIED" on SimpleUVM is correct and expected — the law is
deliberately bi-directional. I read the three-way count on SimpleUVM: every
added line text is the law's own population (`open_recorder`, `open_stream`,
`create_item`, `hier_path uvm_instance_scope.len/.substr`,
`method_func_call itoa`, `vpiName:len/substr/itoa/index_string/pos`) with
`pristine=0 → patched=golden` on the structural lines. **No unattributed name.**

### 2.3 Canaries

| check | measured |
|---|---|
| brief-named `r10uvm52repro/canaries.sh`, surelog | `ok=52 changed=0 absent=0` |
| brief-named `r10uvm52repro/canaries.sh`, u2r | `ok=8 changed=0 absent=0` |
| `ctcan2.sh` surelog, **EXPECT_UNKNOWN=1**, baseline FIRST | `ok=58 changed=0 absent=0 unknown-patterns=1` **PASS** |
| `ctcan2.sh` u2r, **EXPECT_UNKNOWN=6**, baseline FIRST | `ok=1 changed=0 absent=0 unknown-patterns=6` **PASS** |
| `canaudit.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0` **PASS** |

`InterfaceModPort` and `BlackParrotComplex` quoted BY NAME are
`CMP_EQUAL,,,differ` in both modes in baseline and fresh, **and** neither is
among the 7 movers — so their databases are byte-identical and the `differ`-column
blindness is closed.

---

## 3. THE HEAD — cleared, and the cleared cells match golden byte-for-byte

`rowheads.sh` on both workdirs:

| row | CONTROL | FINAL |
|---|---|---|
| SimpleUVM / default | **112** cmp lines, 1 head | **54**, 1 head |
| SimpleUVM / testflags | **112** | **54** |
| Scoreboard / default | **112** | **54** |
| BuildUVMPkg / both | 58 | 58 |
| SeqDriver / both | 1414861 | 1414877 |

**Head identity, read not summarised.** The CONTROL head is exactly the brief's
target — `func_call: (open_recorder), line:343:13, endln:343:61` with the three
`vpiArgument` children. The FINAL head is
`int_var: (uvm_pkg::uvm_tr_stream::get_recorders), line:371:13` with
`ref_typespec → logic_typespec` — **a different family** (residue R2), so the
call-shape head is genuinely gone rather than reordered.

The census confirms it per-cell (`callcen` + `calljoin`, argument-span key):

```
SimpleUVM/default   agree 10948 -> 10957   SHAPE 7 -> 0   NAME 58 -> 58
                    GONLY 1946 -> 1944     OONLY 1961 -> 1959
```

The three repaired cells are **byte-identical to golden** in the final database:

```
343 func_call open_recorder 343:13-343:61 args=3 tgt=uvm_pkg::uvm_tr_stream::open_recorder
157 func_call open_stream   157:13-157:58 args=3 tgt=uvm_pkg::uvm_tr_database::open_stream
946 func_call create_item   946:5-946:52  args=2 tgt=uvm_pkg::uvm_sequence_base::create_item
```

**SeqDriver's head identity is unchanged** — `LHS: <null> / RHS: package uvm_pkg
(uvm_pkg::)` in both control and final; only the object id moves (6032 → 6040).
The +16 cmp lines are head DEPTH, and the distance instrument says SeqDriver
moved **230 closer**. The collision report to r10sd2 is accurate.

---

## 4. THE REFUTATIONS HOLD — I re-measured both

**Refutation 1 & 3 (the brief's law, and a position-only law, are both false).**
The 7 SHAPE cells in the control, measured by me:

| line | golden | ours (control) | direction |
|---|---|---|---|
| 157 | `func_call open_stream` | `method_func_call m_do_open` | UNDER-collapse |
| 343 | `func_call open_recorder` | `method_func_call m_do_open` | UNDER-collapse ← HEAD |
| 946 | `func_call create_item` | `method_func_call set_item_context` | UNDER-collapse |
| 357 ×2 | `method_func_call substr` | `func_call uvm_instance_scope` | **OVER-collapse** |
| 992 ×2 | `method_func_call itoa` | `func_call index_string` | **OVER-collapse** |

Cell **992 is statement position and golden KEEPS the method shape** — the
out-of-body gate is required and a position-only law is dead. Confirmed.

**Refutation 2 (the `string`-type law is false).** Arm `a2_scope`'s two
decisive cells, from my own golden:

```
G2  g_s_in  (string, IN-BODY, stmt)      -> golden func_call g_s_in 38:7-38:21   COLLAPSE
H1  h_h_out (class handle, OUT-OF-BODY)  -> golden method_func_call touch,
                                            prefix=h_h_out@71:5                  KEEP
```

Opposite predictions, one database, both as the implementer reported. The type
axis (`a1_type`) shows all six return types collapsing in statement position and
keeping in expression position. **Type: refuted. Out-of-body: confirmed.**

**Refutation 4** is verified structurally: the pre-existing built-in arm at
`ExprEmit.cpp:11671` had no position and no out-of-body gate, and it is the arm
that produced the three OVER-collapses above.

---

## 5. GRID REPRODUCED CELL-FOR-CELL

`gridcells.sh` (its golden-cannot-move guard passed on all arms):

| arm | claimed | **measured** |
|---|---|---|
| `a1_type` | 14 → 0 | **differing(control)=14 → differing(final)=0** |
| `a2_scope` | 12 → 0 | **12 → 0** |
| `a3_recv` | 5 → 2 | **5 → 2**, and both remaining lines are the single N6 chain cell (residue R1) |

**EMPTY PRODUCT CELL HUNT: none found.** I enumerated every cell label declared
in the arm sources against the golden census. All 15 declared `a1` cells
(A1–A4, B1–B3, C1–C2, D1–D2, E1–E2, F1–F2) and all 12 declared `a2` cells
(G1–G5, H1–H4, J1–J2, K1–K2) produce a real call object in golden; `a3`'s
N1–N7/P1/Q1 likewise. No cell in any table is empty or synthesised.

---

## 6. MY OWN OVER-FIRE HUNT — a NEW arm on SEVEN unmeasured axes

The predicate's gate is
`stmtCtx && !curSubOob9 && recv==funcRetSym && retvar's parent scope is a Subroutine`.
**Nothing in it distinguishes static from automatic, virtual from plain,
interface-homed from package-homed, or a top-level call from one nested inside
`if`/`for`** — and the implementer's three arms exercise none of those. If
golden keys on any of them, the pass over-fires and its grid could not have
seen it. So I built `v1_gaps.sv` and measured:

| cell | axis | GOLDEN | OURS CONTROL | OURS FINAL |
|---|---|---|---|---|
| V1 | **VIRTUAL** method, in-body, stmt | COLLAPSE `func_call v_virt` | KEEP | **agree** |
| V2 | **STATIC** method, in-body, stmt | COLLAPSE `func_call v_stat` | KEEP | **agree** |
| V3 | nested **`if`/`for` block**, stmt | COLLAPSE `func_call v_nested 53:11-53:32` | KEEP | **agree** |
| V4 | nested block, **EXPRESSION** (neg. control) | KEEP `method_func_call peek_stub` | KEEP | **agree** |
| V5 | **DEFAULTED formal** in the collapsed call | COLLAPSE `func_call v_default`, **args=1** | KEEP | **agree, args=1** |
| V6 | package free fn, stmt | COLLAPSE | KEEP | **agree** |
| V7 | **INTERFACE-homed** function, stmt | COLLAPSE `func_call i_fn 93:5-93:18` | KEEP | **agree** |

**`differing(control)=12 → differing(final)=0`. Zero over-fires and zero
under-fires on seven axes the pass never measured.** The law generalises.

Two implementation choices the pass's own arms could not justify are
**vindicated** here:

* **`writtenArgs16(call)` and not `call.arguments()`** — V5's collapsed
  `func_call` carries **args=1** in golden and in ours; the defaulted `y=7` is
  absent from both. `call.arguments()` would have emitted two.
* **`callRng11` and not `expr.sourceRange`** (§ callParenSpan11) — a purpose-built
  no-argument cell `n_noarg.bump();` gives golden
  `func_call n_noarg 10:7-10:21`, running **through the closing paren**, and
  ours matches exactly. `expr.sourceRange` stops at the callee name and would
  have been short.

---

## 7. BOUNDARIES — verified by execution, not by reading

I ran **every** arm of the fenced neighbouring passes through both binaries and
diffed our own dumps:

```
r10svs2repro : s1_dynsize s2_querykind s3_arraykind s4_context s5_negctl
               s6_otherbuiltin s7_recvless w1_stmtfunc w2_spacedot
               w3_macrodeep w4_classbuiltin          -> ALL 11 SAME
r10uvm56repro: a1_witness a2_local a3_scope a4_kinds a5_argpos a6_type
               a7_recur a8_newlhs v1_scopes2 v2_call v3_hierpath
               v4_methodkinds                        -> ALL 12 SAME
```

**All 23 arms byte-identical between pristine and patched.** This is stronger
than the implementer's claim, which was reasoned from arm cell P1 rather than
executed: § parensLessCallIsPathRefObj / § parensLessFuncRefIsRefObj (r10svs2)
and § classMethodRetNameNoBind56 / § retNameNewLhsNoBind56 are provably
untouched. The P1 repair is confined to a *return-name* parens-less receiver,
which r10svs2's arms do not cover — a repair, not a breach, as claimed.

**§ invalidNewCallFromSyntax55** — `new` call cells are **identical** in control
and final across every arm (`a1` 8/8/8, `a2` 10/10/10, `a3` 11/11/11 for
golden/control/final, `ctrl_vs_final_diff=0`). Claim verified — see finding F4
for why the pass's own table could not have shown this.

**r10earl40 (LIVE)** — no interaction. `Earlgrey_0_1` is `changed=0` and is not
among the 7 movers. I also checked **landing composability**: r10earl40's live
main-tree diff applies to 6e1c27a, and `/tmp/r10uvm69.patch` then applies
`--check` clean on top. The two `include/UhdmExporter.h` hunks are ~2370 lines
apart. **No landing conflict.**

**r10sd2 (LIVE)** — the collision report is accurate and complete: both
SeqDriver databases move (+1436/+1463), the cmp print lengthens by 16, head
identity is unchanged, distance improves 230. **r10sd2 must re-baseline.**

---

## 8. STATED GATE == CODE GATE

The stated gate is *(receiver is exactly the return-variable `NamedValue`) &&
statement position && not out-of-body*. The code
(`ExprEmit.cpp:309`) is exactly:

```cpp
if (!stmtCtx || !funcRetSym)                                 return false;
if (curSubOob9)                                              return false;   // (b)
if (recv.kind != ExpressionKind::NamedValue)                 return false;
if (&recv.as<NamedValueExpression>().symbol != funcRetSym)   return false;
auto* ps0 = funcRetSym->getParentScope();
return ps0 && ps0->asSymbol().kind == SymbolKind::Subroutine;
```

No fourth clause. **Both call sites call it; neither re-implements it**
(`grep -n retNameRecvCollapse69 src include` → declaration + definition + 2
call sites). I verified the `stmtCtx` trap the header warns about: the built-in
site captures `bool stmtCtx = callStmtContext;` at line 11657 immediately before
`callStmtContext = false;`, and the class-method site captures
`bool callStmtCtx0 = callStmtContext;` at 9505 likewise — **each is the call's
own flag, never the cleared member.** `curSubOob9` and `funcRetSym` are
saved/restored around the same subroutine-body emission in `TaskFuncEmit.cpp`
(5162/5189 and 5360/5376), so the predicate reads a consistent pair. The
class-method arm is correctly guarded by `call.thisClass()` non-null.

---

## 9. NUMBERED FINDINGS

None blocks landing. F1 is the only one I changed.

**F1 — `gridcells.sh` ships NON-EXECUTABLE (mode 644) while every other `.sh`
in the directory is 755.** It is the driver that produces the pass's headline
grid table, and its own usage line documents `gridcells.sh <ctrl> <final>`.
Invoked as documented it fails with no output; in a `for` loop it printed
**nothing at all** and returned 1 — indistinguishable from "no differing cells",
which is precisely the silent-zero failure mode this directory's other drivers
are written to prevent.
```
$ ls -la tools/probe/r10uvm69repro/gridcells.sh   # -rw-r--r--  (all others -rwxr-xr-x)
$ ./gridcells.sh a b        # -> no output, exit 1
$ bash ./gridcells.sh a b   # -> the table
```
Present in the implementer's worktree too, so it is not a patch artefact.
**FIXED in the re-cut patch** (`chmod +x`); no measurement changes.

**F2 — the §1 corpus table lists line 351 as one of the "7 SHAPE-disagreeing
cells", but 351 is not a SHAPE cell by the instrument's own accounting.**
`calljoin.py` keys on argument spans; `.len()` has no arguments, so golden keys
it `351|@28NOARG` and ours-control keys it `351|@9NOARG` — different keys, so
the pair cannot join and lands in GONLY/OONLY, never in SHAPE. The 7 SHAPE
entries are `{157, 343, 357×2, 946, 992×2}` = **five distinct lines**, and the
README's parenthetical ("the 7th SHAPE cell is 357/992 counted twice") does not
reconcile the table it follows.
```
$ grep -P "\t351:" g.cen  -> KEY 351|@28NOARG method_func_call len 351:28-351:31
$ grep -P "\t351:" o_ctrl.cen -> KEY 351|@9NOARG func_call uvm_instance_scope 351:9-351:33
```
**The substantive claim about 351 is TRUE and I verified the repair
independently**: the final database emits `method_func_call len 351:28-351:31`,
matching golden exactly. The accounting is also fully coherent —
`agree +9 = 7 SHAPE cells + the 2 unpaired 351 instances`, with GONLY and OONLY
each falling by exactly 2 (1946→1944, 1961→1959). Documentation defect only.

**F3 — the grid headline numbers are diff-SIDE counts, not cell counts.**
"14 → 0", "12 → 0", "5 → 2" are `grep -cE '^[<>]'` line counts; a changed cell
contributes two. The README says so for `a3` ("2 diff lines = one cell") but not
for `a1`/`a2`, and the summary report's axis table reads as cells. Cosmetic —
the fixed cell counts are 7 and 6, and every underlying cell is tabulated
correctly.

**F4 — the grid table is structurally blind to `new` cells, yet §8 cites it.**
`gridcells.sh`'s formatter filters `grep -v "\tnew\t"`, so §8's claim that the
`method_func_call 'new'` objects "are visible in every arm census here and are
untouched" cannot be read off the table the README prints. The claim is
nonetheless **TRUE** — I verified it from raw `callcen` output (§7 above). The
filter is a reasonable boundary choice; the citation just points at the wrong
instrument.

---

## 10. RANKED RESIDUES (after verification)

* **R1 — chained return-name receiver** (`n_chain.inner.touch(n);`). Golden
  collapses to an **argument-less** `func_call n_chain 75:7-75:29`; we keep
  `method_func_call inner` with the receiver as prefix. The only differing cell
  left in `a3` (2 diff lines = 1 cell). **Zero corpus population** — confirmed
  by me: no such cell in any of the four UVM tests. Correctly deferred to
  § deepRecvCall11. Highest-value residue *on this axis*, lowest urgency.
* **R2 — the NEW head on all three target rows.** `int_var` for
  `uvm_tr_stream::get_recorders` @371:13 carrying `vpiSigned:1` and
  `ref_typespec → logic_typespec`. The § atomVarSignedWritten68 /
  § arrayVarSignedWritten8 family. **This is the next target on these rows.**
* **R3 — SeqDriver's `<null>` design-package head** (1.41M cmp lines), r10sd2's
  live target; unchanged in identity here but **re-baselining is required**.
* **R4 — 58 `NAME` cells** on SimpleUVM (shape agrees, name differs), unchanged
  control and final. Naming is context-dependent (MEMORY.md dead-end).
* **R5 — 1944 GONLY / 1959 OONLY `NOARG`-keyed cells.** An **instrument**
  limitation of `calljoin.py`'s argument-span key, correctly labelled as such.
  F2 shows the cost: a real disagreement (351) hides in this bucket. **A future
  pass on this axis should give `callcen.cpp` a better key for argument-less
  calls before trusting the SHAPE count as the whole population.**

---

## 11. WHAT I RAN (reproduction index)

```sh
# gates
SLANG_UHDM=/tmp/wt_v69/build/slang-uhdm ./tests/check_goldens.sh
SLANG_UHDM=/bin/false                   ./tests/check_goldens.sh
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode testflags --jobs 2 \
        --out /tmp/v69_u2r_final.csv --workdir /tmp/v69wd_u2r_final
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 2 \
        --out /tmp/v69_sl_final.csv --workdir /tmp/v69wd_sl_final     # + pristine twins
bash tools/probe/r10uvm69repro/ct8rows.sh results/gate_uhdm2rtlil.csv /tmp/v69_u2r_final.csv
bash tools/probe/r10uvm69repro/ct8rows.sh results/golden_surelog.csv  /tmp/v69_sl_final.csv
SELFCHECK=1 SELFCHECK1=1 bash tools/probe/r10uvm69repro/byteverify.sh <final-wd> <pris-wd>
# head, census, movers
bash tools/probe/r10uvm69repro/rowheads.sh <wd> <out> SimpleUVM Scoreboard BuildUVMPkg SeqDriver
/tmp/r10uvm69_callcen <db> ; python3 tools/probe/r10uvm69repro/calljoin.py g.cen o.cen
bash tools/probe/r10uvm69repro/mv1.sh <golden> <pristine> <patched> <label>
bash tools/probe/r10uvm69repro/detcheck.sh <bin> 3 <scoreboard args>   # from the test's src dir
# grid + my gap arm
SLANG_UHDM=<bin> bash tools/probe/r10uvm69repro/ct1arm.sh {a1_type,a2_scope,a3_recv,v1_gaps}.sv <wd>
CALLCEN=/tmp/r10uvm69_callcen bash tools/probe/r10uvm69repro/gridcells.sh <ctrl-wd> <final-wd>
# canaries
bash tools/probe/r10uvm52repro/canaries.sh <new.csv> <baseline.csv>
EXPECT_UNKNOWN=1 bash tools/probe/r10uvm69repro/ctcan2.sh <baseline.csv> <new.csv>
bash tools/probe/r10uvm69repro/canaudit.sh ./canaries.sh ./ctcan2.sh
# probe build (the directory ships no pbuild.sh; r10uvm55repro's recipe works)
g++ -std=c++20 -O1 callcen.cpp -o /tmp/r10uvm69_callcen -I~/.local/include \
    ~/.local/lib64/lib{uhdm,capnp,kj}.a -lpthread
```

All four sweep workdirs (~800 MB) deleted after measurement.

---

## 12. VERDICT

**PASS.** The law is correctly decoded, correctly narrowed, and correctly
implemented at both call sites; the head is cleared on all three target rows
with every cleared cell matching golden byte-for-byte; all five gates are green
on binaries I built; both refutations reproduce; the boundaries to r10svs2,
r10uvm55/56, r10earl40 and r10sd2 are verified by execution; and the law
survives seven axes its author never tested. The four findings are
documentation and driver-hygiene defects — F1 fixed in the re-cut, F2–F4
recorded here.

**Deliverable:** `/tmp/r10uvm69.verified.patch` — the delivered patch plus this
file, my `v1_gaps.sv` over-fire arm, and the `gridcells.sh` executable bit.
**Production code is UNCHANGED from the delivered patch.**
