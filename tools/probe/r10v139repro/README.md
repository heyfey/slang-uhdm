# r10v139 — ADVERSARIAL VERIFICATION of r10uvm139
## § `tfItemLocalAutomaticIsNotWrittenStatic139`

**VERDICT: ACCEPT AS SHIPPED.**  `/tmp/r10uvm139.patch`
(md5 `c73ba2cd32a076b83870922052fece3f`) applies clean (`git apply --check`
rc 0) on a FRESH `c3e9fee`; surface is `src/TaskFuncEmit.cpp` + 32 files under
`tools/probe/r10uvm139repro/` and nothing else; `results/*.csv` untouched;
no fenced test name appears anywhere in the patch.  Every headline number was
reproduced bit-for-bit on this verifier's OWN build, and no
pristine-right → patched-wrong cell was found on any legal-SV face.

Binaries built here, `-j 2`, from two fresh worktrees at `c3e9fee`:
pristine `b4420701b56878cf3a90a2b541785800`, patched
`d70a9f1ad4e32c068c182e28596562bb` — the patched md5 the implementer reported,
independently reproduced.  Both frozen `chmod 555` before any sweep.

---

## 1. The model, re-read at the source

Confirmed line by line in `~/git-repos/Surelog/src/DesignCompile/CompileStmt.cpp`:

* **TF-ITEM** (`compileTfPortDecl`, the `paBlock_item_declaration` arm):
  `bool is_static = false;` set true ONLY at `paLifetime_Static`, left false at
  `paLifetime_Automatic` and at no lifetime node, then
  `var->VpiAutomatic(!is_static);` for every `Variable_decl_assignment`.
  No initialiser test, no type test, no subroutine-lifetime test.
* **BLOCK-ITEM** (`compileDataDeclaration`): `automatic_status = false`, set
  true only at `paLifetime_Automatic`, and explicitly set back to false at
  `paLifetime_Static`; written with `var->VpiAutomatic(automatic_status)`.

The two productions really do carry opposite defaults, and the patch changes
only the first.

