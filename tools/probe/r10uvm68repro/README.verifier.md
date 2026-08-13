# r10uvm68 — INDEPENDENT ADVERSARIAL VERIFICATION of `§ atomVarSignedWritten68`

**VERDICT: PASS.**

This document is **r10uvm68's own** and describes r10uvm68 only. Nothing is
carried over from `r10uvm67repro` or from any other pass. It **replaces** the
implementer's self-assessment of the same name, which correctly opened with
"NO INDEPENDENT ADVERSARIAL VERIFIER RAN" — one has now run, and this is its
report. The implementer's self-check inventory is preserved verbatim in §7 so
that the honest disclosure it made is not erased by the fact that the gap it
disclosed is now closed.

Everything below was produced by the verifier from its **own** worktrees, its
**own** builds, its **own** sweeps and, for the two checks that mattered most,
its **own instruments** written from the dump format rather than reused from
the implementer's `dumptree.py`. No number here was copied from `README.md`;
every one was re-measured and only then compared.

---

## 0. WHAT WAS BUILT, AND THE STRONGEST SINGLE RESULT

| worktree | base | `git status` | binary md5 | errors |
|---|---|---|---|---|
| `/tmp/wt_r10uvm68vpris` | `df0cdae4942…` | EMPTY | `fc59a2414877316104c88c8c1fe43b77` | 0 |
| `/tmp/wt_r10uvm68v` (patch applied) | `df0cdae4942…` | 4 src + probe dir | `c7900a56e4ed369ce31987a75c105171` | 0 |
| `/tmp/wt_r10uvm68vhead` (patch on branch head) | `983cf4b3086…` | 4 src + probe dir | `0a965be090f8ca63719dc30135cf3533` | 0 |
| `/tmp/wt_r10uvm68vsite` (verifier instrumentation, **not shipped**) | `df0cdae4942…` | +counters | — | 0 |

Both `Linking CXX executable slang-uhdm` and `Built target slang_uhdm` were read
off each build log; each md5 was asserted separately against `^[0-9a-f]{32}$`.

**The two df0cdae md5s are BIT-FOR-BIT the implementer's** (`fc59a241…` control,
`c7900a56…` shipped). An independently configured, independently compiled build
from a clean worktree reproduced both binaries exactly, so every runtime number
in `README.md` was produced by the same machine code this verifier measured.

The patch **round-trips to the same md5** on `df0cdae`
(`40e47dc7d57a35e4d0224a7ddf7d9588`) and `git apply` is clean on `df0cdae` **and**
on branch head `983cf4b`.

---

## 1. THE FIVE GATES, RE-RUN INDEPENDENTLY — ALL GREEN

`GOLDEN_DEFER` echoed `[UNSET]` before GATE 4. All sweeps `--jobs 2`, own
`--out`, own `--workdir`, deleted afterwards (§8).

| gate | implementer | verifier | verdict |
|---|---|---|---|
| **1 BUILD** | `fc59a241…` / `c7900a56…` | **identical, both** | ✅ |
| **2 GOLDENS** | 23 PASS / 0 FAIL; `SLANG_UHDM=/bin/false` → 0/23 | **23/0 and 0/23** | ✅ |
| **3 u2r** default & testflags | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL | **679/50/2 both modes** | ✅ |
| **3 u2r dump column** | 492/187/52 default, 496/183/52 testflags | **identical** | ✅ |
| **3 row gate** | 0 differing ROWS vs `results/gate_uhdm2rtlil.csv` | **0 differing ROWS (0 sides)** | ✅ |
| **4 surelog default** | 469 EQ / 11 NOTEQUAL / 25 FAIL / 5 DEFERRED | **identical** | ✅ |
| **4 surelog testflags** | 465 EQ / 8 NOTEQUAL / 23 FAIL / 5 DEFERRED | **identical** | ✅ |
| **4 row gate** | 1588 rows, 0 differing, histograms unchanged | **0 differing ROWS, both histograms identical** | ✅ |
| **5 byte verifier surelog** | 7 / 953 | **7 / 953, and the 7 named below** | ✅ |
| **5 byte verifier u2r** | 0 / 1358 | **0 / 1358** | ✅ |
| **5 SELFCHECK / SELFCHECK1** | 952/953 & 8; 1357/1358 & 1 | **identical** | ✅ |

