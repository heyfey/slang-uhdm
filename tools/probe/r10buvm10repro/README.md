# r10buvm10 — § enumBaseTdAliasClone10 + § enumBaseTdChainNoClone10 — **the BuildUVMPkg head cleared, one rung on**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `1a5d01e` |
| worktree | `/tmp/wt_r10buvm10` |
| pristine binary | md5 `8b5e2f68abfc42dfb43c389faa929c83` |
| patched binary | md5 `1cbb4c34040e4bca0facc551818533e1` |
| production surface | `src/TypeEmit.cpp` (ONE function, `buildEnumTs`) |
| probe surface | `tools/probe/r10buvm10repro/` only |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines.  What it does is CLEAR THE HEAD buvm9
left, and it advances to the object buvm9's own ladder named as the next rung.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` lines, default / testflags | **17** | **79** |
| heads (`grep -c '^LHS:'`) | 1 | 1 |
| head object | `ref_typespec(uvm_field_flag_t)#1710` < `bit_typespec(uvm_field_flag_t)#1706` / `RHS: <null>` | `bit_var(uvm_pkg::uvm_comparer::compare_map)@21545` < `array_var` / `RHS: <null>` |

Both modes' cmp logs are **byte-identical to each other** on both binaries.  The
new head is **exactly buvm9's patched rung 2** (`bit_var@21545 <
array_var(compare_map)`), quoted in that pass's README §5 — the ladder advanced
by one rung and landed where the previous pass predicted it would.

## 1. THE HEAD, DECODED — the owner is an ENUM'S BASE TYPE

The head is a **null-edge** head, so the field heuristic names the TARGET and
the OWNER has to be read off the object model.  `r10buvm10cen` prints every
`ref_typespec` Actual edge with the referrer's whole parent chain, and there is
exactly one edge into golden `#1706`:

```
REF G ts=bit_typespec:uvm_field_flag_t:#1706 hasalias=1 ref=#1712
      reffull=uvm_pkg::uvm_pkg::uvm_recursion_policy_enum
      chain=enum_typespec(uvm_pkg::uvm_recursion_policy_enum)#1711<package(uvm_pkg)#1<design#191741
```

The owner is the `enum_typespec`'s **`vpiBaseTypespec`**, i.e. `uvm_pkg.sv:7930`

```systemverilog
typedef bit [UVM_FIELD_FLAG_RESERVED_BITS-1 : 0] uvm_field_flag_t;   // 7859
typedef enum uvm_field_flag_t { UVM_DEFAULT_POLICY = 0, ... } uvm_recursion_policy_enum;
```

Golden's base is a **bare-named per-use COPY** of the typedef's typespec, at the
typedef's own span, instanced at the package that holds the listing, carrying
`vpiTypedefAlias` -> the QUALIFIED listing object.  Ours is the same copy with
the same name, the same span and the same instance and **no alias**:

```
TS G kind=bit_typespec name=uvm_field_flag_t      id=#1706 alias=bit_typespec:uvm_pkg::uvm_field_flag_t:#1584 aliasfull=uvm_field_flag_t inst=package:uvm_pkg:#1 instview=ELAB
TS P kind=bit_typespec name=uvm_field_flag_t      id=#3003 alias=-                                            aliasfull=-                inst=package:uvm_pkg:#2742 instview=ELAB
```

`typespec::Compare` walks `Typedef_alias`, so the missing pointer IS the head.

### the census, golden-vs-ours, BEFORE any code

`r10buvm10cen` + `aljoin` key every `ref_typespec` Actual edge **ID-blind and
address-blind** on `(actual kind:name, ref fullname, parent chain of
kinds+names)` and record whether the named object carries an alias.  Over
BuildUVMPkg (golden 18 626 edges, ours 18 104):

