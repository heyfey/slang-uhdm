# r10uvm80 — § blockDeclAutomaticIsWrittenKw80

**BASE 4f9b233.** Production surface: `src/StmtEmit.cpp` **only** (one new
file-static predicate + four one-line call sites). Probe surface:
`tools/probe/r10uvm80repro/` only.

**Result, up front: the 62-line head shared by SimpleUVM/default,
SimpleUVM/testflags and Scoreboard/default is CLEARED on ALL THREE ROWS.**
The head was ONE object with ONE property — `int_var k` at
`uvm_sequencer_base.svh:919:35`, golden `|vpiAutomatic:1|`, ours absent, every
other line byte-equal — and it is gone from all three cmps.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table below and every script here.

---

## 1. THE HEAD, and what it was

`rowheads.sh` on the BASE databases, before anything moved:

| row | cmp lines | heads |
|---|---|---|
| SimpleUVM/default | 62 | 1 |
| SimpleUVM/testflags | 62 | 1 |
| Scoreboard/default | 62 | 1 |

All three cmps are the SAME 62 lines with the ids stripped
(`md5 cef0e3d975011a8b37084d79359ac93a`), and the whole of the difference is one
line:

```
LHS (golden)                                   RHS (ours)
int_var: (…::m_wait_for_available_sequence::k) int_var: (…::k)
|vpiName:k                                     |vpiName:k
|vpiFullName:…::k                              |vpiFullName:…::k
|vpiSigned:1                                   |vpiSigned:1
|vpiAutomatic:1                                        <-- MISSING
```

The source is `uvm-1.2/src/seq/uvm_sequencer_base.svh:919`, inside a
`fork … join_none` inside a `for` inside a `fork` inside `m_wait_for_available_sequence`:

```systemverilog
                for(i = 0; i < is_relevant_entries.size(); i++) begin
                fork
                    automatic int k = i;
```

---

## 2. THE MECHANISM: Surelog has THREE vpiAutomatic sites, and they disagree

Read out of Surelog's source, then confirmed on the artifact (§3).

