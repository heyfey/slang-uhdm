# r10uvm140 — § `retNamedTdWinsOverCanon140` — **THE RETURN TYPE'S OWN TYPEDEF** — the `uvm_sequence_state_enum` head CLEARED on THREE row-modes, 22 cells in 9 databases, 0 corpus rows changed

**MEASUREMENT-ONLY directory.** Nothing in it is an acceptance judge. The
official `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py`
are the authorities for every number below. slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **nothing was promoted** and **NO CORPUS ROW
CONVERTED**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `c966463` (= UVM pass 138) |
| pristine binary | built from a clean worktree at `c966463`, frozen `chmod 555` before any sweep; its head logs reproduce the brief's head object for object |
| patched binary | frozen `chmod 555` before any sweep |
| production surface | `src/TaskFuncEmit.cpp` ONLY — **one block**, the return-type typespec lookup |
| probe surface | `tools/probe/r10uvm140repro/` only |

## READ THIS FIRST — the numbers

| row-mode | pristine | patched |
|---|---|---|
| **SimpleUVM default / testflags** | 334 cmp lines, head = golden's `enum_typespec (uvm_pkg::uvm_sequence_state_enum)` vs our `enum_typespec (uvm_pkg::uvm_sequence_state)` | **head CLEARED** — 29 lines to a NEW head of a different family |
| **Scoreboard default** | 334, the same head | **head CLEARED**, the same new head |
| SeqDriver default / testflags | 58, 1 head (a different family) | head log **BYTE-IDENTICAL** — its 6 cells sit below the head |
| MiniAmiq default / testflags | 58, 1 head (a different family) | head log **BYTE-IDENTICAL** — its 6 cells sit below the head |
| BuildUVMPkg default / testflags | 83, 1 head | head log **BYTE-IDENTICAL** — its 4 cells sit below the head |
| Earlgrey_0_1 default / testflags | 17, 1 head | head log **BYTE-IDENTICAL** |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL), byte-identical |
| corpus rows changed | — | **0** on BOTH corpora, BOTH modes, against the committed baselines AND against this pass's own pristine sweeps |
| byte movers | — | **9 / 956** surelog, **0 / 1358** uhdm2rtlil — exactly the nine **PREDICTED BY NAME** from the pristine databases before the patched sweep ran |
| the law's corpus population | 22 wrong cells / 44 wrong bindings over 9 databases | **0** — `diff=0`, `onlygold=0`, `onlyours=0` on every one |
| the law's grid population | 54 wrong cells (arms a/b/c/d, DEF **and** ELAB views) | **0** — `MOVED-WRONG 0`, `AWAY 0`, typespec object counts UNCHANGED |

---

## 1. THE HEAD, RE-MEASURED ON THIS PASS'S OWN PRISTINE BUILD FIRST

`uvm-1.2 src/base/uvm_object_globals.svh:399-412` declares an enum and then a
**backward-compat ALIAS of that typedef**:

```systemverilog
typedef enum {
  UVM_CREATED = 1, ... UVM_FINISHED = 256
} uvm_sequence_state;                                   // 399-410

typedef uvm_sequence_state uvm_sequence_state_enum;     // 412 "backward compat"
```

and `src/seq/uvm_sequence_base.svh:200` writes a method whose RETURN TYPE
spells the ALIAS:

```systemverilog
function uvm_sequence_state_enum get_sequence_state();
   return m_sequence_state;
endfunction
```

```
LHS (golden)                                RHS (ours, pristine)
enum_typespec (uvm_pkg::                    enum_typespec (uvm_pkg::
              uvm_sequence_state_enum)                    uvm_sequence_state)
|vpiName:uvm_pkg::uvm_sequence_state_enum   |vpiName:uvm_pkg::uvm_sequence_state
|vpiTypedefAlias: ref_typespec              (no vpiTypedefAlias)
   -> enum_typespec (uvm_pkg::uvm_sequence_state)
|vpiInstance: package uvm_pkg               |vpiInstance: package uvm_pkg
|vpiEnumConst: x9 (UVM_CREATED..UVM_FINISHED, identical values on both sides)
```

