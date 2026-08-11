# r10svs2 — ADVERSARIAL VERIFICATION

**VERDICT: PARTIAL.**

All five gates reproduce, every headline number reproduces (the patched binary is
**bit-identical** to the implementer's), and the two laws are real — I confirmed
them independently against a golden I generated myself, and my own arm w3 scores
**7/7** on dimensions the implementer never measured (macro expansion, deep
dotted receivers). The positive controls hold byte-for-byte.

But the pass ships **one genuine over-fire that the implementer's arm set
structurally cannot see**, and it is a *regression from a cell that already
matched golden*:

> `§ parensLessFuncRefIsRefObj` has **no statement-position gate**, so a
> **FUNCTION** called **receiver-less, parens-less, in STATEMENT position**
> (`zero;`) is turned into a `ref_obj`. Golden emits `func_call`. Pristine
> emitted `func_call`. We now emit `ref_obj`.

Corpus reach today is **zero** (I priced it empirically, twice over), so no gate
goes red and the patch is *shippable as measured*. It is PARTIAL rather than PASS
because the shipped code contradicts the pass's own stated law, takes an
equal-to-golden cell to unequal, and the implementer's write-up asserts a
statement-position scope the code does not implement.

Verifier worktrees: `.claude/worktrees/r10svs2v` (patched, branch `r10svs2vwt`)
and `.claude/worktrees/r10svs2vp` (pristine, branch `r10svs2vpris`), both from
`946579a`, both built by me. No `git stash`. `results/`, `scripts/` and `tests/`
untouched throughout.

---

## 0. PATCH SCOPE AUDIT — CLEAN

`git apply --stat /tmp/r10svs2.patch` (full output, nothing elided):

```
 src/ExprEmit.cpp                            |  115 +++++
 tools/probe/r10svs2repro/README.md          |  635 ++++++++++++++++++++++++
 tools/probe/r10svs2repro/s1_dynsize.sv      |   37 ++
 tools/probe/r10svs2repro/s2_querykind.sv    |   48 ++
 tools/probe/r10svs2repro/s3_arraykind.sv    |   34 +
 tools/probe/r10svs2repro/s4_context.sv      |   41 ++
 tools/probe/r10svs2repro/s5_negctl.sv       |   38 ++
 tools/probe/r10svs2repro/s6_otherbuiltin.sv |   36 ++
 tools/probe/r10svs2repro/s7_recvless.sv     |   37 ++
 tools/probe/r10svs2repro/svall.sh           |   36 ++
 tools/probe/r10svs2repro/svarm.sh           |   53 ++
 tools/probe/r10svs2repro/svcells.py         |  130 ++++++
 tools/probe/r10svs2repro/svrecv.sh          |   32 +
 13 files changed, 1265 insertions(+), 7 deletions(-)
```

* `git apply --check` → **rc=0** on a pristine `946579a`.
* **No `results/*.csv`, no `scripts/verify_golden.py`, no `tests/check_goldens.sh`,
  no slang header, no `third_party`.** Forbidden-path scan of the patch text
  returned empty.
* `git status --short results/ scripts/ tests/` — **empty before AND after**
  applying, and again after every gate. (`scripts/__pycache__/` appeared once,
  created by *my own* importlib load of `verify_golden.py` to recover a golden
  cache key; I removed it. It is not in the patch.)
* Exec bits preserved: 3 × `new file mode 100755` (the `.sh` drivers), 9 ×
  `100644`.
* Production diff is `src/ExprEmit.cpp` **+108 / −7** — matches the claim.
* **Patch md5 `4495c12779baf79576c78b39869af634`** — matches.
* No fenced name appears in any r10svs2repro *driver*; the only mention is
  documentation prose at `README.md:532`.

---

## 1. EVERY NUMBER, MINE BESIDE THEIRS

### Gates

| Gate | Implementer | Mine | |
|---|---|---|---|
| G1 pristine md5 | `ed106184c97207183fe1316211507882` | `ed106184c97207183fe1316211507882` | ✅ and **= main-tree build**, so the worktree really is 946579a |
| G1 patched md5 | `5efa1ddebf96bce7869150586162e931` | `5efa1ddebf96bce7869150586162e931` | ✅ **bit-identical rebuild** |
| G1 link line / errors | present / 0 | present / 0 | ✅ md5 asserted in a separate command before any sweep |
| G2 goldens | 23 PASS / 0 FAIL | **23 / 0** | ✅ |
| G2 negative control | 0 PASS / 23 FAIL | **0 / 23**, rc=1 | ✅ |
| G3 u2r testflags | 679 EQ / 50 REJECT / 2 SL_FAIL | **679 / 50 / 2** | ✅ |
| G3 u2r dump | 496 match / 183 differ / 52 blank | **496 / 183 / 52** | ✅ |
| G3 whole-row | 0 rows | **0 differing ROWS (0 row-sides)**, 731 rows | ✅ |
| G4 srl default | 467 / 13 | **467 / 13** (+5 DEFERRED, 284 REJECT, 25 SL_FAIL) | ✅ |
| G4 srl testflags | 463 / 10 | **463 / 10** | ✅ |
| G4 srl dump match | 225 / 165 | **225 (default) / 165 (testflags)** | ✅ |
| G4 whole-row | 0 rows | **0 differing ROWS**, 1588 rows | ✅ |
| G5 u2r bytes | 0 / 679 | **0 / 679** | ✅ |
| G5 u2r SELFCHECK / SELFCHECK1 | 678/679, 1 | **678/679, 1** | ✅ |
| G5 srl bytes | 9 / 953 | **9 / 953**, identical mover set | ✅ |
| G5 srl SELFCHECK / SELFCHECK1 | 952/953, 10 | **952/953, 10** | ✅ |

Commands: `cmake --build build -j 3`; `SLANG_UHDM=$PWD/build/slang-uhdm bash
tests/check_goldens.sh`; `SLANG_UHDM=/bin/false bash tests/check_goldens.sh`
(quoted: `FAIL AssignSumOfConstants (diff …/AssignSumOfConstants.dump
/tmp/tmp.yIbrVZaYbq/slang.dump)`); `python3 scripts/verify_golden.py --corpus
{uhdm2rtlil,surelog} --mode {testflags,both} --jobs 2` with my own `--out`/
`--workdir`; `tools/probe/r10oth8repro/ct8rows.sh <committed baseline> <mine>`;
`SELFCHECK=1 SELFCHECK1=1 tools/probe/r10oth6repro/byteverify.sh`.

### Canaries

| | Implementer | Mine |
|---|---|---|
| `canaries.sh` u2r | ok=8 changed=0 absent=0 | **ok=8 changed=0 absent=0** ✅ |
| `canaries.sh` surelog | ok=52 changed=0 absent=0 | **ok=52 changed=0 absent=0** ✅ |
| `ctcan2.sh` u2r, `EXPECT_UNKNOWN=6` | ok=1 changed=0 absent=0 | **ok=1 changed=0 absent=0** ✅ |
| `ctcan2.sh` surelog, `EXPECT_UNKNOWN=1` | **ok=6** | **ok=58** ❌ see Finding 4 |
| `canaudit.sh` | audited=29 UNCOVERED=0 FENCE-BREACH=0 | **audited=29 UNCOVERED=0 FENCE-BREACH=0** ✅ |

By name, mine vs the committed baseline — both **byte-identical**:
`InterfaceModPort,{default,testflags},CMP_EQUAL,,,differ` and
`BlackParrotComplex,{default,testflags},CMP_EQUAL,,,differ`.

The four slang-fenced rows are byte-identical to `results/golden_surelog.csv`
(they ride along with a whole-corpus sweep, as they do in the committed
baseline); no claim is made about them and no driver dispatches them.

### Heads and the three distances

| | Implementer | Mine |
|---|---|---|
| `946579a` head | `ref_obj (work@packet::cal_fcs::size)` 48:22 | **`ref_obj: (work@packet::cal_fcs::size), id:2152, line:48:22, endln:48:26`** ✅ = the brief's head verbatim |
| `946579a` depth | 26 | **26 lines, heads=1** ✅ |
| shipped head | `begin (work@packet::byte_unpack)` 84:3 | **`begin: (work@packet::byte_unpack), id:2288, line:84:3, endln:84:22`** ✅ |
| shipped depth | 1512 | **1512 lines, heads=1** ✅ |
| `diff -u` content | 2698 → 2632 (**Δ −66**) | 3972 → 3906 (**Δ −66**) ⚠️ Finding 5 |
| multiset `msdist.sh` | 757 → 726 (**Δ −31**) | 829 → 798 (**Δ −31**) ⚠️ Finding 5 |

`grep -c '^LHS:'` = 1 on every run, as required.

### Movers — all 9, attributed independently

Same 9 files, same direction: SVSwitch ×2, SimpleUVM ×2, SeqDriver ×2,
BuildUVMPkg ×2, Scoreboard ×1 (default only). Across all nine:
**`vpiSigned` 0, `class_typespec` 0, `vpiTypedefAlias` 0** ✅ — the
build-dependent UVM alias churn did not fire.

Census of the *whole corpus* (see §3 for why 9 files bound it):
**366 `hier_path` span lines changed, 619 changed lines total.**

### Per-shape convergence against golden — the only attributable measure

SVSwitch, golden generated by me (`surelog -parse -nocache -f filelist`):

| shape | golden | pristine | patched |
|---|---|---|---|
| `method_func_call: (size), 65:32-65:36` **(parens-ful positive control)** | 1 | 1 | **1** ✅ |
| `method_func_call: (size), 77:14-77:18` **(parens-ful positive control)** | 1 | 1 | **1** ✅ |
| `hier_path: (data.size), 48:17-48:26` | 3 | 0 | **3** ✅ |
| `ref_obj: (work@packet::cal_fcs::size), 48:22-48:26` **(brief's target head)** | 1 | 0 | **1** ✅ |
| `hier_path: (bytes.size), 40:20-40:30` | 3 | 0 | **3** ✅ |
| `func_call: (cal_fcs), 65:45-65:52` | 0 | 1 | **0** ✅ |

All 12 `cal_fcs`-bearing shapes, including
`|vpiFullName:work@packet::display::cal_fcs`, have **identical counts in golden
and patched**.

SimpleUVM, golden generated by me — the implementer's four claims, **span-keyed
exactly as they counted them**:

| shape | claimed g/base/shipped | mine |
|---|---|---|
| `ref_obj: (uvm_pkg::uvm_table_printer::emit::max)` | 2 / 0 / 2 | **2 / 0 / 2** ✅ |
| `ref_obj: (…::wait_ptrigger::triggered)` | 1 / 0 / 1 | **1 / 0 / 1** ✅ (exact fullname `uvm_pkg::uvm_event_base::wait_ptrigger::triggered`, 122:15-122:24) |
| `hier_path: (q.max)` @ golden span 1054:12-1054:17 | 6 / 0 / 6 | **6 / 0 / 6** ✅ |
| `hier_path: (m_event.triggered)` @ 122:7-122:24 | 3 / 0 / 3 | **3 / 0 / 3** ✅ |

Every shape goes **0 → exactly golden's count**. Confirmed.

### Arms, refutations, corrections

| claim | mine |
|---|---|
| arm totals patched `CELLS 45 EQ 39 DIFFER 3 DIFFERKIND 1 UNMEASURED 2` | **45 / 39 / 3 / 1 / 2** ✅ |
| arm totals pristine `CELLS 44 EQ 19 …` | **CELLS 45 EQ 20 DIFFER 1 DIFFERKIND 22 UNMEASURED 2** ⚠️ Finding 6 |
| refutation 3: slang rejects `fix.size`, Surelog accepts | ✅ `error: invalid member access for type 'int$[8]'`; Surelog produced a database |
| correction: **11** `method_func_call: (size)`, not 10 | ✅ **11**, at 11 distinct spans |
| the four cast rows fixed | ✅ all four `CMP_EQUAL,,,match`, byte-identical to baseline |

---

## 2. FINDINGS, most severe first

### F1 — OVER-FIRE (SEVERITY: HIGH). `§ parensLessFuncRefIsRefObj` has no statement-position gate; a parens-less FUNCTION in statement position regresses from equal-to-golden to wrong.

The gate at `src/ExprEmit.cpp:8960` is

```cpp
if (realIsFunc18 && rawText(expr.sourceRange) == sub.name) {
```

`realIsFunc18` keeps *tasks* out. **Nothing keeps statements out.** The
implementer's own law says the scope is "**expression (not statement)
position**", and their §3 refutation 1 argues explicitly that "what actually
protects `obj.print;` is that it is a **STATEMENT**" — but that protection is
never implemented for the receiver-less site.

Arm `w1_stmtfunc.sv` (mine, in this directory). Cell (1) is `zero;` — a
**function**, receiver-less, no parens, **statement** position; legal
SystemVerilog, slang accepts it. Cell (2) `zero();` is the parens-ful control,
(3)/(4) are the task cells arm s7 already had.

```
$ SLANG_UHDM=<patched>  bash svarm.sh w1_stmtfunc.sv /tmp/r10svs2v_arm_w1_stmtfunc_pat
$ SLANG_UHDM=<pristine> bash svarm.sh w1_stmtfunc.sv /tmp/r10svs2v_arm_w1_pris
$ grep -nE "func_call|ref_obj|task_call" <dump> | grep -E "line:1[4-9]:"
```

| line | source | GOLDEN | PRISTINE 946579a | PATCHED |
|---|---|---|---|---|
| 15 | `zero;` | `func_call: (zero), 15:5-15:9` | `func_call: (zero), 15:5-15:9` | **`ref_obj: (work@sf::g::zero), 15:5-15:9`** ❌ |
| 16 | `zero();` | `func_call: (zero), 16:5-16:11` | same | same ✅ |
| 17 | `void_t;` | `task_call: (void_t), 17:5-17:11` | same | same ✅ |
| 18 | `void_t();` | `task_call: (void_t), 18:5-18:13` | same | same ✅ |

**The pristine cell was byte-identical to golden and the patch breaks it.** This
is precisely the failure mode the brief warned about ("two passes ago exactly
that shipped and was caught only by BUILDING THE MISSING ARM"): arm s7 measured a
parens-less *task* in statement position and a parens-less *function* in
*expression* position, so the product cell — parens-less **function** in
**statement** position — is the one square the arm grid leaves empty, and it is
the only square with no guard.

**CORPUS REACH, priced empirically, not syntactically:**
* u2r byte movers **0 / 679** → zero reach on that corpus, for either law.
* The 9 surelog movers contain exactly **3** `func_call → ref_obj` swaps, all
  `cal_fcs` in SVSwitch `Packet.sv`. I read all three sites:
  * `:65` `$display("\n %2d : %h ",data.size() + 3 , cal_fcs);` — argument
  * `:77` `bytes[data.size() + 3] = cal_fcs;` — RHS
  * `:91` `if(bytes[bytes.size - 1] != cal_fcs)` — comparison operand
  All three are **expression** position. **Reach = 0 today.**

So this ships green. It is nonetheless a latent regression: it is wrong against
golden, it is wrong against the pass's own law text, and the next corpus row that
writes `f;` as a statement silently un-converts. The fix is one clause — the same
`stmtCtx` flag already used at `src/ExprEmit.cpp:9838`.

### F2 — SPAN ARITHMETIC (SEVERITY: MEDIUM). The new hier_path span is built as `receiver_end + 1 + len(name)`, which is "to the end of the method name" only in the *tight* spelling.

```cpp
auto mStart9 = recv->sourceRange.end() + 1;          // assumes exactly one char: the '.'
… SourceRange(expr.sourceRange.start(), mStart9 + name.size())
```

Any trivia between the receiver and the method name — a space, a comment, a
newline — shifts the real method token right, and both the new `ref_obj`
location and the new hier_path span end land short. Arm `w2_spacedot.sv`:

| line | source | GOLDEN hier_path | PATCHED hier_path | GOLDEN ref_obj | PATCHED ref_obj |
|---|---|---|---|---|---|
| 14 | `d.size` **tight** | 14:9-14:15 | **14:9-14:15** ✅ | 14:11-14:15 | **14:11-14:15** ✅ |
| 15 | `d . size` | 15:13-**15:21** | 15:13-**15:19** ❌ | 15:**17**-15:21 | 15:**15**-15:19 ❌ |
| 16 | `q .size` | 16:13-**16:20** | 16:13-**16:19** ❌ | 16:**16**-16:20 | 16:**15**-16:19 ❌ |
| 17 | `q. size` | 17:13-**17:20** | 17:13-**17:19** ❌ | 17:**16**-17:20 | 17:**15**-17:19 ❌ |
| 18 | `d /* c */ . size` | 18:13-**18:29** | 18:13-**18:19** ❌ | 18:**25**-18:29 | 18:**15**-18:19 ❌ |
| 19–20 | `d` ⏎ `.size` | 19:13-**20:18** | 19:13-**20:5** ❌ | **20:14**-20:18 | **20:1**-20:5 ❌ |

**This is NOT a regression** — I checked, and pristine's `method_func_call`
carried the identical wrong columns (`15:15-15:19`, `20:1-20:5`), so the `+1`
offset is pre-existing. The finding is that the patch **propagates a known-broken
offset onto a new surface** (the hier_path span), and that the law as documented
("the span runs to the end of the method name") is true only for the tight
spelling. Reach: 0 movers today. Correct fix: derive `mStart9` from the method
name token, not from `receiver_end + 1`.

### F3 — THE STATED LAW IS REFUTED BY GOLDEN (SEVERITY: MEDIUM, documentation/model). The real gate is "slang's `sourceRange` collapsed onto the receiver", not "no written parentheses".

The implementer states the unifying gate as "**written parentheses × expression
(not statement) position**". Arm `w4_classbuiltin.sv` cell (3) refutes it:

```
line 17:  r = r + this.randomize;      // PARENS-LESS, EXPRESSION position
GOLDEN  : hier_path: (this.randomize), 17:14-17:28
          \_method_func_call: (randomize), 17:19-17:28      <-- STILL A CALL
PATCHED : identical to golden ✅
```

A parens-less, expression-position dotted method that golden keeps as a
`method_func_call`. The shipped code is **correct** here only because its gate is
`rawText(expr.sourceRange) == recvText`, and for `randomize` slang's
`sourceRange` already spans `this.randomize`, so the gate never fires. The code
is right; **the law text is wrong**, and it is wrong in the dangerous direction:
a future pass that "cleans up" the gate into an honest written-parens test —
exactly what the prose invites — will fire on `this.randomize` and regress it.
The law should be restated as the *observable* it actually keys on.

Controls in the same arm all hold (locators with `with` → `hier_path` named after
the array alone, `method_func_call` retained, cells 19–22; `constraint_mode` /
`rand_mode` parens-ful statements unchanged). Separately and pre-existing in
*both* binaries: receiver-less `randomize` / `randomize()` (cells 1–2) are
**dropped entirely** by us where golden emits
`ref_obj: (work@w4::f::randomize) 15:10-15:19` and `func_call: (randomize)
16:14-16:25`. Not this pass's doing; worth a residue entry.

### F4 — UNREPRODUCIBLE NUMBER (SEVERITY: LOW). `ctcan2.sh` on the surelog pair reports **ok=58**, not the claimed **ok=6**.

```
$ EXPECT_UNKNOWN=1 tools/probe/r10oth7repro/ctcan2.sh results/golden_surelog.csv <mine>
---- ctcan2 rows: ok=58 changed=0 absent=0 unknown-patterns=1
PASS: every supplementary canary row is byte-identical to the baseline.
```

Deterministic, and identical with the arguments swapped, so it is not an
arg-order artefact. The substantive assertions (`changed=0 absent=0`, PASS,
`unknown-patterns=1` matching `EXPECT_UNKNOWN=1`) all hold, and the u2r figure
(`ok=1`) matched exactly — so this is a mis-transcription in the write-up, not a
gate failure. Flagged because an under-reported `ok` count would mask canaries
that were never actually compared.

### F5 — NUMBER REPRODUCIBLE ONLY AS A DELTA (SEVERITY: LOW). The two absolute distances are golden-provenance-dependent.

My `diff -u` content reads 3972 → 3906 and my multiset 829 → 798, against the
implementer's 2698 → 2632 and 757 → 726. **Both deltas are exactly reproduced
(−66 and −31.)** The absolute values differ because my SVSwitch golden came from
the test's own `-f filelist` command line while theirs came from the sweep's
cached `default`-mode golden (sources only). The cmp head matched verbatim, so
the two goldens agree on the object under test. Recording it so a future pass
does not treat 2698/757 as reproducible constants — only the deltas are.

### F6 — MINOR ARM-TABLE DISCREPANCY (SEVERITY: LOW). Pristine arm totals are `CELLS 45 EQ 20`, not `CELLS 44 EQ 19`.

```
$ SLANG_UHDM=<pristine> bash svall.sh vpris   → CELLS=45 EQ=20 DIFFER=1 DIFFERKIND=22 UNMEASURED=2
$ SLANG_UHDM=<patched>  bash svall.sh vpat    → CELLS=45 EQ=39 DIFFER=3  DIFFERKIND=1  UNMEASURED=2
```

The patched row matches the claim exactly. The pristine row is one cell richer
than reported (cells are union-keyed over both sides' spans, so the baseline
count can shift with an arm-source edit). The substantive claim — **DIFFERKIND
22 → 1** — reproduces exactly.

### F7 — GOLDEN SUITE BARELY COVERS THE CHANGED SURFACE (SEVERITY: INFORMATIONAL, but it is the reason F1/F2 needed hand-built arms).

The brief asked specifically whether a span change could hide from the goldens.
It can:

```
$ cd tests/golden && for f in *.dump; do n=$(grep -c hier_path $f); [ $n -gt 0 ] && echo "$n $f"; done
46 simple_nested_struct_nopack.dump
```

**1 of 23 goldens contains a `hier_path` at all** (46 lines, one file). "23 PASS"
is therefore near-zero evidence about `hier_path` spans, and the real guard is
the byte verifier plus hand-built arms.

The whole-corpus span census, bounded rigorously — a **byte-identical database
cannot contain a different span**, and byteverify proved only 9 of 1632
databases changed:

```
TOTAL hier_path span lines changed across the ENTIRE corpus = 366
TOTAL changed lines = 619
```

Every one of the 366 is an *extension* of an existing span to golden's value; I
verified the direction per-shape in §1 and found no span moved away from golden.

### F8 — A CLAIM I HAD TO REPAIR TO CONFIRM (SEVERITY: INFORMATIONAL). "Every changed line is a span extension or a swap" is false line-wise for one mover, true in multiset terms.

`./testflags/SeqDriver-32af76aa` shows **36 changed lines** outside the law's
classes — `bit_typespec (uvm_reg_data_t)`, `range`, `ref_typespec`, `vpiName`.
Every one appears as a `-X` with a matching `+X` of identical content and count:

```
$ grep -vE 'hier_path|ref_obj|method_func_call|func_call|vpiFullName|vpiFunction|\\_function:' vb.dump |
    sed 's/^ *//' | sort | uniq -c  > vb.ms     # same for the patched dump
$ diff -q vb.ms va.ms   →   IDENTICAL
```

Pure `diff` **realignment**, zero content change — the campaign's own law that
`diff -u` is alignment-sensitive. The attribution claim stands, but only when
stated multiset-wise; line-wise it reads as 36 unexplained lines.

---

## 3. WHAT I CONFIRMED THAT THE IMPLEMENTER DID NOT MEASURE

Arm `w3_macrodeep.sv` (mine) covers two dimensions absent from s1–s7 and both are
**clean — 7/7 cells byte-identical to golden**, pristine wrong on 3 of them:

| line | source | golden = patched? |
|---|---|---|
| 26 | `d.size` tight | ✅ `hier_path 26:9-26:15` + `ref_obj 26:11-26:15` |
| 27 | `` `SZ_NOPAREN `` (macro, parens-less method) | ✅ `hier_path 27:13-27:19` + `ref_obj 27:15-27:19` |
| 28 | `` `SZ_PAREN `` (macro, parens-ful) | ✅ control holds, `method_func_call 28:15-28:19` |
| 29 | `` `F_NOPAREN `` (macro, parens-less func) | ✅ `ref_obj (work@w3::f::zero) 29:13-29:17` |
| 30 | `` `F_PAREN `` (macro, parens-ful func) | ✅ control holds, `func_call 30:13-30:19` |
| 31 | `a.b.size` deep dotted, parens-less | ✅ `hier_path 31:13-31:21` + `ref_obj 31:17-31:21` |
| 32 | `a.b.size()` deep dotted, parens-ful | ✅ control holds |

This is a real strength: `rawText`'s `getFullyOriginalRange` remapping keeps the
two sides of the gate consistent inside a macro, so the law fires correctly there
rather than silently missing or over-firing. I expected a defect here and found
none.

---

## 4. RANKED RESIDUE (the implementer's list, re-priced)

* **V1** *(new, mine)* — **F1**, parens-less function in statement position.
  One-clause fix, ready-made witness at `w1_stmtfunc.sv:15`. Zero reach, but it
  is a live wrong-vs-golden cell. **Fix before the next parens pass touches
  site 2.**
* **V2** *(new, mine)* — **F2**, trivia-aware `mStart9`. Fixes 5 cells in
  `w2_spacedot.sv` and removes a pre-existing offset bug from two object kinds at
  once.
* **V3** *(new, mine)* — restate the law per **F3** before anyone "simplifies"
  the gate into a written-parens test.
* **R1** (theirs) — user-defined class method, parens-less, expression position;
  the single surviving `DIFFERKIND`. Confirmed present (arm s5 site 24:11).
* **R2** (theirs, 3 SVSwitch cells) — `.bytes::` vs `::bytes::` index prefix.
* **R3** (theirs, 2 cells) — name-only query `ref_obj` inside `new[…]`.
* **R4** (theirs, 2 cells) — `unique` takes the array-alone shape.
* **V4** *(new, mine)* — receiver-less `randomize` / `randomize()` are **dropped
  entirely** by both binaries; golden emits `ref_obj` / `func_call` (F3, cells
  1–2). Pre-existing, unrelated to this pass, previously unrecorded.
* **R5 / R6** (theirs) — `new[…]` family; `h.o = new()` lvalue span. I observed
  R6 directly: `hier_path: (o.a)` golden `40:16-40:17` vs ours `40:16-40:19` in
  both binaries.
* **R7** (theirs) — **confirmed**: the shipped SVSwitch head is
  `begin: (work@packet::byte_unpack) 84:3-84:22`, the Interface/clocking-block
  cluster. The next SVSwitch pass is an interface pass.

---

## 5. BOTTOM LINE

`SVSwitch` does **not** convert — quoted from my own sweep, and I agree with the
implementer's honesty on this point:

```
SVSwitch,default,CMP_NOTEQUAL,decompile:,,
SVSwitch,testflags,CMP_NOTEQUAL,decompile:,,
```

The brief's target head is genuinely cleared (`ref_obj
(work@packet::cal_fcs::size) 48:22` golden 1 / pristine 0 / **patched 1**), the
parens-ful positive controls at `65:32` and `77:14` are **byte-identical to
before and to golden**, all five gates are green on my independent rebuild, all
nine movers converge 0 → exactly golden's count, and no canary moved.

**PARTIAL**, on F1 alone: one square of the law's grid was never built, and the
code fires there on a cell that already matched golden.