The patched CSVs are **byte-identical to the pristine CSVs** in both corpora
(`diff` = 0 lines) and **byte-identical to the implementer's CSVs** (`diff` = 0
lines) for surelog and u2r alike.

The 7 movers are exactly and only:

```
default/BuildUVMPkg  default/Scoreboard  default/SeqDriver  default/SimpleUVM
testflags/BuildUVMPkg  testflags/SeqDriver  testflags/SimpleUVM
```

`Scoreboard/testflags` is `SLANG_REJECT` and emits no database, so 7 is the
complete UVM population, not 7 of 8.

**The committed u2r baseline is testflags-only — VERIFIED**: 731 rows, all
`mode=testflags`. The row gate therefore ran on a testflags extract, exactly as
GATE 3 states.

---

## 2. THE HEAD — CLEARED ON ALL THREE TARGET ROWS, RE-MEASURED

`uhdm-cmp <golden> <ours>`, LHS always golden:

| row-mode | pristine | patched |
|---|---|---|
| SimpleUVM/default | **58** | **112** |
| SimpleUVM/testflags | **58** | **112** |
| Scoreboard/default | **58** | **112** |
| SeqDriver/default | 85 | **85** (unchanged) |
| BuildUVMPkg/default | 58 | **58** (unchanged) |

* **The old head object has 0 occurrences in the new cmp log** —
  `grep -c 'm_set_attribute::file'` on the patched log returns **0**.
* Diffing the pristine head's LHS and RHS blocks line by line: apart from
  serializer `id:` values the two blocks are identical except for **`|vpiSigned:1`,
  present on RHS only, printed twice**. The claim "`|vpiSigned:1` was the ENTIRE
  divergence" is exact.
* The new head is `func_call: (open_recorder) @343:13` (golden) vs
  `method_func_call: (m_do_open) @343:27` (ours), verbatim as reported. 58→112
  is head DEPTH, not distance.
* **The same head clears on the branch-head build** (`983cf4b` + patch):
  SimpleUVM/default cmp = **112 lines**, same new head, old head object absent.

---

## 3. THE GRID, RE-MEASURED WITH AN INDEPENDENT INSTRUMENT

The implementer's grid was reproduced twice: once with its own
`ct68cells.py KEY=span`, and once with **`ct68vcells.py`**, written for this
verification from the uhdm-dump format and differing from `dumptree.py` in three
deliberate ways — the key carries the FILE, "back-reference" means *no fields of
its own* rather than *no child objects*, and `io_decl` is included.

| arm | pristine (theirs / **mine**) | patched (theirs / **mine**) |
|---|---|---|
| a1_scope | 31 / EQ22 / DIFFER 9 — **31 / EQ22 / DIFFER 9** | 31 / EQ31 — **31 / EQ31** |
| a2_atom | 33 / EQ23 / DIFFER 10 — **identical** | 33 / EQ33 — **identical** |
| a3_flavour | 22 / EQ14 / DIFFER 8 — **identical** | 22 / EQ22 — **identical** |
| a4_typaram (neg. control) | 13 / DIFFER 0 — **identical** | 13 / DIFFER 0 — **identical** |
| a5_proto | 20 / EQ10 / DIFFER 9 / UNMEAS 1 — **identical** | 20 / EQ19 / UNMEAS 1 — **identical** |
| a6_tdarray (fence control) | 33 / EQ28 / DIFFER 5 — **identical** | 33 / EQ28 / **DIFFER 5** — **identical** |
| **total** | **152 / DIFFER 41** | **152 / DIFFER 5, all in a6** |

Two independent implementations agree **cell for cell, on all 152 cells, on both
binaries**. On the law's own 119 cells: **DIFFER 36 → 0**.

The a4 and a6 controls are byte-level, not tally-level: with the workdir path
normalised, **our dump for `a4_typaram` and for `a6_tdarray` is BYTE-IDENTICAL
between the pristine and the patched binary**.