| key class | keys |
|---|---|
| `G=N P=N` (neither aliases) | 13 693 |
| `G=A P=A` (both alias) | 770 |
| **`G=A P=N` — golden aliases, we do NOT** | **3** |
| `G=N P=A` | 8 |
| present on one side only (per-use COPY COUNTS differ, see §5 R3) | 904 |

and after the patch, the SAME join over the SAME shapes reads **`G=A P=A` 773 /
`G=A P=N` 0** — the three disagreements are gone and nothing flipped the other
way (`G=N P=A` stays 8, all pre-existing).

and the **3** are all one shape — `actual=bit_typespec owner=enum_typespec`:

```
bit_typespec:uvm_field_flag_t   <- enum_typespec(uvm_pkg::uvm_radix_enum)            @7899
bit_typespec:uvm_field_flag_t   <- enum_typespec(uvm_pkg::uvm_recursion_policy_enum)  @7930   <- THE HEAD
bit_typespec:uvm_reg_cvr_t      <- enum_typespec(uvm_pkg::uvm_coverage_model_e)       @60757  <- the brief's sibling rung
```

**CALIBRATION FIRST, golden against golden:** the same join over the golden
database against itself reads **`G=A P=A` 913 / `G=N P=N` 13 987 / DISAGREEING
0**, and the census binary is byte-deterministic on a re-run.  A join that
cannot report zero on identical inputs cannot report three on different ones.

## 2. DECODED FROM SURELOG — this is not a new shape, it is a MISSED CALLER

`CompileHelper::compileDatastructureTypespec` (Surelog
`src/DesignCompile/CompileType.cpp` ~849-900) resolves a NAMED type by walking
the `DataType` chain.  `parent_tpd` is set on the first `TypeDef` it meets, and
then:

| datatype reached | what Surelog does |
|---|---|
| `Struct` / `Enum` / `Union` / `ClassDefinition` / `DummyType` | `result = <the shared object>; break` — **no clone, no alias** |
| **`SimpleType`** with `parent_tpd` set | `clone_tree(result)`, then `new_result->Typedef_alias()->Actual_typespec(result)` — **a per-USE clone carrying an alias back at the object it was made of** |
| a `TypeDef` that ALREADY owns a typespec (i.e. the OUTER typedef of a chain) | `result = parent_tpd->getTypespec(); break` — **no clone** |

An enum's base is one more caller of that arm: `CompileType.cpp` ~1319, the
`paEnum_base_type` case, runs the base name through `compileTypespec`.  So the
enum base takes **exactly** the shape LAW S (`bareScalarTdCopyOf`,
`src/TypeEmit.cpp` ~5929) and § `arrayElemTdClone42` (`tdVecNamedClone42`, ~628)
already build at every other position, and the kind gate our code has always had
at this site (`cl0` is only ever built for `bit_typespec` / `logic_typespec`)
is *narrower* than Surelog's `SimpleType` set — the aggregates are fenced out by
construction, not by assumption.

We minted the copy, the name, the span and the instance and left the alias null.

## 3. THE TWO LAWS

> **§ enumBaseTdAliasClone10** — the per-declaration COPY an `enum_typespec`
> binds as its `vpiBaseTypespec` when the base is written as the NAME of a
> typedef of a SIMPLE (atom/vector) type is a LAW-S copy and carries
> `vpiTypedefAlias` -> the typedef's LISTING object **of the view being
> emitted**.  The target is the object the copy was CLONED FROM (`shb`), so the
> def-view copy aliases the def listing object and the elaborated copy its
> elaborated twin without the mint site having to know which view it is in.

> **§ enumBaseTdChainNoClone10** — a **typedef-OF-typedef** base takes NO copy
> at all: the base binds the chain's LISTING object directly, QUALIFIED name and
> all, because that object already IS a named alias object
> (`CompileHelper.cpp` ~1021 gives a `typedef <name> <name>;` listing entry its
> own `Typedef_alias`), and Surelog's walk breaks at `parent_tpd->getTypespec()`
> before it can reach the clone arm.