**The head is a BINDING, not a missing object.** The walk reaches the pair
through

```
design -> uhdmtopPackages -> package uvm_pkg -> vpiClassDefn uvm_sequence_base
       -> vpiMethod get_sequence_state -> vpiReturn enum_var
       -> vpiTypespec ref_typespec -> vpiActual  <-- HERE
```

and `BaseClass::Compare`'s first comparison after the type tag is `VpiName`,
so the two objects first-fail on the name; `typespec::Compare` then walks
`Typedef_alias` before `Instance`, and ours has none.

**We already MINT golden's object.** Our `uvm_pkg::uvm_sequence_state_enum`
enum_typespec is in the package's `vpiTypedef` listing at the same index as
golden's (the two listings are NAME-IDENTICAL, 89 entries each), and its own
fields are byte-identical to golden's on every field `Compare` reads — the
whole-object diff between golden's copy and ours is three lines, all of them
`vpiParent` / `vpiFullName`, and **no generated `Compare` reads either**.
Nothing had to be minted, re-parented, or re-named. Only the FUNCTION RETURN
pointed at the wrong one of the two.

## 2. THE DECODED MODEL — Surelog resolves a return type BY NAME; we resolved it by CANONICAL TYPE

`src/TaskFuncEmit.cpp`, the return-type arm, read:

```cpp
UHDM::typespec* ts = nullptr;
auto& retCanon = sub.getReturnType().getCanonicalType();
if (retCanon.kind == PackedStructType || UnpackedStructType || EnumType)
    for (auto& [sym, tsp] : typedefTs)                 // std::map keyed by POINTER
        if (sym->kind == TypeAlias &&
            &sym->as<TypeAliasType>().getCanonicalType() == &retCanon) {
            ts = tsp; break;                           // "SOME alias of this type"
        }
```

The scan answers *"some `TypeAlias` whose canonical type is this one"*. With an
alias OF a typedef there are **two** such aliases (`uvm_sequence_state` and
`uvm_sequence_state_enum`) over ONE canonical enum, and the answer was
whichever the pointer-keyed `std::map` held first — the BASE, on every one of
the nine databases.

Surelog never had that ambiguity: `CompileHelper::compileTypespec`'s named arm
resolves the return token as a **datatype lookup by name** and hands back the
typespec registered for the datatype the token spells, so golden's binding is
always the typedef the source WROTE. `UhdmWriter::writeDataTypes`
(`src/DesignCompile/UhdmWriter.cpp:775-809`) is what gives that object the
qualified `uvm_pkg::` name and, later, the `class_defn` parent it wears in the
dump — a LAST-WRITER-WINS re-parent that `Compare` cannot see and that this
pass therefore does not model.

**The fix is the name lookup, put in front of the scan:**

```cpp
if (auto& rdt140 = sub.getReturnType(); rdt140.kind == SymbolKind::TypeAlias)
    if (auto it140 = typedefTs.find(&rdt140); it140 != typedefTs.end())
        ts = it140->second;          // the typedef the return type NAMES
if (!ts)
    ...the old canonical scan, unchanged...
```

Every return type that is **not** a registered `TypeAlias` (an anonymous enum,
a `$unit` duplicate alias instance, an alias whose own object was never listed)
falls through to the old scan and keeps its old answer — which is why the whole
uhdm2rtlil corpus is byte-identical and why the base-returning twin of every
grid cell is a `SAME-OK` control.

### What the law does NOT claim

* It does not touch the **argument** path: `io_decl`s already bound the named
  alias (`set_arbitration(UVM_SEQ_ARB_TYPE val)` reads `UVM_SEQ_ARB_TYPE` in
  both databases, pristine included) — 3/3 on SimpleUVM.