**The rewrite is behaviourally exactly the claimed table.**  Pristine's
`if (!hasInit && !blockLocal && !blockItems9) … else if (<automatic written>)`
and patched's `if (!blockLocal && !blockItems9) { if (life != Static) … } else
if (life == Automatic)` differ on exactly two tf-item faces: `static`+no-init
(1 → 0) and no-keyword+init (0 → 1).  The `else` arm is § `r10fsv3` unchanged
apart from an added `kind == Declarator` guard, which is inert (a slang
variable's syntax under a `DataDeclarationSyntax` is always its `Declarator`) —
and measured inert on every block-face cell of all eight arms below.

---

## 2. Gates, re-run here (own pinned build, own workdirs)

| gate | result |
|---|---|
| goldens, `SLANG_UHDM` exported per binary | patched **23 PASS / 0 FAIL**, pristine **23 / 0**, `/bin/false` **0 PASS / 23 FAIL** |
| uhdm2rtlil testflags AND default, both binaries | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in all four sweeps |
| `ct8rows` u2r vs committed baseline, and patched vs pristine, both modes | **0 differing rows** (status AND dump column) |
| surelog `--mode both`, 1588 rows, both binaries | **937 / 567 / 48 / 19 CMP_NOTEQUAL / 10 / 3 / 2 / 1 / 1** — identical pristine and patched |
| `ct8rows` surelog vs committed baseline and vs pristine | **0 differing rows over 1588**; **no row converted**; `results/*.csv` untouched |
| `byteverify SELFCHECK=1` u2r | **MOVERS 0 / 1358**, SELFCHECK 1357/1358 |
| `byteverify SELFCHECK=1` surelog | **MOVERS 9 / 956**, SELFCHECK 955/956 — precisely the nine rows `PREDICTION.txt` names |
| canaries | surelog `ok=52 changed=0`, u2r `ok=8 changed=0`; `ctcan2` PASS both; `canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs, md5 patched vs pristine, both modes | InterfaceModPort / BlackParrotComplex / YosysOldOr **SAME**; SVSwitch `4842211c4030`; YosysVerx `6ccda350c24a` |

**`cmds.txt` audit BY BINARY PATH**, all four sweeps, file by file: surelog
1573 files — **1523 name the frozen binary, 50 name none**; uhdm2rtlil 1462 —
**1458 name it, 4 name none**; **0 name the main-tree binary and 0 name either
worktree's `build/slang-uhdm`**, in either corpus, in either sweep.

### Heads (`rowheads.sh`, this verifier's own sweeps)

| row | pristine | patched |
|---|---|---|
| SeqDriver default / testflags | 58 / 58, one `^LHS:` | **26 / 26**, one `^LHS:` |
| MiniAmiq default / testflags | 58 / 58, one `^LHS:` | **26 / 26**, one `^LHS:` |
| SimpleUVM ×2, Scoreboard/default, BuildUVMPkg ×2 | 32 | 32 |
| Earlgrey_0_1 ×2 | 17 | 17 |
| Rggen/default | 0 | 0 |

All eight committed `head_{pris,pat}_{default,testflags}_{SeqDriver,MiniAmiq}.cmp`
artifacts reproduce **byte-identically** here.  The pristine head's only
differing line is `|vpiAutomatic:1` on `string_var values`; the patched head is
the nameless, uninstanced `class_typespec 'uvm_cmdline_processor'` at
`uvm_component.svh:3383` (R0), as reported.

---

## 3. Attribution, measured independently

**Census** (`ct139cen` + `score139.py`, key `SCOPE|VNAME`, built and run here
over golden / pristine / patched for all nine mover databases):

| row | modes | AUTO cells | W→R | W→W | **R→W** | AWAY |
|---|---|---|---|---|---|---|
| SeqDriver | def+tf | 17184 ×2 | 12 ×2 | 0 | **0** | 0 |
| SimpleUVM | def+tf | 9459 ×2 | 6 ×2 | 0 | **0** | 0 |
| Scoreboard | def | 9480 | 6 | 0 | **0** | 0 |
| MiniAmiq | def+tf | 18073 ×2 | 12 ×2 | 0 | **0** | 0 |
| BuildUVMPkg | def+tf | 9519 ×2 | 10 ×2 | 0 | **0** | 0 |
| **total** | | **117 950** | **86** | **0** | **0** | **0** |

Golden-vs-golden calibrates `RIGHT->RIGHT` only on all five rows.  `WRONG→WRONG`
is 0 in the AUTO column of every database: after the pass every *paired*
variable in every UVM database agrees with golden on `vpiAutomatic`.  The
`VKIND` / `VTS` residues (149/184, 3/2, 3/2, 168/222, 3/4) and the one-sided
sets (ONLY-GOLDEN 2663/35/17/2621/49, ONLY-OURS 969/4/4/969/6) are byte-for-byte
what pristine had.  The moved cells are named `values`, `clp`, `initialized`,
`uvm_cmdline_proc` and nothing else.

**Order-blind whole-dump attribution** (id- and workdir-normalised, `LC_ALL=C
sort`ed — the only sound reading for the coin rows), all nine movers:
the ONLY changed dump lines are `|vpiAutomatic:1`, net
−4 / −4 / +2 / −2 / −2 (SeqDriver, MiniAmiq, BuildUVMPkg, SimpleUVM,
Scoreboard) in **both** modes.  Nothing else in any database changed.

**Source sites**, read in `uvm-1.2/src/base/uvm_component.svh`:
`3380 static string values[$]`, `3383 uvm_cmdline_processor clp = …`,
`3539 static bit initialized`, all inside the paren-less out-of-body
`function void uvm_component::m_set_cl_verb` / `m_set_cl_sev`; 1800.2's
pp_output adds `m_set_cl_action`/`m_set_cl_sev`'s `uvm_cmdline_proc`.  The
neighbouring `3381 static bit first = 1` and `3467 static bit initialized = 0`
are static+init and correctly stay 0 on both binaries.

---

## 4. Breaking the law — 8 independent arms, 1144 AUTO cells

Written from scratch here with names, orders, case and numbering deliberately
unlike the implementer's grid (`Quarrel139`, `Sundry139`, `Winch139`,
`Gasket139`, `Sluicebox139`, `Halyard139`, `Quiver139`, `Wicket139`).  Golden =
Surelog `-nobuiltin`, LHS always golden; both views; every rc recorded; file
list on fd 3; children `</dev/null`; `PROCESSED` asserted.

| arm | what it varies | AUTO cells (def/elab) | W→R | **R→W** | **AWAY** |
|---|---|---|---|---|---|
| `v139_a_kinds` | 11 declaration kinds (int, string, string queue, dynamic array, associative array, fixed array, class handle, packed struct, unpacked struct, real, enum) × none/`static`/`automatic` × ±initialiser, TF-ITEM **and** BLOCK twins | 151 / 330 | 40 / 58 | **0** | **0** |
| `v139_b_homes` | 22 HOMES: in-body class method (both header shapes), class task, class task with body io, out-of-body function AND task, `static function` class method, package free function/task/task-with-io, `function static`/`function automatic` package functions, interface task+function, program task+function, module function/task/task-without-io, `$unit` function and task | 88 / 128 | 21 / 23 | **0** | **0** |
| `v139_c_blocks` | block locals in `begin` (inside a TF-ITEM **and** a BLOCK subroutine), `fork…join_none`, `for`-body, `initial`, `always`; formal arguments (`input`/`ref`/`output`, `function automatic`, task formals) | 29 / 51 | 2 / 3 | **0** | **0** |
| `v139_d_shapes` | multi-declarator lists (`static int n1,n2,n3`), multi+init, lifetimes in reverse order, mixed case, the same local name in two subroutines, io-then-decl task | 24 / 28 | 9 / 9 | **0** | **0** |
| `v139_e_inst` | 1, 2 and 3 instances of a parameterised module + a package class used from each | 11 / 39 | 4 / 10 | **0** | **0** |
| `v139_f_carve` | the `blockLocal` carve-out face (named typedef + enum array in a MODULE subroutine) | 8 / 17 | 1 / 2 | **0** | **0** |
| `v139_g_edge` | `const` / `var` modifiers, virtual and pure-virtual methods, a static class method, a parameterised class with two specializations, a nested class, a one-`begin` body, a value-returning paren-less function | 30 / 54 | 10 / 18 | **0** | **0** |
| `v139_h_odd` | `const static`, `var static`, `const automatic`; chandle, event, virtual-interface handle, enum ARRAY and named-typedef locals in a PACKAGE tf-item; a generate-block function | 49 / 107 | 16 / 31 | **0** | **0** |
| **total** | | **1144** | **257** | **0** | **0** |

`RIGHT->WRONG` and `AWAY` are **0 in EVERY COLUMN** (`AUTO`, `VKIND`, `VTS`,
`VCONST`, `PATH`, `VFULL`, `VSPAN`) of **every one of the 16 arm-views**.
`ONLY-GOLDEN` and `ONLY-OURS` are identical in pristine and patched everywhere.

The law reads exactly as claimed on golden, cell for cell.  Arm A, the eleven
kinds under one paren-less package function:

```
plainStat139 (static, no init)   golden 0×11   pristine 1×11 (WRONG)   patched 0×11
plainInit139 (no kw, init)       golden 1×9    pristine 0×9  (WRONG)   patched 1×9
plainNone139 / plainAuto139      golden 1      pristine 1              patched 1
statInit139  / autoInit139       golden 0 / 1  pristine 0 / 1          patched 0 / 1
blkNone/blkStat/blkInit (BLOCK)  golden 0/0/(0,1,0)  unchanged on both binaries
```

Arm B, every home, `none / static / automatic` written on the local: the
patched column equals the golden column in **all 21 homes golden emits**, and
golden's answer is the PRODUCTION, never the home and never the subroutine's
own lifetime — `static function void` (class) and `function static void`
(package) both read `1 / 0 / 1`, exactly like `function automatic void`.

---

## 5. Boundary — 3999 files × 2 views, md5-first

`boundv139.sh` compiles every `.sv`/`.svh` under the WHOLE of
`tools/probe` (3993 committed + this dir's 6 arms) with both frozen binaries in
both views to the SAME `-o` path, keyed on the RELATIVE path, and compares
md5-first:

```
LISTED=3999 PROCESSED=3999 MOVED=26 NORUN=306 RC-MISMATCH=0
PROCESSED-ASSERT-OK
```

The 26 moved file-views are 10 from `r10uvm139repro`'s own arms, 12 from this
dir's own arms, and **4 foreign**: `r10uvm66repro/a2_slots.sv` and
`a3_count.sv`, both views.  Re-measured against GOLDEN they move toward it and
nowhere else — `a2_slots` W→R 1 / 2, `a3_count` W→R 4 / 8, **R→W 0** in every
column — and their whole-dump diffs contain **only** `|vpiAutomatic:1` lines.
`RC-MISMATCH=0`: the two binaries never disagree about running, segfaulting
files included.

**Must-stay controls, byte-identical on both binaries in both views** (checked
directly, ahead of the wide run): `r10uvm137repro` (10 file-views),
`r10v137repro` (12), `r10uvm134repro` (10), `r10uvm126repro` (8),
`r10buvm34repro` (6), `r10buvm33repro` (6), `r10uvm113repro` (8),
`r10uvm122repro` (12), `r10uvm131repro` (10) — **0 moved**.

---

## 6. Residues confirmed, and two the pass did not name

* **R0** confirmed and reproduced: `class_typespec 'uvm_cmdline_processor'`,
  `uvm_component.svh:3383`, golden carries `vpiName` + `vpiInstance -> package
  uvm_pkg`, ours neither.  26 cmp lines, one `^LHS:`, MiniAmiq ×2 + SeqDriver ×2.
* **R1** confirmed with independent names: `v139_f_carve` (`ca`, `cb`, `da`,
  `db`) and `v139_h_odd` `modTd139` (`ka`, `kc`) read golden 1 / ours 0 on BOTH
  binaries — a named-typedef or enum-array local in a NON-package subroutine.
  `v139_h_odd`'s `exotic139` proves the complement: the same declarations in a
  PACKAGE subroutine are NOT carved out and do take the rule.
* **R3** confirmed and extended: `const` / `var` tf-item locals are objects
  golden never emits.  `const static` and `var static` (arm H `hc`, `hd`) are
  also golden-absent, so the patch's payload change on them (`hd` 1 → 0) can
  never be a judge-visible regression.  Corpus incidence zero.
* **V-R1 (new, pre-existing, not this pass's).**  On the BLOCK face with
  `automatic` written, golden gives the unpacked-array local's ELEMENT variable
  `vpiAutomatic:1` while giving the `array_var` itself 0; we give both 0.
  Measured on `v139_a_kinds` `blkAuto139` `sc` (2 def + 8 elab cells,
  `WRONG->WRONG` on both binaries).  A § `r10fsv3`-family residue.
* **V-R2 (documentation nit).**  The pass README says the patched head's cmp
  log is "byte-identical" in both modes on both rows.  It is for MiniAmiq;
  SeqDriver's two modes differ in four lines — object `id:` numbers only
  (`18780`/`13472` vs `18792`/`13484`).  The head object, its fields and the
  line count are the same.  No measurement depends on this.

---

## 7. Files here

`armsv139.sh` (arm driver), `boundv139.sh` (wide boundary), and the eight arms
`v139_{a_kinds,b_homes,c_blocks,d_shapes,e_inst,f_carve,g_edge,h_odd}.sv`.
The census and scorer are the pass's own `../r10uvm139repro/{ct139cen.cpp,
score139.py}`, rebuilt and re-run here.  MEASUREMENT ONLY — the official
`uhdm-cmp` stayed the sole acceptance judge for every gate above.
