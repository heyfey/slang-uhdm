# r10buvm17 — § `foreachElabLoopVarAnyKindBinds17` — **the BuildUVMPkg head cleared, and the foreach loop-variable bind family closed on every resolved kind**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `72931ce` |
| worktree | `/tmp/wt_r10buvm17` |
| pristine binary | md5 `c95bcb1d01cf06e0646d83ce287aa8d3` |
| patched binary | md5 `fe481ff3f2326ba2bfd8dd067f863d80` |
| production surface | `src/StmtEmit.cpp` (one return predicate) + `src/TaskFuncEmit.cpp` (one saved/restored flag) + `include/UhdmExporter.h` (its declaration) — **65 added lines, 55 of them comment** |
| probe surface | `tools/probe/r10buvm17repro/` only |
| deliverable | `/tmp/r10buvm17.patch`, applies clean on a FRESH `72931ce` |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines.  What it does is clear buvm16's residue
R0 and close the foreach loop-variable bind family on every kind Surelog
resolves.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` heads (`grep -c '^LHS:'`), default / testflags | 1 / 1 | 1 / 1 |
| `BuildUVMPkg` cmp lines, default / testflags | **29 / 29** | **84 / 84** (a DIFFERENT, DEEPER head — see § 7) |
| `BuildUVMPkg` cmp md5, both modes | `16780a99e816` (the brief's pin, hit exactly) | `551fe9a07afd` |
| head object | `byte_var(…get_packed_bytes::i)` / `RHS <null>` | `bit_typespec(uvm_field_flag_t)` vs `int_typespec` (**R0**) |
| foreach census, surelog corpus (956 DBs), `GOLDEN-BINDS-OURS-BARE` sites | **228** | **137** |
| the same, `AGREE` | 7 172 | **7 263** |
| the same, `OURS-BINDS-GOLDEN-BARE` (over-fire) | **1** | **1** (the SAME pre-existing cell — § 8 R4) |
| byte movers | — | **9 / 956** surelog, **0 / 1358** u2r, all 9 predicted BY NAME first |

The other **ten** cmp logs of the seven-row head set are **byte-identical
between the two binaries**, and both `BuildUVMPkg` modes' logs are byte-identical
to each other on both binaries.

## 1. THE HEAD, DECODED FROM THE PRISTINE LOG FIRST

Read out of `/tmp/r10buvm17_heads_pris/BuildUVMPkg.default.cmp` before any code
was written:

```
LHS:
decompile:
byte_var: (uvm_pkg::uvm_packer::get_packed_bytes::i), id:191859, line:22233:20, endln:22233:21
|vpiParent:
\_foreach_stmt: (uvm_pkg::uvm_packer::get_packed_bytes), id:11223, line:22233:4, endln:22233:11
…
RHS: <null>
```

`BaseClass.h:187-193`'s SINGULAR `SafeCompare` has exactly one arm that prints
this shape:

```cpp
} else if ((lhs != nullptr) && (rhs == nullptr)) {
  context->m_failedLhs = lhs;      // the VALUE, not the owner
  return 1;
```

(the VECTOR overload's asymmetric arm sets the OWNER `lhs_obj` and is guarded by
`!lhs->empty()`, so it cannot print a *variable* on the left with a `<null>`
right.)  `ref_obj::Compare`, read in
`~/git-repos/UHDM/build/generated/src/ref_obj.cpp:150`, has exactly ONE singular
`SafeCompare`: `Actual_group()`, compared after `VpiName` / `VpiDefName` /
`VpiGeneric`.  So the head is a `ref_obj` whose golden `vpiActual` is that
`byte_var` and whose ours is **absent** — the exact mirror of the head buvm16
cleared.

### THE BRIEF'S ARITHMETIC IS CORRECTED BY THE DUMPS

The brief reads the 15-vs-11 name count as "2 refs × 2 ELAB copies".  It is
**FOUR references in ONE copy**.  `uvm_pkg.sv:22226-22240` is the out-of-body
`function void uvm_packer::get_packed_bytes(ref byte unsigned stream[])`, and
its `foreach (stream[i])` body names `i` four times:

| ref | written | golden ELAB | ours (pristine) |
|---|---|---|---|
| `22234:11` | `if (i != sz-1 …)` — an operation operand | `byte_var(i)` | BARE |
| `22235:14` | `m_bits[i*8 +: 8]` — an indexed-part-select BASE | `byte_var(i)` | BARE |
| `22237:14` | the same in the `else` arm | `byte_var(i)` | BARE |
| `22238:14` | `stream[i] = v;` — a bit-select INDEX | `byte_var(i)` | BARE |

**IT IS A DEF/ELAB SPLIT, and the LISTING already agreed.**  Golden's
un-elaborated `uhdmallPackages` listing (dump line 51201) lists the loop
variable as `ref_var(i)` and leaves all four references BARE; **so do we**
(51209).  Golden's elaborated `uhdmtopPackages` listing (620167) lists
`byte_var(i)` — **so do we** (619486) — and binds all four.  Only the four
`|vpiActual:` edges were missing.

## 2. THE LAW, DECODED FROM THE PRODUCER

> **§ `foreachElabLoopVarAnyKindBinds17`** — in a PACKAGE-homed subroutine's
> ELABORATED listing, a body reference to a `foreach` loop variable binds the
> object the loop lists in `vpiLoopVars` **whatever that object's KIND is**.
> The un-elaborated listing lists an unresolved `ref_var` and binds nothing.

Surelog has **no kind test at all**.  `UhdmWriter::lateBinding`
(`UhdmWriter.cpp:3294`) walks the reference's own `VpiParent` chain and, on a
`foreach_stmt` parent (`:3522`), does

```cpp
for (auto var : *f->VpiLoopVars()) {
  if (var->VpiName() == name) {
    if (var->UhdmType() == uhdmref_var) continue;   // <-- the ONLY test
    if (var->UhdmType() == uhdmref_obj) continue;
    ref->Actual_group((expr*)var);
```

and a loop variable **is** a `ref_var` when it leaves
`CompileHelper::compileStmt`'s `paFOREACH` arm (`CompileStmt.cpp:525-598`: a
`ref_var` over a freshly minted `unsupported_typespec`, registered with
`component->needLateTypedefBinding`).  It stops being one only when
`UhdmWriter::lateTypedefBinding` -> `swapForSpecifiedVar`
(`UhdmWriter.cpp:2490-2570`) replaces it with whatever
`CompileHelper::getSimpleVarFromTypespec` (`CompileType.cpp:78`) makes out of
the iterated array's decoded typespec — `byte_var` for `byte unsigned s[]`,
`long_int_var`, `bit_var`, `string_var`, `struct_var`, `class_var`,
`real_var`, `short_int_var`, `array_var`, or the `int_var` default when the
decode fails.  And `writePackage` runs that swap **only for the elaborated
copy**:

```cpp
  if (elaborated) {
    lateTypedefBinding(s, pack, p);      // UhdmWriter.cpp:1301-1303
  }
  lateBinding(s, pack, p);               // :1304, BOTH copies
```

That one `if` **is** the def/elab split, and the kind list our emitter carried
(`int_var` / `array_var` / the associative INDEX / the class-property `string`)
was only ever a proxy for it.

**WHY A PACKAGE HOME.**  `writePackage` is the only writer that runs
`lateTypedefBinding` over an elaborated listing.  A MODULE home takes a
different road entirely (Surelog's elaboration mints an implicit net and binds
that — our `implicitNetModule` arm already matches it), a `$unit` home binds
nothing, and a PROGRAM or INTERFACE home keeps the unresolved `ref_var` listing
in golden.  Class definitions get neither call at all
(`UhdmWriter.cpp:1066-1067` — `lateTypedefBinding` / `lateBinding` are
commented out), which is why an IN-BODY class method stays bare in both views.

## 3. THE PASS-9 OBJECTION, RE-MEASURED AND RETIRED

The code this pass changes carried an explicit warning:

> *"Only the INT_VAR shape is registered as bindable.  Widening it to every
> resolved kind is measurably wrong: on SeqDriver that bound 161 string_var,
> 99 bit_var and 56 logic_var refs golden leaves alone (its own loop-variable
> object there is an unresolved ref_var — 2112 of them, residue R-lv)."*

That objection was about the **LISTING**, not the binding, and passes 19-22
closed it.  Measured at `72931ce` with `r10buvm17cen`, the `lv=` listings now
disagree on

| row | foreach sites | `lv=` listing differences |
|---|---|---|
| BuildUVMPkg | 773 | **4** |
| SeqDriver | 1 345 | **3** |
| MiniAmiq | 1 458 | **22** (19 of them a `DEFIFACE` listing) |
| SimpleUVM / Scoreboard | 737 / 739 | **2** each |

and **every site this widening moves lists the SAME object kind on both
sides**.  The 2 112 unresolved `ref_var` listings the note describes are gone.

## 4. THE INSTRUMENT

`r10buvm17cen.cpp` reads a `.uhdm` out of `Serializer::AllObjects()` (never dump
TEXT) and prints one row per `foreach_stmt`: the enclosing subroutine's full
name, the foreach's `line:col`, the **VIEW** (`DEFPKG` / `ELABPKG` / `DEFMOD` /
`TOPMOD` / `DEFIFACE` / `DEFPROG`, decided by which of the design's
`AllPackages` / `TopPackages` / `AllModules` / `TopModules` / `AllInterfaces` /
`AllPrograms` lists the foreach's ROOT ancestor sits in), the whole `vpiLoopVars`
listing as `kind(name)`, and **every reference to a loop-variable name anywhere
under the foreach** as `name@line:col:parentkind->actualkind(name)` or `->BARE`.

**KEYING TRAPS PAID FOR HERE, and both are encoded in the scripts.**

1. **The design is everyone's ancestor.**  The first cut walked `VpiParent` to
   the very top and looked the ROOT up in the design's lists — which answered
   `ROOT-design` for all 774 rows on both sides, i.e. the view axis, the axis
   the whole law turns on, silently read as a constant.  The walk now stops one
   step below `uhdmdesign`.
2. **THE REFERENCE'S PARENT KIND IS A DIAGNOSTIC, NOT A KEY.**  Keying the join
   on the reference SHAPE (`name@loc:parentkind`) split 159 of BuildUVMPkg's 773
   sites into two one-sided keys that read as "no disagreement", because our
   selects are `bit_select` where golden builds a `hier_path` (a separate,
   pre-existing residue).  The key is the SITE (`subroutine|loc` + view); the
   shape and the actuals are the VALUE, and `cencls17.py` reports a
   parent-kind-only difference as its own class `POSITION-ONLY` so it can never
   be counted as a bind disagreement — 1 441 sites corpus-wide are exactly that.
3. References are attributed to a foreach by walking **their own** `VpiParent`
   chain up to the `foreach_stmt`, not by a hand-written statement walker: every
   statement kind is covered for free and an unparented node is COUNTED as
   `orphanrefs` instead of silently vanishing (ours carry 157 in BuildUVMPkg,
   golden 0 — a separate residue that the census reports rather than hides).

## 5. THE GRID — TWO ARMS, AND THE COUNTER-WITNESS THAT NARROWED THE LAW

`grid17.sh` prints golden / pristine / patched per site.  Verdicts: `same`,
`CONVERTED` (P wrong, Q == G), `OVER-FIRE` (P right, Q wrong),
`MOVED-STILL-WRONG`, `residue` (G != P == Q).

### a1 `a1_lvkinds17.sv` — A PACKAGE AND NOTHING ELSE, exactly BuildUVMPkg's shape
`-- MOVED-STILL-WRONG=1 residue=1 same=6 CONVERTED=15`, **0 OVER-FIRE.**

| cell | written | golden ELAB | pristine | patched |
|---|---|---|---|---|
| `k_byte17` | OOB method, `ref byte unsigned s[]`, three POSITIONS (operation operand, bit-select index, `$display` argument) | `byte_var` ×3 | BARE ×3 | **bound ×3** |
| `k_long17` / `k_short17` / `k_bit17` / `k_real17` / `k_str17` | `longint` / `shortint` / `bit [15:0]` / `real` / `string` | `long_int_var` / `short_int_var` / `bit_var` / `real_var` / `string_var` | BARE | **bound** |
| `k_cls17` / `k_struct17` | a queue of class handles / of packed structs | `class_var` / `struct_var` | BARE | **bound** |
| `k_multi17` | `foreach (g17[i,j])` — TWO loop variables at once | `byte_var(i)`, `byte_var(j)` | BARE ×4 | **bound ×4** |
| `k_nest17` | a NESTED foreach's inner variable | `byte_var(j)` | BARE | **bound** |
| `k_task17` / `k_static17` | an OOB TASK, an OOB STATIC method | `byte_var` | BARE | **bound** |
| `free17` / `freetask17` / `freestr17` | a package FREE function / task | `byte_var`, `string_var` | BARE | **bound** |
| `k_int17` | the `int_var` shape pass 9 already registered | `int_var` | bound | bound (unchanged) |
| `k_assoc17` | `[string]` and `[class]` associative INDEX (pass 19) | `string_var` | bound | bound (unchanged) |
| **`k_clsidx17`** | **THE PATH-BASE CONTROL** — `foreach (m_bycls17[c])` over `int m_bycls17[D17]`, body uses `c.d17`, `c.val17()` and `m_bycls17[c]` | **`BARE`, `BARE`, `class_var(c)`** | same | **same — the two dotted positions STAY BARE** |
| `k_inbody17` | the IN-BODY class-method control (§ `classMethodNoBind`) | BARE | BARE | BARE |
| `k_dotted17` | `q17[o].d17` / `q17[o].val17()` — the loop var as a bit-select INDEX inside a path | `class_var(o)` | BARE | **bound** (`MOVED-STILL-WRONG`: the BINDING converts, our node is still `bit_select` where golden builds `hier_path` — R2) |
| `k_shadow17` | a loop variable SHADOWING a subroutine local | `int_var(i)` in **both** views | BARE | BARE (`residue` — R5, untouched) |

`k_clsidx17` is the cell that makes the no-over-fire claim a MEASUREMENT rather
than an inference: golden binds the bit-select INDEX and leaves the hier_path
BASE and the method-call RECEIVER bare, in the same foreach, in the same
elaborated listing — and the patched binary reproduces all three.

### a2 `a2_homes17.sv` — **THE HOME GUARD, and the counter-witness that narrowed the law**
`-- residue=4 same=5 CONVERTED=2`, **0 OVER-FIRE, 0 MOVED-STILL-WRONG.**

| cell | home | golden | verdict |
|---|---|---|---|
| `hoob17` / `hfree17` | a PACKAGE class OOB method / free function, with a top module present | `byte_var` / `string_var` bound | **CONVERTED** |
| `mfn17` / `mtask17` / the `initial` block | a MODULE function / task / `initial` | `logic_net(i)` — the implicit net | **same** (untouched: ExprEmit's `implicitNetModule` arm owns them) |
| `moob17` | an OOB method of a class declared INSIDE a module | `logic_net(i)` | residue (our listing/naming already differs) |
| `unitfn17` | a `$unit` function | BARE | **same** |
| `iffn17` | an INTERFACE function | golden lists `ref_var`, BARE | residue (our listing resolves — R3) |
| **`pgfn17`** | **a PROGRAM function** | golden lists `ref_var`, **BARE** | **residue — and UNGATED IT WAS AN OVER-FIRE** |

The first cut had no home test and bound `pgfn17`'s reference where golden
leaves it bare, because our listing resolves a variable golden does not.  The
shipped gate is `curSubPkgHome17` — the package-home test
(`pkgScope && !classScope`, or an OUT-OF-BODY class method whose `class_defn`'s
parent is a `package`), the same test `pkgRetFoldHome86` already computes for
its own window — and with it `pgfn17` is untouched.  The gate costs **nothing**
in the corpus: the five-row census is bit-for-bit identical gated and ungated.

## 6. THE CENSUS AND THE MOVER PREDICTION MADE BEFORE THE SWEEP

`/tmp/r10buvm17_prediction.txt` was written by `predict17.py` from the PRISTINE
**OUR-SIDE** censuses alone — no golden, no patched database — with the
predicate *"a site whose view is `ELABPKG`, whose `vpiLoopVars` listing carries
no `ref_var`, and NOT ONE of whose loop-variable references is bound"*:

| corpus | predicted movers |
|---|---|
| surelog | `default`+`testflags` × `BuildUVMPkg` (35 sites), `MiniAmiq`, `SeqDriver`, `SimpleUVM` (26 each), plus `default/Scoreboard` (its `testflags` row is `SLANG_REJECT` — no database) = **9** |
| uhdm2rtlil | **ZERO.**  The census finds **`foreach=0` in all 1 358 databases**: the only `foreach` in the whole corpus (`multiplier/dut.sv:105`) is COMMENTED OUT. |

`byteverify.sh` reported **exactly those 9 databases and no others** out of 956,
and **0 / 1358** on u2r.

Corpus-wide, joined site-by-site by `cencls17.py` over all 956 surelog
databases:

| class | pristine | patched |
|---|---|---|
| `AGREE` | 7 172 | **7 263** |
| `GOLDEN-BINDS-OURS-BARE` | **228** | **137** |
| `OURS-BINDS-GOLDEN-BARE` | 1 | 1 (the same cell) |
| `KIND-DIFF` / `LISTING-DIFF` / `POSITION-ONLY` / `REFSET-DIFF` | 16 / 64 / 1 441 / 492 | unchanged |

## 7. ATTRIBUTION — every mover named, to the LINE

`dumpdiff17.sh`, pristine -> patched, path-normalised and reported both raw and
ORDER-BLIND.  **Every changed side is an ADDED `|vpiActual:` and its target;
ZERO lines were removed anywhere.**

| database | raw sides | sorted sides | content |
|---|---|---|---|
| `BuildUVMPkg` (both modes, identical) | 56 | **56** | **28 added actuals**: `get_packed_bytes::i` ×4, `get_packed_longints::i` ×4, `m_set_cl_verb::i` ×4, `perform_accesses::i` ×4, `uvm_has_wildcard::i` ×3, `get_addresses::i` ×2, `pack_string::index`, `set_packed_bytes::i`, `set_packed_longints::i`, `add_sequences::i`, `add_typewide_sequences::i`, `get_physical_addresses_to_map::idx` |
| `SeqDriver` / `MiniAmiq` / `SimpleUVM` (both modes) | 30 | **30** | **15 added actuals** each: `uvm_has_wildcard::i` ×3, `pack_string::index` ×2, `m_has_wildcard::i` ×2, `m_set_cl_verb::i` ×2, `get_addresses::i` ×2, `get_physical_addresses::i`, `get_predecessors_for_successors::pred`, `add_sequences::i`, `add_typewide_sequences::i` |
| `Scoreboard` (default) | 122 | **30** | the same 15.  The extra 92 raw sides are the campaign's documented `vpiTaskFunc` ORDER COIN; attributed ORDER-BLIND, as the measurement laws require |

`detcheck17.sh`: 3 runs of the patched binary on the `BuildUVMPkg` input give
**1 distinct hash**, 0 `NO_OUTPUT`.

## 8. THE GATES

| gate | result |
|---|---|
| 1 build both, md5 | `c95bcb1d01cf06e0646d83ce287aa8d3` pristine / `fe481ff3f2326ba2bfd8dd067f863d80` patched.  Both frozen read-only at `/tmp/r10buvm17_bin/` BEFORE any sweep; every workdir's `cmds.txt` re-read and asserted to name only that binary. |
| 2 goldens | patched **23 PASS / 0 FAIL**, pristine **23 / 0**, and `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL** (the negative control), each with `SLANG_UHDM` exported explicitly |
| 3 u2r, `--mode both` | **0 differing ROWS** against the committed `results/gate_uhdm2rtlil.csv` AND against the pristine sweep taken first in this worktree; **679 `CMP_EQUAL` / 50 `SLANG_REJECT` / 2 `SURELOG_FAIL`** in both modes; dump column unmoved |
| 4 surelog, `--mode both` | **0 differing ROWS** against the COMMITTED `results/golden_surelog.csv`, over all **1588** rows, status AND dump.  **NO ROW CONVERTED.**  The PRISTINE sweep is byte-identical to that baseline too, so there is no drift to report this pass. |
| 5 byteverify | **9 / 956** surelog, all 9 predicted BY NAME first; **0 / 1358** u2r; `SELFCHECK` 955/956 and 1357/1358 |
| canaries | `canaudit.sh` `audited=29 UNCOVERED=0 FENCE-BREACH=0`; `canaries.sh` `ok=52 changed=0` (surelog) and `ok=8 changed=0` (u2r); `ctcan2.sh` PASS on both.  `SVSwitch` `4842211c4030` and `YosysVerx` `6ccda350c24a` hit exactly; `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` byte-identical in both modes. |
| boundary | `bound17.sh` compiled **every `.sv` arm under `tools/probe/`** with both binaries: `PROCESSED=2765 == LISTED=2765`, rejects symmetric (124 == 124, no asymmetric reject), and **THREE arms differ — this pass's own `a1`/`a2` and exactly ONE pre-existing arm, `r10uvm8repro/q1/dut.sv`, whose single moved cell was then measured against golden and CONVERTS** (`p1::qj`, a package free function over `ref string i[$]`, `string_var(k)`).  **Every bind-window law's arm is byte-identical** — buvm13 / buvm15 / buvm16, uvm88, uvm90, uvm82, uvm91, sd8-12, and the `classArgBind12` / `28` / `57` / `64` witnesses. |

## 9. R0 — THE NEW HEAD, DECODED, AND IT IS NOT A REGRESSION

```
LHS:
bit_typespec: (uvm_field_flag_t), id:2174, line:7859:9, endln:7859:49
|vpiParent:
\_parameter: (uvm_pkg::UVM_PACK), id:2179, line:8001:28, endln:8001:36
|vpiName:uvm_field_flag_t
|vpiTypedefAlias:
\_ref_typespec: (uvm_pkg::UVM_PACK::uvm_field_flag_t) -> bit_typespec (uvm_pkg::uvm_field_flag_t)
…
RHS:
int_typespec: , id:177658, line:8001:11, endln:8001:27
|vpiParent:
\_parameter: (uvm_pkg::UVM_PACK), id:2850, line:8001:28, endln:8001:36
```

Both sides are set, so this is a `VpiType` mismatch in
`typespec::Compare` — `bit_typespec` vs `int_typespec` — on the TYPESPEC of the
package parameter `uvm_pkg::UVM_PACK` (`uvm_pkg.sv:8001`,
`localparam uvm_field_flag_t UVM_PACK = …`).  Golden types the parameter with
the TYPEDEF object (`uvm_field_flag_t`, a `bit_typespec` declared at 7859:9,
carrying `vpiTypedefAlias` to the package-level copy); we emit a bare
`int_typespec` spanning the initialiser.  It is the typespec-LINKAGE family, not
a binding one, and `UVM_NOPACK` and its siblings one line down are the same
shape.

**It is not a regression.**  The pristine and patched dumps of that parameter are
**byte-identical** (`diff` over the whole 700-780 region: `IDENTICAL-REGION`),
and golden's `bit_typespec` disagreed with our `int_typespec` there before this
pass ran.  R0 was simply MASKED by the head this pass cleared.

**The line count going UP (29 -> 84) is not more defects** — it is a BIGGER
OBJECT printing.  The old head decompiled one `byte_var`; the new one decompiles
a `bit_typespec` with its `vpiTypedefAlias`, its `vpiInstance` and its whole
`vpiRange` subtree, twice.  The head count is 1 on both binaries and both modes.

## 10. RESIDUES THIS PASS MEASURED AND DID NOT TOUCH

* **R1 — THE `ref_var` LISTING THAT GOLDEN BINDS ANYWAY** (the whole remaining
  gap).  All **137** remaining `GOLDEN-BINDS-OURS-BARE` sites, in **5 databases**
  (`SeqDriver` and `MiniAmiq` ×2 modes, 34 each, plus one cell in
  `LocalScopeHierPath`), have an **unresolved `ref_var` listing on BOTH sides**
  and golden binds the reference to that `ref_var` — in the DEFPKG view as well
  as the ELABPKG one (68 / 69).  `UhdmWriter::lateBinding` cannot do that (it
  `continue`s on `uhdmref_var`), so the producer is UHDM's own
  `ElaboratorListener`: `enterForeach_stmt`
  (`UHDM/templates/ElaboratorListener.cpp:1172`) puts **every** `VpiLoopVars`
  entry, `ref_var` included, into the scope map, and `leaveRef_obj`'s `bindAny`
  binds through it — which happens only in a design that gets elaborated, i.e.
  one with a top module.  `BuildUVMPkg` (a package and nothing else) has ZERO of
  these; that is why this pass clears its head completely and leaves 34 sites
  standing on the two rows that have a module.
* **R2 — our selects are `bit_select` where golden builds a `hier_path`.**
  1 441 sites corpus-wide (`POSITION-ONLY`), unmoved by this pass; `a1`'s
  `k_dotted17` is the one-file witness.
* **R3 — the PROGRAM and INTERFACE listings.**  Golden lists an unresolved
  `ref_var` loop variable for a program- or interface-homed foreach; we list a
  resolved one.  `a2`'s `pgfn17` / `iffn17`; 19 of MiniAmiq's 22 `LISTING-DIFF`
  sites are the same thing in a `DEFIFACE` view.  This is what the home gate
  keeps the law away from.
* **R4 — the one pre-existing OVER-FIRE**, unchanged by this pass:
  `LocalScopeHierPath` / testflags, `pack::uvm_mem_mam::check_reg|18:5` — our
  reference binds a `ref_var` golden leaves bare.
* **R5 — the SHADOWED loop variable.**  `a1`'s `k_shadow17`: when the loop
  variable's name already resolves in the enclosing scope, golden lists a
  `ref_var` over the existing object AND binds the body reference to the
  ORIGINAL `int_var`, in BOTH views; we bind nothing.  A separate window (the
  first arm of `declLoopVar`), deliberately untouched.
* **R6 — our unparented expression nodes.**  The census counts 157
  `orphanrefs` in BuildUVMPkg (golden 0) and 258-273 in the bigger rows:
  `ref_obj` / `bit_select` objects we emit with no `VpiParent` at all.  They
  cannot be attributed to a foreach and are reported, not hidden.

## 11. FILES

| file | what it is |
|---|---|
| `r10buvm17cen.cpp` / `build17.sh` | the foreach loop-variable bind census instrument |
| `cenall17.sh` / `cenours17.sh` | corpus-wide census, both sides / our side only |
| `cenjoin17.py` / `cencls17.py` | the multiset join and the site classifier |
| `predict17.py` | the PRISTINE-ONLY mover prediction |
| `a1_lvkinds17.sv` / `a2_homes17.sv` / `grid17.sh` | the two arms and the three-way cell table |
| `sweeps17.sh` | the sweep driver (binary asserted out of every `cmds.txt`) |
| `byteverify.sh` / `dumpdiff17.sh` / `rowheads.sh` / `detcheck17.sh` / `bound17.sh` | mover attribution, head measurement, determinism, the boundary gate |
| `canaries.sh` / `ctcan2.sh` / `canaudit.sh` | the canary battery and its audit |