* It does not touch the **union** path: a packed union alias return already
  bound the named alias (arm A `readAliasSample` -> `Chrome_pkg::SampleWord_u`
  on both sides, pristine included). `PackedUnionType` is not one of the three
  kinds the block gates on and was deliberately left out.
* It does not touch the **vector** path: `retCanon.kind` for
  `typedef logic[11:0] rulerBits; typedef rulerBits RulerBits_v;` is not one of
  the three kinds, so the per-function BARE clone that arm A measures
  (`logic_typespec (RulerBits_v)` against golden's
  `logic_typespec (Chrome_pkg::RulerBits_v)`) is UNCHANGED — recorded as
  residue **R1** below, not fixed here.
* It does not touch the **return-var KIND**: golden emits a `ref_var` where we
  emit an `enum_var`/`struct_var` for one copy of a function declared at
  PACKAGE scope (uvm's out-of-body `uvm_sequencer_base::get_arbitration`; arm
  A/B `pkgOre` / `pkgIon` / `Harbour_pkg::pkgTideAlias`). Recorded as residue
  **R2**.

---

## 3. THE CENSUS — the law's corpus population, golden vs ours, over the NINE UVM databases

`ct140cen.cpp` reads BOTH databases' `Serializer::AllObjects`, keys every
`function` by `VpiFullName`, and records the **sorted multiset** of typespec
names its return variable's `ref_typespec` binds (enum / struct kinds only).
Golden-vs-golden calibration is implicit: `same=` counts the cells the two
producers already agree on, and they are the majority everywhere.

| database | cells | pristine `diff` | patched `diff` | `onlygold` / `onlyours` |
|---|---|---|---|---|
| SeqDriver default | 42 | 3 | **0** | 0 / 0 |
| SeqDriver testflags | 42 | 3 | **0** | 0 / 0 |
| SimpleUVM default | 34 | 2 | **0** | 0 / 0 |
| SimpleUVM testflags | 34 | 2 | **0** | 0 / 0 |
| Scoreboard default | 35 | 2 | **0** | 0 / 0 |
| MiniAmiq default | 50 | 3 | **0** | 0 / 0 |
| MiniAmiq testflags | 50 | 3 | **0** | 0 / 0 |
| BuildUVMPkg default | 44 | 2 | **0** | 0 / 0 |
| BuildUVMPkg testflags | 44 | 2 | **0** | 0 / 0 |
| Earlgrey_0_1 default / testflags | 1 / 1 | 0 | 0 | 0 / 0 |
| Rggen default | 1 | 0 | 0 | 0 / 0 |
| **total** | **378** | **22 cells / 44 bindings** | **0** | **0 / 0** |

The 22 cells come from just TWO source declarations, both of them
`uvm_object_globals.svh` "backward compat" aliases (`:370` and `:412`):

| function | golden binds | we bound |
|---|---|---|
| `uvm_pkg::uvm_sequence_base::get_sequence_state` | `uvm_pkg::uvm_sequence_state_enum` | `uvm_pkg::uvm_sequence_state` |
| `uvm_pkg::uvm_sequencer_base::get_arbitration` (3 copies) | `uvm_pkg::UVM_SEQ_ARB_TYPE` | `uvm_pkg::uvm_sequencer_arb_mode` |
| `adpcm_pkg::…::get_arbitration` (SeqDriver) / `svaunit_pkg::…::get_arbitration` (MiniAmiq), 2 copies each — the nested second UVM copy those two designs carry | `uvm_pkg::UVM_SEQ_ARB_TYPE` | `uvm_pkg::uvm_sequencer_arb_mode` |

**THE CORPUS NEGATIVE CONTROL.** `uvm_object_globals.svh` carries a THIRD
backward-compat alias, `typedef uvm_severity uvm_severity_type;`, and two
functions return the **BASE**: `uvm_pkg::uvm_report_catcher::get_severity` and
`uvm_pkg::uvm_report_message::get_severity`. `pred140` names them as candidates
(the canonical scan had two answers there too), golden binds `uvm_pkg::
uvm_severity` on both, and the patched databases still bind `uvm_pkg::
uvm_severity` — the named-typedef lookup returns the base because the base is
what the source spelled. They are in the census's `same=` column before and
after, and they are why the law cannot over-fire on an alias GROUP.