The same six arms were re-run against the **branch-head** build and returned the
identical six tallies.

---

## 4. WHAT THE VERIFIER ADDED — SIX CHECKS THE PASS DID NOT HAVE

### 4.1 THE FULL PER-OBJECT SIGNEDNESS JOIN (`ct68vjoin.py`) — the strongest new result

`ct68ctrex.sh` asks only *"does any golden variable with a NAMED typespec carry
`vpiSigned`?"*. That bounds the direction the patch removes flags in, but says
nothing about the ANON population — and golden's own SimpleUVM table has **380
`int_var ANON:int_typespec signed=-`** objects, so golden omits the flag on a
large anonymous population too. If we stamped any of those, no instrument in the
pass could see it.

So every variable object in both dumps was joined on **(kind, fullname, span)**
and the full contingency table read, for **all 7 UVM databases**:

| database | pristine OVER-stamp | pristine UNDER-stamp | patched OVER | patched UNDER |
|---|---|---|---|---|
| SimpleUVM/default | **15** | **0** | **0** | **0** |
| SimpleUVM/testflags | 15 | 0 | **0** | 0 |
| Scoreboard/default | 15 | 0 | **0** | 0 |
| SeqDriver/default | 16 | 0 | **0** | 0 |
| SeqDriver/testflags | 16 | 0 | **0** | 0 |
| BuildUVMPkg/default | 15 | 0 | **1** | 0 |
| BuildUVMPkg/testflags | 15 | 0 | **1** | 0 |

Three findings this makes, none of which the pass's instruments could:

1. **The 15/16 movers were the COMPLETE over-stamp population** of each database
   across *every* variable kind — `bit_var`, `logic_var`, `array_var`,
   `struct_var`, `ref_var`, `io_decl`, all of them — not merely of the NAMED
   `int_var` bucket the census looked at.
2. **UNDER-stamp is 0 before and 0 after, everywhere.** The patch removes no flag
   golden carries. That is the risk a SUPPRESS law actually runs, and it is
   measured at zero.
3. The single surviving over-stamp is BuildUVMPkg's
   `enum_var uvm_pkg::uvm_reg_hw_reset_seq::do_block::field_check_restore
   @79885:25` — **present identically in pristine and patched**, i.e. the
   implementer's **R4**, confirmed by name, span and kind.

### 4.2 PER-SITE LIVENESS — NO DEAD SITES, NO EMPTY PRODUCT CELL IN THE CODE

The implementer's own missing-check list named *"a negative control on the gate
itself"*. A fourth build was made in which `clearNamedAtomSigned68` takes a site
id and counts, per site, how often it is **reached**, how often the gate
**passes**, and how often the pass **actually clears a flag that was true**.
The instrumented binary's emitted databases are **byte-identical to the shipped
patched binary's** on all six arms, so its counters describe the shipped code.

```
                       a1  a2  a3  a4  a5  a6   |  SimpleUVM (reached/passed/cleared)
site 1 pure virtual     .   .   .   .  1/1/1 .  |  36 / 1 / 0
site 2 DPI import       .   .   .   .  1/1/1 .  |  26 / 0 / 0
site 3 return var      11/2/2 14/7/5 9/2/2 8/1/0 12/5/5 8/0/0 | 2034 / 19 / 7
site 4 body local       8/4/4 16/8/5 8/6/5 2/1/0  1/1/1 0     | 1873 / 14 / 6
site 5 block item       4/2/2 .    2/1/1 .      3/3/3 0      | 1176 /  4 / 3
site 6 for-header       2/1/1 .    .     .      .     0      |  242 /  0 / 0
site 7 drainFuncRet     2/1/1 .    .     .      4/4/4 0      |  404 /  0 / 0
```

* **All 7 sites are reached, pass the gate, and clear a live flag in at least one
  arm.** There is **no dead site** and therefore no empty product cell on the
  code side. "STATED GATE == CODE GATE" is confirmed by grep (3 tests; 7 sites =
  TaskFuncEmit 4, StmtEmit 2, ModuleEmit 1) *and* by execution.