The second law is **not** decoration: it was written because `grid10.sh` called
the first cut of the first law an **OVER-FIRE** on arm `w1v_enumbase10`'s
`t_chain` cell.  The fence is the fix, not the retreat.

### STATED GATE == CODE GATE

**STATED:** in `buildEnumTs`, inside the existing `baseSyn->kind == NamedType &&
et.baseType.kind == TypeAlias && sharedAliasTs(...)` window — the ONLY place a
typedef-named enum base is built — (a) if the base typedef's target type is
itself a `TypeAlias`, bind `shb` as the base and mint nothing; (b) otherwise,
after the existing name/span stamps on the copy, attach one `ref_typespec`
(`VpiFullName` = the BARE typedef name, `VpiParent` = the copy,
`Actual_typespec` = `shb`) as the copy's `Typedef_alias`, only if it has none.

**CODE:** `src/TypeEmit.cpp`, `git diff` vs `1a5d01e` — 74 added lines in that
one window, of which 58 are the comment.  Nothing else in the tree is touched.

## 4. THE GRID — three arms, and the one that CAUGHT the over-fire

`grid10.sh` is the three-way cell table (golden / pristine / patched) keyed on
the alias question.  Surelog and BOTH binaries run in the SAME directory (a UHDM
database records the source file's ABSOLUTE path — buvm8's `bndarms` trap).

| arm | cells | verdicts |
|---|---|---|
| `w1v_enumbase10.sv` — the enum-base position, one cell per BASE KIND + the chain cell + 3 non-typedef CONTROLS | 55 golden edges | **CONVERTED 6, OVER-FIRE 0, MOVED-STILL-WRONG 0** |
| `w2v_homes10.sv` — the SAME position at every HOME | 38 | **CONVERTED 5, OVER-FIRE 0** (+4 pre-existing name residues, §5 R2) |
| `w3v_fence10.sv` — every LAW-S position with NO enum in sight | 80 | **CONVERTED 0, OVER-FIRE 0 — a strict NO-OP** |

Cells worth naming:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| w1 `e_bit` / `e_log` | `typedef enum t_bit {...} e_bit;` at package scope | alias | **none** | **alias** |
| w1 `e_chain` | base is `typedef t_chain_base t_chain` | binds `pk10::t_chain` (QUALIFIED, its own alias) | a bare unaliased clone | **binds `pk10::t_chain`** |
| w1 `p_vec` / `p_kw` / `p_implicit` | base is `bit [7:0]` / `int` / absent | = ours | = ours | unchanged |
| w1 `e_int`/`e_byte`/`e_sint`/`e_lint`/`e_integer` | base is a typedef of an INTEGER ATOM | NAMED clone + alias | **anonymous typespec** | anonymous (**R1**) |
| w2 `pkg_e` | package scope | alias | none | **alias** |
| w2 `mod_e` / `modloc_e` | MODULE scope, imported / module-LOCAL typedef | alias | none | **alias** |
| w2 `cls_e` / `ocls_e` / `xcls_e` | class in the home pkg / in an importing pkg / in a MODULE | alias | none | **alias** |
| w2 qualified spelling (`enum pq10::q_t {...}`) | — | **SURELOG SYNTAX ERROR** (`SNT:PA0207`) | — | UNMEASURABLE, recorded as such |

The alias answer over arm w2's six `q_t` base edges is **6/6 golden `hasalias=1`,
6/6 pristine `hasalias=0`, 6/6 patched `hasalias=1`** — printed in full in §8's
reproduce block, because "the class cells only differ by a name" is a claim that
has to be shown, not asserted.

## 5. RESIDUES, each measured and left deliberately