`onlygold=0 onlyours=0` on every database, and `objcnt140` (DISTINCT objects in
the Serializer arena, not dump occurrences) reads **identical typespec counts
in the pristine and the patched database for all nine movers** — the law
re-points a pointer and mints nothing. That is the **AWAY 0** score.

## 4. THE GRID — four arms, both views, 54 cells

`runarms140.sh` builds every `g140_*.sv` with Surelog (`-parse` and
`-parse -elabuhdm`) and with both frozen binaries in both views, censuses each
database with `cen140.py`, and scores with `score140.py`.

| arm | axis | DEF | ELAB |
|---|---|---|---|
| `g140_a_kinds.sv` | enum / struct / union / vector typedef x base / alias / 2-deep chain / second-alias-of-one-base, in a package class and at package scope | TOGOLD 7, SAME-OK 3, MOVED-WRONG 0 | TOGOLD 7, SAME-OK 3, MOVED-WRONG 0 |
| `g140_b_homes.sv` | seven HOMES: `$unit` function, `$unit` class method, package function, in-body package-class method, OUT-OF-BODY package-class method (the `get_arbitration` shape), module function, module-class method | TOGOLD 10, SAME-OK 7, MOVED-WRONG 0 | TOGOLD 10, SAME-OK 7, MOVED-WRONG 0 |
| `g140_c_import.sv` | the alias in a DIFFERENT package from its base, reached by wildcard import / explicit single import / fully-qualified `pkg::name` return type; three aliases of one base | TOGOLD 7, SAME-OK 3, MOVED-WRONG 0 | TOGOLD 7, SAME-OK 3, MOVED-WRONG 0 |
| `g140_d_inst.sv` | 1 / 2 / 3 instances of the alias-returning module, plus a parameterised class specialised twice | TOGOLD 3, SAME-OK 2, MOVED-WRONG 0 | TOGOLD 3, SAME-OK 2, MOVED-WRONG 0 |

**54 TOGOLD, 0 MOVED-WRONG, 0 AWAY, 30 SAME-OK controls.** All eight arm
databases MOVED (byte hashes) — an arm that agrees without moving is not an arm
that tests. The one `STILL-WRONG` row per arm is `work@process::status`, our
built-in `process` class stub, which golden does not emit at all (`GOLD=None`);
it is identical in pristine and patched and predates this pass.

Arm names are deliberately non-parallel (`metalKind`/`MetalKind_e`/
`metal_kind_t`/`OreKind_e`, `tideMode`/`TideMode_e`/`tide_mode_t`,
`stoneGrade`/`StoneGrade_e`/`grade_kind_t`/`GradeChain_e`,
`heatBand`/`HeatBand_e`/`heat_band_t`): a grid that calls everything
`a_t`/`b_t`/`c_t` over `A`/`B`/`C` is self-confirming, and the declaration ORDER
is what the pristine bug keyed on.

## 5. THE BOUNDARY — 4059 arms, 6 moved, both strangers move TOWARD golden

`bound140.sh` runs from a COPY of the whole `tools/probe` tree so no path
filter can hide an arm; the file list is read on fd 3, children get
`</dev/null`, scratch is keyed on the RELATIVE path, `PROCESSED` is asserted
against `LISTED`, and this pass's own four arms are the POSITIVE CONTROL.

```
LISTED=4059 PROCESSED=4059 PRODUCED_DBS=3915 MOVED_ARMS=6 RC_DIFFS=0
```

Four movers are this pass's own arms. The other two are earlier-pass arms of
the SAME law, re-measured against golden:

* **`r10buvm22repro/g22b.sv`** — `typedef qs_t cn_tdstruct_t;` /
  `typedef qe_t cn_tdenum_t;` (class-scope aliases of package typedefs)
  returned by `L22::lc_n_tdstruct()` / `lc_n_tdenum()`.
  **TOGOLD 2, MOVED-WRONG 0** in BOTH views: golden binds `cn_tdstruct_t` /
  `cn_tdenum_t`, we bound `q22::qs_t` / `q22::qe_t` and now bind golden's.
  `objcnt140` reads 38/38 (DEF) and 43/43 (ELAB) — nothing minted; the
  dump-occurrence counter's `49 -> 52` on the ELAB view is the two objects
  becoming REACHABLE plus a weaklyReferenced-tail reorder, and the tail is
  unreachable to the judge.
* **`r10buvm9repro/w6v_clsalias.sv`** — `typedef w6p::b_s n3_s;` returned by
  `w6k::f3()`. The whole-dump diff is **ADDITIONS ONLY** — one hunk in the DEF
  view, two in the ELAB view (the second of those is the same object printed
  again in the weaklyReferenced TAIL, which is unreachable to the judge). Our
  class-scope `struct_typespec (n3_s)` now carries
  `vpiInstance: package w6p` in both views — **which is exactly what golden's
  object carries**: golden's `n3_s` entry in the same `class_defn (w6p::w6k)`
  `vpiTypedef` listing reads `vpiInstance: package w6p` in BOTH views, right
  after its `vpiTypedefAlias -> struct_typespec (w6p::b_s)`. Nothing was
  removed; `objcnt140` reads
  19/19 and 30/30. The arm's cmp line count rises 6982 -> 6986 / 7430 -> 7434
  because that arm's head is the whole `design` object, so the count is the
  head's decompile SIZE and our side gained the field golden already had.

## 6. RESIDUES

* **R0 (the NEXT head on SimpleUVM x2 + Scoreboard/default, 29 cmp lines).**
  `LHS: <null>` against OUR `io_decl (obj)` on
  `uvm_pkg::uvm_objection::wait_for` (`uvm_objection.svh:897`,
  `task wait_for(uvm_objection_event objt_event, uvm_object obj=null);`).
  A `<null>` LHS with a full RHS on a vector element is the VECTOR
  `SafeCompare` overload on a SIZE MISMATCH: golden's `Io_decls` vector is
  SHORTER than ours — a SURPLUS io_decl on our side, the `Io_decls` count law
  for a task whose second formal has a DEFAULT VALUE. That is the next pass's
  head.
* **R1 — the VECTOR alias return keeps a BARE per-function clone.** Arm A
  `Chrome_pkg::Assay::readAliasRuler` (`typedef logic [11:0] rulerBits;
  typedef rulerBits RulerBits_v;`): golden binds the LISTING object
  `Chrome_pkg::RulerBits_v`, we mint a bare-named clone `RulerBits_v`. The
  vector path is `retCanon.kind`-excluded from this law by construction, and
  the existing bare-clone rule (a method of a package class gets a bare clone,
  measured on `uvm_reg_data_t` / `uvm_action`) is right for a typedef of a
  BUILT-IN type and wrong for an ALIAS OF A TYPEDEF. Unfixed here; it needs
  its own arm table.
* **R2 — the return-var KIND for a PACKAGE-SCOPE function returning an alias.**
  Golden emits a `ref_var` where we emit an `enum_var`/`struct_var` for ONE of
  the copies: `uvm_pkg::uvm_sequencer_base::get_arbitration` (out-of-body,
  compiled at package scope) reads 2 `enum_var` + 1 `ref_var` in golden and
  3 `enum_var` in ours; arm A/B reproduce it on `Chrome_pkg::pkgOre`,
  `Chrome_pkg::pkgIon` and `Harbour_pkg::pkgTideAlias`. Both sides bind the
  SAME typespec after this pass, so the residue is the VARIABLE's class, not
  the binding.
* **R3 — `work@process::status`.** Our built-in `process` class stub emits a
  return `enum_var` bound to `enum_typespec (state)`; golden emits no such
  function. Present identically in pristine and patched on every arm.