* **a6 is fenced structurally, not by luck**: on the array arm sites 4/5/6/7 are
  reached **zero** times and site 3 passes zero times. The element-reg path never
  calls the predicate at all.
* **a4 proves the type-parameter claim empirically**: the gate *passes* on a
  `parameter type` alias (site 3 ×1, site 4 ×1) and clears **nothing**, because
  the object is already a `ref_var` with the flag unset. The negative control is
  a real no-op, not an untested assertion.
* **a2 bounds the atom axis in code**: site 3 passes 7 (all seven named return
  functions, `time` and `int unsigned` included) and clears **5** — exactly the
  five signed atoms. The comment's claim about `time` and unsigned is executed,
  not asserted.
* On SimpleUVM only sites **3, 4, 5** do any work: 7 + 6 + 3 = **16 clears**.

### 4.3 THE oth8 / oth9 FENCE, BYTE-LEVEL, ON EVERY ARM OF BOTH PASSES

All **10** `r10oth8repro` arms and all **6** `r10oth9repro` arms were run on both
binaries. With the workdir path normalised, **our dump is BYTE-IDENTICAL,
pristine vs patched, on all 16**. `§ arrayVarSignedWritten8` and
`§ arrayElemTsSignedParented9` are untouched — measured, not promised.

### 4.4 THE PATCH ON THE CURRENT BRANCH HEAD, BUILT AND RUN

`git apply` clean on `983cf4b` (r10earl38 `§ genChainBranchScopeThreads38`),
configured, built: **0 errors**, `Built target slang_uhdm`. On that binary:
**goldens 23/0**, all six arm grids identical to the df0cdae build, and
SimpleUVM/default cmp **112 lines with the old head object absent**. There is no
semantic collision with r10earl38, only the textual one already ruled out —
earl38's `ModuleEmit.cpp` hunk is at ~26392, site 7 at ~20635.

Live passes checked directly in their worktrees: **r10sd1** edits
`include/UhdmExporter.h` + `src/UhdmExporter.cpp`, **r10earl39** edits
`src/ExprEmit.cpp` — **disjoint files**. `§ bitsOwnClassPropFold61` untouched.
Site 7 is adjacent to `§ retLocalPkgRangeBind67`'s `tfTypeScope` code (lines
~20860) — same object, different field, ~225 lines apart, no shared state.

### 4.5 MULTI-STABILITY, EIGHT DRAWS PER BINARY — AND A CORRECTION

Scoreboard/default, 3 reps + `detcheck.sh` 5 reps on each binary:

| binary | size | distinct sha256 in 8 draws |
|---|---|---|
| pristine `fc59a241…` | **11 122 522** (constant) | **3** |
| shipped `c7900a56…` | **11 122 508** (constant) | **3** |

**The shipped binary flakes exactly as much as the pristine one.** The
implementer's "shipped drew 1 distinct where pristine drew 2" was a sampling
accident, and its own README.verifier.md item 5 asked for precisely this larger
draw. The **conclusion is unaffected and correct**: same size ⇒ flake, and the
**size delta is −14 bytes, stable across all sixteen draws**, the direction a
SUPPRESS law predicts.

### 4.6 EMPTY PRODUCT CELLS — HUNTED, ONE FOUND

Every declaration in every arm source was mapped to its grid cell by hand.
a2 (23 arm cells), a3 (13), a5 (11) and a6 all account for **every** declared
case; the surplus over the arm's own declarations is the `builtin.sv` population
Surelog synthesises into each workdir, which is present and identical on both
sides. **One genuine empty product cell exists** — see F4 below.

---

## 5. EVERY OTHER REPORTED NUMBER, RE-MEASURED