* **R1 — the INTEGER-ATOM base kinds.**  For `typedef enum t_int {...}` golden
  mints a NAMED `int_typespec 't_int'` with an alias; we fall through to the
  keyword-base arm and mint an ANONYMOUS `int_typespec`.  Same for
  `byte`/`shortint`/`longint`/`integer` (arm w1, five cells, all G=A / P=N=
  anonymous / Q=anonymous — **unchanged by this pass**).  It is the same Surelog
  arm and § `tdAtomKindGate43`'s same kind set, but it is a DIFFERENT defect (a
  missing NAME and a missing object, not a missing pointer) and it does not
  occur on uvm_pkg, whose enum bases are all `bit` typedefs.  Named, not fixed.
* **R2 — the base ref's `VpiFullName` for a CLASS-scope or MODULE-INSTANCE enum
  typedef.**  Golden writes `pq10::cin10::cls_e` / `uvm_pkg::uvm_resource_types::override_e`;
  we write `cls_e` / `override_e`.  **Byte-for-byte identical on both binaries**
  (arm w2, §8's quote) — a pre-existing naming residue this pass makes visible
  in the grid key and does not touch.
* **R3 — the per-use COPY COUNT.**  Golden holds 1 069 aliased typespecs in
  BuildUVMPkg (368 `uvm_reg_data_t`, 260 `uvm_reg_addr_t`, 87 `type_id`, …) and
  we hold 346.  This is BY DESIGN and is stated in LAW S's own comment: Surelog
  mints one copy per DECLARATION, uhdm-cmp does not compare object identity, so
  ONE memoized copy per listing object suffices.  It is the whole of the 904
  one-sided keys in §1's table and it is not a cmp fact.
* **R4 — buvm9's R1 alias-chain family is NOT this mechanism, and stays R1.**
  `uvm_pkg::UVM_SEQ_ARB_TYPE` / `uvm_sequence_state` / `uvm_sequence_state_enum`
  / `uvm_severity_type` are golden-ELAB / ours-DEF on **`vpiInstance`**, and
  their object is a LISTING entry minted by `CompileHelper::compileDataTypes`
  with `tpclone->Instance(scope->getUhdmInstance())` (Surelog
  `CompileHelper.cpp` ~1021).  This pass's object is a per-USE clone minted by
  `CompileType::compileDatastructureTypespec` and its field is
  `Typedef_alias`.  Different function, different field, different law — and
  measured: the whole-dump diff (§6) shows those objects byte-for-byte
  unchanged.
* **R5 — the NEW head is R0 and it is not this family.**
  `uvm_pkg::uvm_comparer::compare_map` (`uvm_pkg.sv:21545`, an associative array
  `uvm_object[uvm_object]`): golden's `array_var` holds a `bit_var` ELEMENT and
  ours holds none (`RHS: <null>`).  Pre-existing — it is buvm9's patched rung 2,
  named there before this pass existed.

## 6. THE WHOLE-DUMP PATH-NORMALISED DIFF — 7 additions, 0 removals

`uhdm-dump` on both BuildUVMPkg databases, workdir path and every `id:`/`#id`
normalised away:

```
lines P=1075062 Q=1075111     diff sides: 49     '<' sides: 0
```

**49 added lines = 7 `vpiTypedefAlias` blocks and nothing else**, and they are
exactly the 7 objects §7 predicted BY NAME from the pristine database:

| object | owner | view |
|---|---|---|
| `bit_typespec(uvm_field_flag_t)@7859:9` | `enum_typespec(uvm_pkg::uvm_radix_enum)` base | DEF + ELAB |
| `bit_typespec(uvm_field_flag_t)@7859:9` | `enum_typespec(uvm_pkg::uvm_recursion_policy_enum)` base | DEF + ELAB |
| `bit_typespec(uvm_reg_cvr_t)@60757:10` | `enum_typespec(uvm_pkg::uvm_coverage_model_e)` base | DEF + ELAB |
| `bit_typespec(override_t)@15198:11` | `enum_typespec(uvm_resource_types::override_e)` base | class scope |

The 7th — `uvm_resource_types::override_t`, a **CLASS-scope** typedef — was NOT
in the brief and was NOT predicted by the head; the census found it and golden
confirms it cell for cell (`#169363` listed & unaliased, `#169364` clone aliased
to it; ours `#5930` / `#5935`, the same pair).  A law measured only where the
head pointed would have been a law with an unmeasured half.

## 7. THE MOVERS, PREDICTED BY NAME BEFORE ANY BYTE WAS COMPARED

`predict10.sh` reads ONLY the PRISTINE databases (never the patched ones, never
golden) and names every object the two laws can touch, out of the object model:

* **CAND A** — a NAMED `bit_`/`logic_typespec` that is a `ref_typespec` Actual
  whose PARENT is an `enum_typespec` and that carries NO alias (the law ADDS one)
* **CAND B** — the same edge where the actual's name is QUALIFIED and it DOES
  carry an alias (a candidate for the CHAIN cell)

Both rules OVER-predict on purpose and say so.

| corpus | databases | CAND A | CAND B | candidate DATABASES |
|---|---|---|---|---|
| uhdm2rtlil | 1 358 | **0** | 0 | **0** |
| surelog | 955 | **35** | **0** | **9**: `{default,testflags}/{BuildUVMPkg,MiniAmiq,SeqDriver,SimpleUVM}` + `default/Scoreboard` |

`CAND B = 0` over both corpora is the statement that
§ `enumBaseTdChainNoClone10` is a **strict no-op on the corpus** — no test has an
enum whose base is a chained typedef; the law exists because arm
`w1v_enumbase10` measured it and it fences the first law, not because a row
needed it.  The 9 CAND-A databases are EXACTLY the 9 byte movers gate 5 then
found (§9), predicted before the comparison ran.

## 8. THE LADDER — 134 rungs REMOVED, **0 ADDED**

`tools/probe/r10ladder1repro/ctladder` (the official `design::Compare` run to
fixpoint by masking each head).  MEASUREMENT ONLY; `uhdm-cmp` is the judge.
Calibration on this pass's golden against itself: **0 rungs on 183 142
objects**.

| | pristine | patched |
|---|---|---|
| rungs (fixpoint) | **335** | **129** |
| stop | FIXPOINT | FIXPOINT |
| masks / cascades (`[S]` line) | 388 / 154 | 129 / 71 |
| secs | 334 | 96 |
| rung 1 | `ref_typespec#1710` / `<null>` | `bit_var@21545` < `array_var(compare_map)` |

Rung-list diff by normalised LHS object: **134 removed, 0 ADDED** — every rung
the patched walk climbs was already a pristine rung, and the brief's named
sibling `bit_typespec(uvm_reg_cvr_t)@60757:10` is among the removed.

**The -134 is mostly the INSTRUMENT, and it is said out loud rather than
claimed as 134 fixed objects.**  To get past its rung 1 the pristine ladder had
to MASK the alias-less object, and a mask CASCADES — the pristine walk needed
335 masks where the patched walk needs 129, and each dropped mask un-exposes the
rungs that mask made reachable.  The AUTHORITATIVE numbers are the official
`uhdm-cmp` head (THE HEADLINE) and the **7** attributed byte movers (§6, §9).

## 9. THE FIVE GATES

| # | gate | result |
|---|---|---|
| 1 | build BOTH binaries, `-j 2`, md5 separately | pristine `8b5e2f68abfc42dfb43c389faa929c83`, patched `1cbb4c34040e4bca0facc551818533e1`. The deliverable was then applied to a THIRD, untouched `1a5d01e` worktree (`/tmp/wt_r10buvm10_verify`, `git apply --check` clean) and built from scratch: md5 **`1cbb4c34040e4bca0facc551818533e1`** — the patch reproduces, bit for bit, the binary every reading above was taken with. |
| 2 | `tests/check_goldens.sh` + negative control | **23** PASS on the pristine, the patched AND the from-scratch reproduction; `SLANG_UHDM=/bin/false` -> **0** PASS. `SLANG_UHDM` exported explicitly to EACH binary. |
| 3 | uhdm2rtlil, both modes | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in each mode on each binary; `ct10rows.sh` pristine-vs-patched = **0 differing ROWS** over 1 462, and the patched `testflags` half vs the COMMITTED `results/gate_uhdm2rtlil.csv` = **0 differing ROWS** over 731 (status AND dump column). |
| 4 | Surelog suite, `--mode both` | `ct10rows.sh` patched vs the COMMITTED `results/golden_surelog.csv` = **0 differing rows** over 1 588; same against the pristine sweep.  Status histograms identical, dump histograms identical.  **NO ROW CONVERTED — `BuildUVMPkg` stays `CMP_NOTEQUAL` in both modes and `results/*.csv` were not touched.** |
| 5 | `byteverify.sh SELFCHECK=1 SELFCHECK1=1` | surelog **9 / 955** movers, u2r **0 / 1 358**.  Every mover PREDICTED BY NAME first (§7: 35 candidate objects in exactly those 9 databases, 0 CAND B) and ATTRIBUTED by `attrib10.sh` (`0 NOT ATTRIBUTED`).  Controls: 954/955 + `SELFCHECK1`=10 (1 corruption + the 9 real movers), and 1357/1358 + `SELFCHECK1`=1. |

Movers, attributed one database at a time (dump lines added / removed, alias
blocks):

| database | dump | alias blocks | verdict |
|---|---|---|---|
| `{default,testflags}/BuildUVMPkg` | +49 / **-0** | 7 | ATTRIBUTED |
| `{default,testflags}/MiniAmiq` | +21 / **-0** | 3 | ATTRIBUTED |
| `{default,testflags}/SeqDriver` | +21 / **-0** | 3 | ATTRIBUTED |
| `{default,testflags}/SimpleUVM` | +21 / **-0** | 3 | ATTRIBUTED |
| `default/Scoreboard` | +21 / **-0** | 3 | ATTRIBUTED |

`MiniAmiq` is `SLANG_REJECT` on both binaries and still writes a database, so it
moves bytes without moving a row — which is exactly why gate 5 exists.

### the canary battery, all pristine-vs-patched

| check | result |
|---|---|
| `canaries.sh` on the surelog CSV | `ok=52 changed=0 absent=0`, 7 expected unknown names (the u2r-only canaries) |
| `canaries.sh` on the u2r CSV | `ok=8 changed=0 absent=0`, 25 expected unknown names |
| `ctcan2.sh` surelog (`EXPECT_UNKNOWN=1`) / u2r (`EXPECT_UNKNOWN=6`) | `ok=58 changed=0` / `ok=1 changed=0` — **PASS** both |
| `canaudit.sh canaries.sh ctcan2.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0`, both self-tests live |
| `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` | **not in the mover list => byte-identical** |
| `SVSwitch` md5 pin | `4842211c4030` on the PATCHED binary, both modes |
| `YosysVerx` md5 pin | `6ccda350c24a` on the PATCHED binary, both modes |
| determinism (`detcheck.sh`, 3 runs each on w1 and w2) | 1 distinct hash, 0 NO_OUTPUT |

### the SEVEN-ROW HEAD SET, both binaries, out of the FULL sweep workdirs

| row | mode | pristine | patched | cmp log |
|---|---|---|---|---|
| `BuildUVMPkg` | default, testflags | 17 lines / 1 head | **79 / 1** | the head MOVED (§ THE HEADLINE) |
| `SeqDriver` | default, testflags | 38 / 1 | 38 / 1 | **identical once `id:` is normalised — a pure arena-id shift of +3** |
| `SimpleUVM` | default, testflags | 38 / 1 | 38 / 1 | same, pure id shift |
| `Scoreboard` | default | 38 / 1 | 38 / 1 | same, pure id shift |
| `MiniAmiq` | default, testflags | 38 / 1 | 38 / 1 | same, pure id shift |
| `Earlgrey_0_1` | default | 20 / 1 | 20 / 1 | **BYTE-IDENTICAL** |
| `Rggen` | default | 64 / 1 | 64 / 1 | **BYTE-IDENTICAL** |
| `YosysVerx` | default, testflags | 0 / 0 | 0 / 0 | **BYTE-IDENTICAL** (CMP_EQUAL, and the md5 pin holds) |

The four id-shift rows are the point: their DATABASES moved (3 alias additions
each, §9) and their HEADS did not, because on those rows the new aliases sit
BEHIND the existing head.  A cmp-line count alone would have called them
"unchanged"; the byte verifier is what saw them, and `attrib10.sh` is what
attributed them.  `Scoreboard testflags`, `Earlgrey_0_1 testflags` and `Rggen
testflags` print SKIP-NOFILE and are COUNTED, not hidden.

### the boundary gate

`bndsub10v.sh` over **455** arm sources — `r10buvm3..9`, `r10uvm82/83` and
`r10sd8..12` (whose arms live in SUBDIRECTORIES, buvm9's lesson) — on both
binaries:

```
-- arms PROCESSED=455 IDENTICAL=449 MOVED=0 REJECT-BOTH=6 ONE-SIDE=0
```

**AND A GATE BUG WAS FOUND AND FIXED HERE, WHICH IS WHY THE COUNT IS PRINTED.**
The inherited script read its file list from STDIN and the two `slang-uhdm`
invocations inside the loop ALSO read STDIN, so the first invocation swallowed
the whole list and the gate printed
`IDENTICAL=0 MOVED=0 REJECT-BOTH=0 ONE-SIDE=0` — a GREEN LINE FROM A GATE THAT
RAN NOTHING.  A second run with paths relative to the wrong cwd `continue`d past
all 455 silently and printed the same green line.  The list now travels on fd 3,
every child gets `</dev/null`, a path that does not resolve is FATAL, and the
PROCESSED count is asserted non-zero.

## 10. reproduce
```sh
./build10.sh                                            # the census instrument
/tmp/r10buvm10cen <golden.uhdm> G > g.cen                # census golden ...
/tmp/r10buvm10cen <ours.uhdm>   P > p.cen                # ... and ours
./aljoin10.py g.cen p.cen                               # the alias join
./aljoin10.py g.cen <(sed 's/ G / P /' g.cen)           # the golden-vs-golden CALIBRATION
./attrib10.sh <patched wd> <pristine wd> <rel>/slang.uhdm ...
PRISTINE=<1a5d01e bin> PATCHED=<patched bin> ./grid10.sh w1v_enumbase10.sv
PRISTINE=... PATCHED=... ./grid10.sh w2v_homes10.sv      # the HOMES arm
PRISTINE=... PATCHED=... ./grid10.sh w3v_fence10.sv      # the FENCE arm (no-op)
./allsweeps10.sh                                        # four sweeps, one at a time, --jobs 2
./predict10.sh /tmp/r10buvm10_wds_pristine              # PREDICT FIRST
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh /tmp/r10buvm10_wds_patched /tmp/r10buvm10_wds_pristine
./ct10rows.sh <baseline.csv> <fresh.csv>
./canaries.sh <fresh.csv> <baseline.csv>; EXPECT_UNKNOWN=<n> ./ctcan2.sh ...
bash canaudit.sh canaries.sh ctcan2.sh
PRISTINE=... PATCHED=... ./bndsub10v.sh < <list of ABSOLUTE arm paths>
./rowheads.sh <workdir> <outdir> BuildUVMPkg
./detcheck.sh <bin> 3 w1v_enumbase10.sv
```

The ladder is `tools/probe/r10ladder1repro/ctladder.cpp`, built with the line in
that directory's README and run `<golden> <ours>`.