| site | who | rule |
|---|---|---|
| `CompileStmt.cpp:1196` (`compileDataDeclaration`, the **statement** overload) | every `data_declaration` **statement** — a `begin`, a named `begin`, a `fork` arm, an `initial`/`always` body, a loop body | `VpiAutomatic(automatic_status)`, where `automatic_status` starts **false**, becomes true ONLY at a `paLifetime_Automatic` node and false at `paLifetime_Static`. **There is no scope default anywhere on this path.** |
| `CompileStmt.cpp:1690` (`compileTfPortList`'s `block_item_declaration` arm) | a subroutine's **tf item** declarations | `VpiAutomatic(!is_static)` — automatic **unless** `static` is written |
| `ElaborationStep.cpp:2350` (`makeVar_`) | module / package / class **Signals** | `VpiAutomatic(!sig->isStatic())`, and `isStatic` comes from which grammar rule matched |

This campaign already transcribes the second (§ r10fsv3, `TaskFuncEmit.cpp`) and
the third (§ packageVarAutomaticIsDataDeclShape26, `ParamEmit.cpp`). **The first
was never transcribed at all**: `src/StmtEmit.cpp`'s block-local loop contained
no `VpiAutomatic` of any kind, so every block-scope declaration came out 0.

---

## 3. THE LAW

```
§ blockDeclAutomaticIsWrittenKw80    src/StmtEmit.cpp, one predicate, four call sites
```

> A **BLOCK-SCOPE (statement) variable declaration** carries `vpiAutomatic` **iff
> the `automatic` KEYWORD is WRITTEN on that data declaration**. The flag is
> stamped on the **DECLARED VARIABLE** — and for an unpacked-array / queue /
> dynamic / associative declaration that is the **ELEMENT variable**, never the
> `array_var` wrapper.

Corollaries, each MEASURED (not derived):

* **Position-independent.** A `fork` arm, a `begin`, a NAMED `begin`, a module
  `initial`, an `always` body, a module task's `begin` and a for-loop body's
  `begin` all read 1 with the keyword and 0 without.
* **Initializer-independent.** `automatic int e;` with no initializer reads 1.
* **The enclosing subroutine's lifetime does NOT propagate.** A body local of a
  `function automatic` reads **0**.
* **`static` reads the same as nothing** — 0.
* **Multi-declarator**: `automatic int a = 1, b = 2;` reads 1 on BOTH, because
  the keyword lives on the declaration the declarators share.
* A `for (int i = 0; …)` **init variable** reads 0.

### The grid — arm `c1_autolife.sv`, 23 cells, golden vs BASE vs PATCHED

`ct80arm.sh` runs golden and both binaries in ONE scratch dir (so uhdm-dump's
absolute paths for Surelog's synthesized `builtin.sv` are identical across the
three reads — a cross-workdir dump diff prints path noise as content).

| cell | position | keyword | golden | base | patched |
|---|---|---|---|---|---|
| c1 `a_fkauto` | fork arm, init | `automatic` | **1** | 0 | **1** |
| c2 `a_fkplain` | fork arm, init | — | 0 | 0 | 0 |
| c3 `b_bgauto` | begin (class task) | `automatic` | **1** | 0 | **1** |
| c4 `c_bgplain` | begin | — | 0 | 0 | 0 |
| c5 `d_bgstat` | begin | `static` | 0 | 0 | 0 |
| c6 `e_bgnoinit` | begin, NO init | `automatic` | **1** | 0 | **1** |
| c7 `f_bgplainni` | begin, NO init | — | 0 | 0 | 0 |
| c8 `g_inautofn` | begin inside `function automatic` | — | **0** | 0 | 0 |
| c9 `h_tfitem` | tf item | — | 0 | 0 | 0 |
| c10 `k_tfstat` | tf item | `static` | 0 | 0 | 0 |
| c11 `l_tfauto` | tf item | `automatic` | 1 | **1** | 1 |
| c12 `n_nbauto` | NAMED begin | `automatic` | **1** | 0 | **1** |
| c13 `o_nbplain` | NAMED begin | — | 0 | 0 | 0 |
| c14 `p_iniauto` | module `initial` | `automatic` | **1** | 0 | **1** |
| c15 `q_iniplain` | module `initial` | — | 0 | 0 | 0 |
| c16 `r_inistat` | module `initial` | `static` | 0 | 0 | 0 |
| c17 `s_alwauto` | `always` body | `automatic` | **1** | 0 | **1** |
| c18 `t_alwplain` | `always` body | — | 0 | 0 | 0 |
| c19 `u_mtauto` | module task's begin | `automatic` | **1** | 0 | **1** |
| c20 `v_mtplain` | module task's begin | — | 0 | 0 | 0 |
| c21 `w_forinit` | `for (int w = 0; …)` init var | — | 0 | 0 | 0 |
| c22 `x_fbauto` | for-body begin | `automatic` | **1** | 0 | **1** |
| c23 `y_fbplain` | for-body begin | — | 0 | 0 | 0 |

Cell c11 is the CONTROL for the OTHER law: § r10fsv3 already stamps a tf item's
written keyword, and this pass leaves it exactly where it was. Cell c1 is the
corpus head verbatim; **c1's cmp head in the arm is the same object as the
corpus head's**, and it is gone in the patched column.

### WHICH OBJECT — arm `c2_autokinds.sv`

The declaration kinds our block loop has separate factories for, all written
`automatic`. Golden, then ours after the fix (identical):

| declaration | golden stamps |
|---|---|
| `automatic int a_scal = 1;` | the `int_var` |
| `automatic logic [3:0] b_vec = 4'h5;` | the `logic_var` |
| `automatic int c_fix [3];` | the **element** `int_var` (parent `array_var`) — the `array_var` itself reads **0** |
| `automatic int d_que [$];` | the **element** |
| `automatic int e_dyn [];` | the **element** |
| `automatic int f_asc [string];` | the **element** |
| `automatic string g_str = "x";` | the `string_var` |
| `automatic k80 h_cls = new();` | the `class_var` |
| `automatic e80_t i_enum = E0;` | the `enum_var` |
| `automatic s80_t j_str2;` | the `struct_var` |
| `automatic int k_m1 = 1, k_m2 = 2;` | **both** declarators |
| `static int l_stat [3];` | nothing (control) |
| `int m_plainq [$];` | nothing (control) |

The array rows are the reason the patch stamps `qr` / `ar` / `reg0` and not the
array wrapper, and Surelog's code says the same thing: `CompileStmt.cpp:1196`
writes the flag on `compileVariable`'s result, and the `array_var` wrapper is
minted AFTERWARDS and never stamped.

**Arm c2 went from CMP_FAIL to PASS_CMP.**

### STATED GATE == CODE GATE

| prose | code |
|---|---|
| ONE predicate | `bool writtenAutomaticKw80(` x1 |
| reads the WRITTEN keyword | `TokenKind::AutomaticKeyword` x1, inside it |
| on the DATA DECLARATION | `SyntaxKind::DataDeclaration` x1 |
| reached through the DECLARATOR's parent | `SyntaxKind::Declarator` x1 |
| slang's semantic lifetime is NOT read | `VariableLifetime` x**0** in the predicate |
| computed ONCE per declaration | `auto80 = writtenAutomaticKw80(` x1 |
| read at FOUR factories | `if (auto80)` x4 |
| every stamp in the loop is GATED | ungated `VpiAutomatic(true)` in the loop x**0** |

`ct80gate.py <src/StmtEmit.cpp>` asserts every row, reading CODE (comments are
stripped first — a guard that greps its own write-up is this campaign's oldest
trap). Real negative control:

```
patched   src/StmtEmit.cpp  -> 9/9 PASS, exit 0
pristine  src/StmtEmit.cpp  -> 2/9 PASS, exit 5, all seven failing rows named
```

An audit that cannot find the block-local loop exits 4 rather than reporting
success.

---

## 4. THE CENSUS — an EXACT prediction, made before the patched sweep existed

`r10uvm80cen.cpp` opens a `.uhdm` with UHDM's own `Serializer` and walks
`Serializer::AllObjects()`. Three reasons that beats grepping `uhdm-dump`: it
sees objects a dump cannot (a dump prints what some parent points at); it reads
the FIELD, not a rendering; and it counts each object ONCE (a dump reprints an
object at every reference, so a shape census over dump text multiplies). It
prints a `TOTALS` line **always**, including on `RESTORE_FAIL`.

`ct80cen.sh` runs it over a WHOLE verify_golden workdir, GOLDEN and OURS, and
joins them per database into two populations:

* **MISS** — golden `vpiAutomatic=1`, ours 0.
* **OVER** — ours 1, golden 0.

### CALIBRATION FIRST, and it caught a broken instrument

Golden-vs-golden through the real driver: `gvars=9464 ovars=9464 gauto=970
oauto=970 MISS=0 OVER=0`.

The FIRST key included the file BASENAME and it read
`MISS=970 OVER=953` on that same golden-vs-ours pair — i.e. it flagged
**every** automatic variable on both sides. **Our side leaves `vpiFile` EMPTY on
every class-member variable**, so a file-bearing key joined nothing. A detector
that flags everything is a broken detector; the key is now
`(line:col, kind, fullname)` and the calibration is what caught it. The join is
also a **multiset**, not a set: 2 346 of SimpleUVM's 9 464 variable objects share
a key with another object, and a set-valued join would mask a per-object
regression inside a key.

### The BASE disagreement inventory (surelog corpus, both modes, 953 databases)

`MISS` 108 rows, `OVER` 40 rows, spread over 58 databases. **Only 16 of those
rows belong to this law.** Every skipped directory was checked: of the 620
SKIP-NOFILE dirs, **570 are golden-only (we emit no database at all) and 50 are
neither** — `ours-only(no golden)=0`. So the census covers 100 % of our surelog
databases and the prediction below is complete, not a sample.

The 16 rows are the only two block-scope `automatic` declarations UVM 1.2 has
that the corpus reaches (`grep -rE '^\s*automatic\s'` over `uvm-1.2/src` returns
exactly three sites; the third is inside an un-instantiated macro in
`uvm_tlm_imps.svh`):

| object | source | rows |
|---|---|---|
| `…uvm_sequencer_base::m_wait_for_available_sequence::k` | `uvm_sequencer_base.svh:919` `automatic int k = i;` | 7 |
| `…uvm_objection::m_execute_scheduled_forks::guard::objection` | `uvm_objection.svh:703` `automatic uvm_objection objection = c.objection;` (a NAMED fork `guard`) | 7 |
| the same two in SeqDriver's second UVM copy (`adpcm_pkg`) | | 2 |

### THE PREDICTION (written before the patched binary swept anything)

**7 databases move; 29 objects gain `vpiAutomatic:1`; 0 objects lose it; 0
over-fires; the uhdm2rtlil corpus cannot move at all.**

| database | predicted objects |
|---|---|
| default/SimpleUVM | 3 (`k` x2, `objection` x1) |
| testflags/SimpleUVM | 3 |
| default/Scoreboard | 3 |
| default/SeqDriver | 7 (`uvm_pkg::k` x2, `adpcm_pkg::k` x4, `objection` x1) |
| testflags/SeqDriver | 7 |
| default/BuildUVMPkg | 3 |
| testflags/BuildUVMPkg | 3 |

**The uhdm2rtlil corpus is an impossibility proof**: the same census over all
**679** u2r databases reads **MISS=0 and OVER=0** — there is no disagreement of
this kind anywhere in it, so the law cannot move a byte there.

Three tests that DO contain a written `automatic` and are NOT this law's
(`FuncStruct`, `FuncStructVal`, `FuncIoTypespec` — all tf items, and all of them
pre-existing MISS rows of the § r10fsv3 family) were pre-checked by running both
binaries directly: **byte-identical**.

---

## 5. GATES (law 1)

Binaries: pristine `d20991b5c431664473ffbf3f8d9735ce`
(`/tmp/wt_r10uvm80pris/build/slang-uhdm`, a FRESH build of 4f9b233), law-1
patched `496c7b9e7c28d1f2ffddd3ed5b1bff21`. Every sweep's `cmds.txt` was grepped
to prove WHICH binary ran (`verify_golden.py` silently defaults `SLANG_UHDM`).

**GATE 0 — the pristine binary reproduces the COMMITTED baselines exactly**
(baseline FIRST, before any patched number was read):

| corpus | rows | whole-row diff vs committed baseline |
|---|---|---|
| uhdm2rtlil, testflags | 731 | **0 differing ROWS** (679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL) |
| surelog, both modes | 1588 | **0 differing ROWS** |

**GATE 1 — build.** Both binaries built `-j 2`, md5s above, `Built target
slang_uhdm`.

**GATE 2 — goldens.** `23 PASS / 0 FAIL`; negative control `SLANG_UHDM=/bin/false`
→ `0 PASS / 23 FAIL`.

**GATE 3 — uhdm2rtlil.** 731 rows, `679 CMP_EQUAL / 50 SLANG_REJECT /
2 SURELOG_FAIL`, `ct8rows.sh` **0 differing ROWS**, dump histogram unchanged
(52 / 183 differ / 496 match). `canaries.sh` ok=9 changed=0 absent=0
unknown=25 (expected 25 on a u2r csv); `ctcan2.sh EXPECT_UNKNOWN=6` PASS.

**GATE 4 — surelog, `--mode both`.** 1588 rows, `ct8rows.sh` **0 differing ROWS**
over 1588, both status and dump histograms identical.
`canaries.sh` ok=52 changed=0 absent=0 unknown=8 (expected 8 on a surelog csv);
`ctcan2.sh EXPECT_UNKNOWN=1` ok=58 changed=0 PASS; `canaudit.sh` audited=31
UNCOVERED=0 FENCE-BREACH=0.

**GATE 5 — the byte verifier, `SELFCHECK=1`.**

```
surelog   : PATH_SETS_IDENTICAL (953 paths)   MOVERS: 7 / 953
            SELFCHECK: 952 / 953 flagged
uhdm2rtlil: PATH_SETS_IDENTICAL (679 paths)   MOVERS: 0 / 679
            SELFCHECK: 678 / 679 flagged
```

**Every mover named and attributed** (`mv80.sh`, which re-censuses both sides of
each moved database and prints the per-object delta). All 25 deltas are
ADDITIONS of `vpiAutomatic:1`; **zero removals; zero objects of any other kind
moved**:

| database | Δ automatic objects | the objects |
|---|---|---|
| default/SimpleUVM | 953 → 956 (+3) | `…m_execute_scheduled_forks::guard::objection`, `…m_wait_for_available_sequence::k` x2 |
| testflags/SimpleUVM | +3 | same |
| default/Scoreboard | 933 → 936 (+3) | same |
| default/SeqDriver | 1083 → 1088 (+5) | `objection`, `uvm_pkg::k` x2, `adpcm_pkg::k` x2 |
| testflags/SeqDriver | +5 | same |
| default/BuildUVMPkg | 806 → 809 (+3) | `objection`, `k` x2 |
| testflags/BuildUVMPkg | +3 | same |

**Distance to golden strictly DOWN on all seven**, measured with the
resync-immune multiset instrument (`msdist.sh`), and down by EXACTLY the number
of objects each database gained:

| database | pristine | patched |
|---|---|---|
| default/BuildUVMPkg | 76 576 | **76 573** |
| testflags/BuildUVMPkg | 76 576 | **76 573** |
| default/Scoreboard | 129 105 | **129 102** |
| default/SeqDriver | 356 734 | **356 729** |
| testflags/SeqDriver | 356 734 | **356 729** |
| default/SimpleUVM | 138 803 | **138 800** |
| testflags/SimpleUVM | 138 799 | **138 796** |

**GATE 6 — the heads.**

| row | pristine cmp lines | patched | heads |
|---|---|---|---|
| SimpleUVM/default | 62 | **60** | 1 |
| SimpleUVM/testflags | 62 | **60** | 1 |
| Scoreboard/default | 62 | **60** | 1 |
| SeqDriver/default | 38 | 38 | 1 (cmp byte-identical with ids stripped — head untouched, earlier object) |
| SeqDriver/testflags | 38 | 38 | 1 (same) |
| BuildUVMPkg/default | 94 | 94 | 1 (same) |
| BuildUVMPkg/testflags | 94 | 94 | 1 (same) |

**GATE 7 — boundaries.** All **25** `.sv` arms of r10uvm79, r10uvm78 and
r10uvm77 run through both binaries: **0 moved**.

**GATE 8 — the census, re-run on the patched sweep.** MISS 108 → **94** rows;
per test, exactly the predicted objects left: BuildUVMPkg 12→9, Scoreboard 6→3,
SeqDriver 44→39, SimpleUVM 22→19 (×the two modes) = **25 objects**, the same 25
the byte verifier attributed. **OVER stayed at 40 rows — not one over-fire.**

### THE PREDICTION vs THE RESULT — a 4-object gap, and its cause

Predicted **7 databases** (exact — 7 moved, no more, no fewer) and **29
objects**; **25** landed. The 4 that did not are `adpcm_pkg::…::k` in SeqDriver,
2 per mode, and they are NOT a law failure: **golden holds FOUR of that object
and we emit TWO**, so two of golden's automatic-flag rows have no object on our
side to receive the flag. Counting golden's `vpiAutomatic=1` objects predicts
the **CEILING**; the object-MULTIPLICITY difference is the gap, and a census that
does not subtract it will always over-predict by exactly that amount. The
residual MISS row (`x2 919:35 int_var adpcm_pkg::…::k`) is recorded as residue
R3.

---

## 6. REFUTATIONS

### RF-1 — "read slang's `VariableSymbol::lifetime`" — MEASURED AND REFUTED

The obvious implementation is to read the symbol's lifetime. It is WRONG, and
the arm says so cell by cell. A temporary instrument (added for this measurement
and removed before the final build) printed, for every declaration the block
loop visits, the written-keyword verdict and slang's lifetime:

| cell | written kw | slang lifetime | golden |
|---|---|---|---|
| `a_fkplain` (fork arm, no kw) | 0 | **Automatic** | **0** |
| `c_bgplain` (begin, class task) | 0 | **Automatic** | **0** |
| `f_bgplainni` | 0 | **Automatic** | **0** |
| `g_inautofn` (`function automatic` local) | 0 | **Automatic** | **0** |
| `o_nbplain` (named begin) | 0 | **Automatic** | **0** |
| `q_iniplain` / `t_alwplain` / `v_mtplain` / `y_fbplain` (module) | 0 | Static | 0 |

slang fills the lifetime from the enclosing scope's default
(`VariableSymbols.cpp:81`, `lifetime = getDefaultLifetime(scope)`), so it is
Automatic for every block local of a class method. **On SimpleUVM alone the
block loop visits 1 349 declarations: the written-keyword law fires on 3 — the
three census-predicted objects — and the lifetime rule would have fired on
1 342 MORE, every one of them golden-correct at 0.**

### RF-2 — "stamp the array_var too" — REFUTED by arm c2

The natural reading of "the declared variable" for `automatic int q[$];` is the
object our `blockMap` holds, which is the `array_var`. Golden stamps the
**element** and leaves the `array_var` at 0 (four kinds measured: fixed, queue,
dynamic, associative — plus the module-scope pair `n_marr`/`o_mq`). Surelog's
code agrees: the wrapper is minted after the flag is written.

### RF-3 — "a class method's locals are automatic" — REFUTED by cell c8

`function automatic void f_auto(); begin int g = 1; … end endfunction` — golden
reads **0** on `g`. The subroutine's lifetime does not reach its block locals;
only the declaration's own keyword does.

---

## 7. RESIDUES (ranked)

**R0 — THE NEW HEAD of the three target rows, and it is the SAME object on all
three** (60 lines, `md5 5dbf2c6ff71371ab101e27bd7ca6f6ff` with ids stripped —
i.e. the three rows still share one head, as they did before):

```
LHS (golden)  string_var: (uvm_pkg::val)   uvm_pkg.sv:802:12
              |vpiParent: \_package: uvm_pkg
              |vpiName:val  |vpiFullName:uvm_pkg::val
              |vpiAutomatic:1  |vpiVisibility:1
RHS (ours)    io_decl:    (val)            1381:68
```

It is a **KIND and PARENT** mismatch, not a flag one: golden has a package-scope
`string_var val` owned by `uvm_pkg`, we hand `uhdm-cmp` an `io_decl` from a
different line entirely. That is the `uvm_pkg::val` / `uvm_pkg::clp` family the
census already lists (10 MISS rows per UVM row, `work@top.val`,
`work@top.clp`, `work@top.uvm_random_seed_table_lookup`, `work@top.top/cs/
common/bld/error_str`) — package variables HOISTED into the top module. Next
pass's target; it is § packageVarAutomaticIsDataDeclShape26's neighbourhood, not
this law's.

**R1 — `function automatic` on a subroutine.** Arm c1's own remaining cmp head:
golden stamps `vpiAutomatic:1` on the `function: (p80::c80::f_auto)` declared
`function automatic void f_auto()`; we do not (`TaskFuncEmit.cpp:2859` reads
`sub.defaultLifetime` and this cell does not reach it). A DIFFERENT object class
(`task_func`, `CompileStmt.cpp:1910`) from this law's `variables`. Corpus
population unmeasured — no corpus row's head is on it.

**R2 — the tf-ITEM automatic residue** (§ r10fsv3's family; the largest of the
144 remaining MISS objects — `clp` x9, `uvm_cmdline_proc` x4 and the
`FuncIoTypespec`/`FuncStruct` function locals). Golden stamps a subroutine's
block-item local
`VpiAutomatic(!is_static)` (`CompileStmt.cpp:1690`) — automatic unless `static`
is written — while our rule at `TaskFuncEmit.cpp:5157` is
`!hasInit && !blockLocal && !blockItems9`, so every INITIALIZED tf item comes
out 0 where golden reads 1: `uvm_component::m_set_cl_verb::clp`,
`m_set_cl_action::uvm_cmdline_proc`, `m_set_cl_sev::uvm_cmdline_proc`,
`m_set_cl_msg_args::p_`, and `FuncIoTypespec`'s five `result`/`result_t`/
`sbit_arg1`, `FuncStruct`'s `sigma_0`. Deliberately untouched here: it is a
different Surelog site with a different rule, and mixing the two is how a
one-line law becomes a two-law regression.

**R3 — the `adpcm_pkg::…::k` object COUNT.** Golden holds 4 of that `int_var`
in SeqDriver (both modes), we hold 2. A multiplicity residue, unrelated to the
flag; it is why the prediction's ceiling was 29 and the floor 25.

**R4 — the 40 OVER rows** (ours 1, golden 0), unchanged by this pass and
untouched by it: `ClassFsm` x4, `ClassExtends`, `ClassParamAsParam`,
`ClassTypeParam`, `ClassVar`, `LocalScopeHierPath` x1 each, and 5–9 per UVM row.
They belong to the Signal/elaboration site, not the statement site.

---

## 8. FILES

| file | role |
|---|---|
| `r10uvm80cen.cpp` | the census instrument (`Serializer::AllObjects()`, `variables` + `vpiAutomatic`) |
| `build80.sh` | builds it against the static UHDM in `~/.local` |
| `ct80cen.sh` | whole-workdir golden-vs-ours census join; MISS / OVER per database |
| `ct80arm.sh` | golden + BOTH binaries in ONE scratch dir, per-binary cmp/heads/dump distance |
| `ct80gate.py` | STATED GATE == CODE GATE audit, with a pristine negative control |
| `mv80.sh` | attributes every byte-mover to named objects |
| `c1_autolife.sv` | the 23-cell position × keyword grid |
| `c2_autokinds.sv` | the declaration-KIND grid (which object gets the flag) |
| `c3_deepjoint.sv` | characterisation arm for r10uvm79's V-R1 (§9) |
| `rowheads.sh` `ct8rows.sh` `byteverify.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `msdist.sh` | the standard gates, carried forward unchanged |

---

## 9. SECOND LAW — § selIdxNestPrefixJoinsByScope80 (r10uvm79's residue V-R1)

Separate law, separate surface (`src/ExprEmit.cpp`, ONE line), separate gates.

```
§ selIdxNestPrefixJoinsByScope80    src/ExprEmit.cpp, the generic ElementSelect
                                    index-prefix, 1 site
```

> The prefix a SELECT's index subtree hands to what is **NESTED** under it is
> `joinRef(prefix, <the select's base name>)`, never a hard `"."`.

This is the **FIFTH** site of the joint family — r10uvm77 fixed the
trailing-step refs, r10uvm78 the doubled part-select prefixes, r10uvm79 the
hier-path tail AND the path-scoped index, and this is the prefix that index
subtree passes DOWN. It lives outside `emitMixedHierPath`, which is why
r10uvm79 could not reach it.

### The grid — arm `c3_deepjoint.sv`

| cell | expression | golden | base | patched |
|---|---|---|---|---|
| d1 | `iarr[midx[i]].f` (depth 1, control) | `…::iarr[[i]].f::midx`, `…::i` | = | = |
| d2 | `iarr[midx[midx[i]]].f` | `…::iarr[].f::midx`, `…::midx::midx`, `…::midx::i` | `…::iarr[].f.midx…` | **= golden** |
| d3 | `iarr[midx[midx[midx[i]]]].f` | `…::midx::midx::midx`, `…::midx::midx::i` | `.`-joined | **= golden** |
| d4 | `iarr[midx[i + j]].f` (operation under the index) | `…[[i + j]].f::midx::i`, `::j` | `.midx::i` | **= golden** |
| d5 | `iarr[midx[fn80(i)]].f` (call under the index) | `…::iarr[].f::midx` | | = golden |
| d6 | `iarr[pk4[i] > 0 ? … ].f` (ternary) | `…::iarr[ > 0 ?  : ].f::pk4` | — | — (r10uvm79's V-R2/V-R4, the index TEXT; untouched) |
| d7 | LVALUE at depth 2 | as d2 | `.`-joined | **= golden** |
| d8 | **MODULE twin** `sarr[mi[mi[z]]].f` | `work@mdeep80.sarr[].f.mi.mi` — `.` at every joint | = | **byte-identical, unchanged** |

d8 is the load-bearing cell: `joinRef` returns `.` for a `.`-first prefix, so the
module world does not move at all. Arm c3's dump distance to golden falls
**156 → 120**.

### Boundary arms — the per-NAME check, not the aggregate

Of the 25 arms of r10uvm77/78/79, **5 move** and this law names every one of
their cells (nested select indices). uvm79's V-F2 lesson is that a per-shape
aggregate can mask a field-level regression inside a net-improving line, so each
moved arm was measured on the **fullname MULTISET**, per name:

| arm | fullname distance law1 → law1+2 | names introduced that golden LACKS | golden names newly produced |
|---|---|---|---|
| `c1_nestedidx` | 10 → **0** | **0** | 4 |
| `c2_idxkind` | 16 → **12** | **0** | 2 |
| `v79v1_idxkind` | 37 → **29** | **0** | 3 |
| `v79v4_base` | 40 → **34** | **0** | 3 |
| `v79v5_deep` | 20 → **14** | **0** | 3 |

`c1_nestedidx` — the arm r10uvm79 built as the CORPUS HEAD SHAPE — reaches
fullname distance **0**. The other 20 arms are byte-identical.

### GATES (law 2), and an HONEST note on its prediction

Law 1's corpus movers were predicted EXACTLY from the artifact before the build.
**Law 2's could not be**, and that is stated rather than papered over: every
textual detector for "a `.` where golden writes `::`" fires on golden too
(golden's own `iarr[].f::midx` contains `].f`, and r10uvm78's RF-1 already
established that a `.` inside a `::` scope is legitimate in 768 golden objects),
and a structural detector was not built. What IS predicted, and verified on
every mover, is the **DIRECTION**: fullname multiset distance to golden strictly
DOWN, and **zero** names produced that golden does not have.

Measured with a law-1+2 binary (`865f353f617975b4c94d718f60d5bb33`) swept over
both corpora and byte-compared **against the law-1 sweep**, so every number here
is law 2 ALONE:

| gate | result |
|---|---|
| goldens | **23 PASS / 0 FAIL** |
| surelog rows (1588) | `ct8rows.sh` **0 differing ROWS** |
| uhdm2rtlil rows (731) | `ct8rows.sh` **0 differing ROWS**, 679/50/2 |
| canaries (both corpora) | `canaries.sh` changed=0 (52 / 9 rows); `ctcan2.sh` changed=0 |
| byteverify u2r, law2 alone | **0 / 679 movers** |
| byteverify surelog, law2 alone | **10 / 953 movers**, `SELFCHECK 952/953` — `default+testflags` × {SimpleUVM, SeqDriver, BuildUVMPkg, SVSwitch}, plus `default/Scoreboard` and `default/Earlgrey_0_1` |
| heads on the 3 target rows | 60 lines / 1 head — unchanged from law 1 |

### AND THAT IS WHY LAW 2 IS **NOT** IN THIS PASS'S PATCH

Two of law 2's ten movers are **`SVSwitch`** (both modes) and
**`Earlgrey_0_1`** — and `SVSwitch` is one of the FOUR databases the standing
brief requires to be **byte-identical**. The standing rule has no
"unless your law names the cell" clause for those four (that clause is attached
to the boundary ARMS), so landing law 2 would violate it. **Law 1 ships; law 2
ships as a measured, ready-to-apply diff in this directory
(`law2_selIdxNestPrefixJoinsByScope80.diff`) and NOT in the patch.**

**Every one of the ten movers was judged per NAME** with the census tool's
`R10UVM80_NAMES=1` mode (each object counted ONCE — the dump reprints an object
at every reference, and Earlgrey's dump is a quarter of a gigabyte of text; the
mode was CALIBRATED against the dump-based measurement on SVSwitch and
reproduces it exactly, same four names, same direction):

| database | NAME-multiset distance to golden, law1 → law1+2 | names introduced that golden LACKS | GOLDEN names newly produced |
|---|---|---|---|
| SimpleUVM (both modes) | 5 348 → **4 930** | **0** | 79 |
| Scoreboard/default | 5 307 → **4 889** | **0** | 79 |
| SeqDriver (both modes) | 13 806 → **13 028** | **0** | 141 |
| BuildUVMPkg (both modes) | 4 900 → **4 608** | **0** | 65 |
| SVSwitch (both modes) | 74 → **64** | **0** | 4 |
| Earlgrey_0_1/default | 18 727 → **18 667** | **0** | 15 |

Not one name moved the wrong way anywhere, in any of the ten. The names it
newly gets right are exactly the shape the law describes —
`uvm_pkg::uvm_sequencer_base::m_choose_next_request::arb_sequence_q::avail_sequences`,
`uvm_pkg::uvm_phase::wait_for_self_and_siblings_to_drop::siblings::m_sync`,
`prim_cipher_pkg::perm_32bit::state_in::perm`.

The measurement the next pass needs, because it says the canary and the law
disagree and the law is right:

```
default/SVSwitch   fullname multiset distance to golden   law1 = 139  ->  law1+2 = 129
                   names introduced that golden LACKS                    0
                   GOLDEN names newly produced                           4
                     work@Receiver::start::bytes::size
                     work@packet::byte_pack::bytes::i
                     work@packet::byte_unpack::bytes::size
                     work@packet::byte_unpack::bytes::i
```

`work@Receiver::start::bytes::size` is **cell C of `joinRef`'s own comment
table** in `src/EmitHelpers.h` — the cell whose comment already records that
golden writes it with `::` and that a wrong repair once broke it. Law 2 makes us
produce it. SVSwitch stays `CMP_EQUAL` with an unchanged dump column throughout
(the row gate is 0 differing rows), so the movement is invisible to every CSV
instrument and only the byte verifier sees it.

### Reproducing law 2

```sh
git apply tools/probe/r10uvm80repro/law2_selIdxNestPrefixJoinsByScope80.diff
# then: build; PAT=<law2 build> PRI=<law1 build> ct80arm.sh c3_deepjoint.sv
# and:  R10UVM80_NAMES=1 r10uvm80cen <db> | ... (the per-name judge above)
```

The diff is ONE line of code inside `emitExpr`'s generic `ElementSelect` arm
(`idxPrefix = prefix + "." + name` → `idxPrefix = joinRef(prefix, name)`) plus
its comment.