| claim | verifier |
|---|---|
| golden SimpleUVM/default = 1 140 700 content lines | **1 140 700** |
| golden `int_var NAMED:int_typespec signed=-` **34**, `signed=1` **absent** | **34 / row absent** |
| golden `bit_var NAMED` 193 all `-`, `logic_var NAMED` 15 all `-` | **193 / 15** |
| ours pristine `int_var NAMED` 17 `-` + 15 `1` → patched **32 `-`, no `1` row** | **exact** |
| every other row of the variable census byte-identical pristine↔patched | **confirmed, all 35 rows** |
| counterexample hunt: **18 171** NAMED-typespec golden objects, **0** counterexamples | **18 171 / 0** |
| movers ADDED **0**, REMOVED 16 / 16 / 16 | **0 and 16 / 16 / 16** |
| removed shapes: `\|vpiSigned:1` and nothing else | **confirmed** |
| dump line delta p→q: SimpleUVM −16, Scoreboard −16, SeqDriver −18, BuildUVMPkg −17 | **−16 / −16 / −18 / −17** |
| multiset distance 143 680→143 682, 143 676→143 678, 134 013→134 013 | **exact** |
| per-depth `\|vpiSigned:1` three-way (g/p/q): d6 216/215/214, d8 141/145/143, d10 99/101/91, d16 50/53/**50** | **exact, and every other depth unchanged p→q** |
| census-predict UVM: 27 sites in 7 files (RETURN 7 / LOCAL 20 / FORVAR 0) | **exact** |
| census-predict all corpora: 73 sites in 25 files, 14 611 files scanned | **exact** |
| the other candidate dirs emit no database | SplitFile / UnitThisNew / AmiqEth / Tnoc **SLANG_REJECT**, Rsd **DEFERRED** |
| canaries.sh surelog ok=52 changed=0 absent=0 unknown=7 | **exact** |
| canaries.sh u2r-testflags ok=8 changed=0 absent=0 unknown=25 | **exact** |
| ctcan2 EXPECT_UNKNOWN=1 (sl) ok=58 PASS; =6 (u2r) ok=1 PASS | **exact, both PASS** |
| canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 | **exact, exit 0** |
| InterfaceModPort / BlackParrotComplex / SVSwitch / ApbSlave / SimpleConstraint / SeqDriver / BuildUVMPkg / SimpleUVM / Scoreboard, BY NAME, both modes | **all OK, both modes** |
| ops trap: full u2r CSV ⇒ `absent=8` and ctcan2 FAILS | **reproduced: absent=8, ctcan2 FAIL** |
| patch: EmitHelpers.h +66, TaskFuncEmit +22, StmtEmit +16, ModuleEmit +8 | **exact; 112 insertions, 0 deletions** |

### 5.1 THE REFUTATION, RE-MEASURED AND STRENGTHENED

The brief's hypothesis — *"the SIBLING int_typespec … if so ONE law may clear
both"* — is **REFUTED, and the refutation is total**. Typespec census,
SimpleUVM/default:

```
                                       GOLDEN   PRISTINE   PATCHED
int_typespec  NAMED  signed=1             64        10        10
int_typespec  NAMED  signed=-        (no row)  (no row)  (no row)
```

Golden stamps **every** named `int_typespec`, `UVM_FILE@313:9` among them, and so
do we. There is no unstamped named `int_typespec` on either side. Acting on the
brief would have deleted 10 correct flags in SimpleUVM alone. **The whole
typespec table is byte-identical pristine↔patched**: the patch touched no
typespec object anywhere.

The other two refutations also hold on re-measurement: *initialiser vs bare* has
no effect on either side (a1 `p_loc`/`p_loci`, `t_loc`/`t_loci` behave
identically), and *class property vs method local vs module var* is an axis of
OUR bug, not golden's rule — golden omits at all three (a1 `t_prop`, `t_mvar`
already EQ in the pristine grid; only the subroutine-scope cells DIFFER).

---

## 6. FINDINGS — numbered, each with its command

None of these changes the verdict. F1–F3 and F5–F9 are instrument or prose
defects that do not move a number; F4 is a real unmeasured cell.

**F1 — the multi-stability claim is a sampling accident.**
`detcheck.sh <bin> 5 <Scoreboard args>` on both binaries: the **shipped** binary
draws **3 distinct sha256 in 5 runs**, the pristine binary also 3. README.md
reports "shipped 1 distinct at 11 122 508" and item 5 of the implementer's own
verifier note asked for a bigger draw. The size is constant at 11 122 508 vs
11 122 522, so the **−14 byte delta and the flake verdict stand**; only the
"1 distinct" observation is withdrawn.

**F2 — `DIFFERKIND 0` is vacuous under `KEY=span`.**
`ct68cells.py` builds the cell key as `'%s@%s' % (n.kind, n.span)` — the **kind
is inside the key**, so a kind mismatch at one span can never produce a
`DIFFERKIND`; it produces two `UNMEASURED` cells instead. "DIFFERKIND 0 before
and after" is therefore not evidence. The substitute evidence does hold:
`UNMEASURED=0` in five arms and the odd count `1` in a5 (a kind swap would add
cells in **pairs**), confirmed by `ct68vcells.py`, whose key does not contain the
kind and which reports the same 20 cells for a5 with a single `GOLDEN_ONLY`.

**F3 — `dumptree.py` drops the FILE from the span key.**
`norm()`/the span key keep only `line:col-line:col`. Surelog synthesises
`builtin.sv` **into each arm's CWD**, so every arm dump mixes two files and a
bare span can merge a `builtin.sv` object with an arm object of the same kind.
Measured with the file-aware `ct68vcells.py`: **no collision actually occurs in
any of the six arms** (identical tallies), so no reported number is wrong — but
the grid is one span coincidence away from silently masking a cell. a1 comes
within one column of it: `int_var@18:14-18:17` is `work@mailbox::try_get` and
`int_var@18:15-18:20` is the arm's `p_blk`.

**F4 — an EMPTY PRODUCT CELL, and a residue behind it.**
`a1_scope.sv:24` declares two FORMALS and comments them `// formals`:
`task m2(int p_io, myint_t t_io);`. Formals are `io_decl` objects, and `io_decl`
is **not** in `ct68cells.py`'s `VARKINDS` — so those two source cells produce
**no cell at all**, not even `UNMEASURED`, and the arm's "DIFFER 0" says nothing
about them. Read by hand from both dumps
(`grep -n 'p_io\|t_io' g.dump o.dump`): neither side carries `vpiSigned` on
either `io_decl`, so **this pass's law is untouched** — but the `t_io` io_decl's
`vpiActual` is `int_typespec: (myint_t)` in golden and an **anonymous**
`int_typespec:` in ours. That is a pre-existing NAMED-vs-ANON divergence of the
same family as R5, previously unranked; it is ranked **V2** below.

**F5 — `mv68.sh`'s shape histogram prints delta ROWS, not line INSTANCES.**
`awk -F'\t' '$1=="REMOVED"{print $3}' | sort | uniq -c` ignores the count field
`$2`, so the table printed `1` four times where 1, 2, 10 and 3 instances moved.
The instance total printed above it (`REMOVED line instances=16`) is correct, and
README.md's prose ("`|vpiSigned:1` at 4 depths, and NOTHING ELSE") is accurate —
but the table invites a wrong reading.

**F6 — `mv68.sh`'s THREE-WAY COUNT block iterates ADDED lines only.**
For a REMOVE-only law `ADDED == 0`, so the section prints **empty**. The
per-depth three-way table in README.md §4.1 was therefore produced by hand, not
by the instrument it sits beneath. Independently re-measured
(`grep -F '|vpiSigned:1' | awk '{match($0,/[^ ]/); print RSTART-1}' | uniq -c`):
**every figure in that table is exact.** The instrument, not the number, is the
defect.

**F7 — file-count bookkeeping.** README.md §7 says "27 files … 6 arms, 13
drivers". `git diff --name-only df0cdae | wc -l` = **28** = 4 production + 24
probe (6 arms, **16** drivers, 2 READMEs). Prose only; the delivered patch is
complete and applies clean.

**F8 — one candidate name is not reconciled.** README.md §3 lists
`Verilator/t_package` among the tests that could move; there is **no test row of
that name** in either corpus CSV. Harmless — 0 movers were measured there — but
the candidate list was not joined against the CSVs.

**F9 — the objects-vs-lines mechanism is stated wrongly.** README.md explains
SimpleUVM's "15 objects / 16 lines" as *one object printed fully in more than one
view*. The site counters (§4.2) record **16 distinct CLEAR operations** — a
second clear on the same C++ object would find the flag already false and not be
counted — so there are **16 distinct UHDM objects**, and the 15 is a **census-key
merge**: `ct68census.py` keys on `(kind, fullname, span)` and two distinct objects
share that key. Both readings yield 16 moved lines; no number changes, but the
mechanism named is not the one operating.

---

## 7. THE IMPLEMENTER'S OWN DISCLOSURE, PRESERVED

The implementer shipped a `README.verifier.md` that opened
"**NO INDEPENDENT ADVERSARIAL VERIFIER RAN**", tabulated what each of its own
checks could and could not catch, and listed five missing adversarial checks —
closing two of them before landing and recording that closing one is how **R0**
was found. That disclosure was accurate and is the reason this verification knew
where to aim. Its five items now stand as:

1. *Independent re-derivation of the golden rule* — **CLOSED** by §4.1: a
   different author's instrument, joining **all** variable kinds rather than the
   NAMED subset, over all 7 UVM databases. 0 under-stamps, over-stamps exactly
   the movers plus R4.
2. *Over-fire hunt on the six element-reg call sites* — **CLOSED** by §4.2
   (sites 4–7 reached **zero** times on a6) and §4.3 (all 16 oth8/oth9 arms
   byte-identical). The verifier was asked to widen a6 and decide whether R0
   belongs here or to r10oth8/9 — see **V1**.
3. *A negative control on the gate itself* — **CLOSED** by §4.2's per-site
   reached/passed/cleared counters, which are a stronger control than a
   deliberately-ungated build: they show not only that each site fires but that
   each site's gate **rejects** the cases it is supposed to reject (a4 passes and
   clears nothing; a2 passes 7 and clears 5).
4. *`git apply --check` against the current head* — **CLOSED and extended**:
   applied, **built**, goldens run and arms re-measured on `983cf4b` (§4.4).
5. *A second draw of multi-stability* — **CLOSED**, and it **corrected the
   claim**: see **F1**.

---

## 8. RANKED RESIDUES (verifier's ranking)

* **V1 = the implementer's R0 — COLLISION NOTICE, and I agree it was right to
  leave it.** The ELEMENT `vpiReg` of a typedef'd-atom ARRAY at SUBROUTINE /
  BLOCK scope: golden `-`, ours `vpiSigned:1`. Re-measured cell for cell — a6
  cells `18:11 l_fix`, `19:11 l_dyn`, `20:11 l_que`, `21:11 l_asc` (function
  locals, all four array kinds) and `39:11 b_fix` (block item), **5 cells,
  unchanged by the patch**. It is the same "as written" law one carrier over,
  and the brief fences array-var signedness to `§ arrayVarSignedWritten8` /
  `§ arrayElemTsSignedParented9`. Taking it would have been a cross-fence edit;
  §4.3 shows the fence is currently exact to the byte on all 16 of those passes'
  arms, which is what makes the boundary meaningful. It is the **highest-value
  next item**: the predicate `clearNamedAtomSigned68` is already correct for it,
  the six element-reg callers are located in README.md §6, and r10oth8 measured
  the element reg at CLASS/MODULE scope only — so subroutine scope is genuinely
  unmeasured there, not decided against.
* **V2 — NAMED-vs-ANON typespec residue, now with the formals cell added
  (F4 + the implementer's R1/R5).** Golden mints one named `int_typespec` per
  reference site (64 on SimpleUVM) where we share one (10); our subroutine-scope
  typespecs are ANON where golden's are NAMED; and **the same divergence exists
  on `io_decl` formals**, which no instrument in this pass looks at. The
  aggregate on SimpleUVM/default: `int_typespec ANON signed=1` golden 543 vs ours
  **681**, `ANON signed=-` golden 168 vs ours **137**, `NAMED signed=1` golden 64
  vs ours **10**. This is what makes the multiset distance rise by 2 while the
  head clears, and it is a **larger population than anything this pass moved**.
* **V3 = R4, promoted.** The BuildUVMPkg `enum_var
  uvm_pkg::uvm_reg_hw_reset_seq::do_block::field_check_restore @79885:25` carries
  `vpiSigned:1` where golden has none, in **both** modes, identically before and
  after. It is **this pass's own law on a third variable class** — golden's
  `enum_var NAMED` population is 126/126 unstamped — and gate test (3)
  (`getCanonicalType().kind != PredefinedIntegerType`) deliberately does not
  reach it because `EnumType` is not a `PredefinedIntegerType`. After §4.1, it is
  the **only remaining over-stamped variable object in any of the seven UVM
  databases**. Widening the gate needs its own arm (golden's ANON `enum_var`
  behaviour is unmeasured), which is why leaving it is defensible — but it is now
  a single, named, fully-located object.
* **V4 = R2/R3.** Objects golden emits and we do not: 2–3 NAMED `int_var` per
  database (34/32, 35/33, 34/31 — ours all correctly `-`), and the in-class
  `extern` PROTOTYPE variable (a5 `int_var@19:19 work@V5::ex_ret`, the single
  `GOLDEN_ONLY` cell). Confirmed present.
* **V5 = R5 naming residues**, confirmed verbatim: our DPI return var is
  `work@m5_mod.dpi_ret` where golden names it `work@m5_mod.dpi_ret.q_t`, and our
  out-of-body extern is `work@V5::ex_ret` where golden writes `V5::ex_ret`.
  `KEY=span` exists so these cannot hide a cell, and they did not.
* **V6 = R6, the next head**, confirmed verbatim on all three rows at 112 lines:
  golden `func_call (open_recorder)@343:13` vs ours
  `method_func_call (m_do_open)@343:27` (`uvm_tr_stream.svh:343`) — pre-existing,
  unmasked, in `§ parensLessCallIsPathRefObj`'s family.
* **V7 — instrument debt** (F2, F3, F5, F6). None moves a number in this pass;
  all four are inherited by whoever reuses these drivers. F3 is the one that can
  actually silence a cell in a future arm.

---

## 9. OPS FACTS

* Verifier worktrees **KEPT** with their builds: `/tmp/wt_r10uvm68v` (patched,
  `df0cdae`) and `/tmp/wt_r10uvm68vpris` (pristine, `df0cdae`). The head-build and
  instrumentation worktrees were removed after use.
* Sweep CSVs and logs KEPT: `/tmp/r10uvm68v_{u2r,sl}_{pat,pris}.csv|.log` and the
  testflags extract `/tmp/r10uvm68v_u2r_pat_tf.csv`. cmp logs
  `/tmp/r68v_cmp_{pris,pat}_<test>_<mode>.log`. Build logs
  `/tmp/r10uvm68v_build_{pat,pris}.log`, `/tmp/r68v_build_{site,head}.log`.
* The four verifier sweep **WORKDIRS (882 MB) were DELETED** per the standing ops
  rule, together with all arm and dump scratch. Regenerate with
  `SLANG_UHDM=<bin> python3 scripts/verify_golden.py --corpus <c> --mode both
  --jobs 2 --out <own.csv> --workdir <own dir>` per binary, then
  `SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh <pat> <pris>`. `GOLDEN_DEFER` stays
  UNSET (5 DEFERRED in both surelog modes).
* **Do NOT use `/home/heyfey/git-repos/slang-uhdm/build/slang-uhdm` as a control**
  — the implementer's ops note is correct; that binary was not built from a clean
  base commit. Every control here is `/tmp/wt_r10uvm68vpris`'s own
  `fc59a2414877316104c88c8c1fe43b77`.
* Two instruments were added to this directory by the verifier and are part of
  the delivered patch: **`ct68vcells.py`** (file-aware, kind-free-key arm grid)
  and **`ct68vjoin.py`** (full per-object signedness join, all variable kinds).
  Both are self-documenting and take `<golden.dump> <ours.dump>`.
* Delivered: **`/tmp/r10uvm68.verified.patch`** — the implementer's patch plus the
  two verifier instruments and this document. The production diff is **byte-for-
  byte the implementer's**; nothing in `src/` was changed.
