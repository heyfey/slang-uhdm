# r10buvm11 — § bitElemSharesArrayRanges11 — **the BuildUVMPkg head cleared; the array_var's ELEMENT range vector**

**MEASUREMENT-ONLY probes.**  Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` and `scripts/verify_golden.py` are the authorities for
every number below.  slang was **not** patched; `results/*.csv` were **READ
ONLY** and **nothing was promoted**.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, matching
`uhdm-cmp <golden.uhdm> <ours.uhdm>`, in every table here and in every script.

| | |
|---|---|
| BASE | `e359f0a` |
| worktree | `/tmp/wt_r10buvm11` |
| pristine binary | md5 `f6d7a09beb97347361bda03a47b92428` |
| patched binary | md5 `3aafd7fcd0915f9dc1d91614da73d618` |
| production surface | `src/UhdmExporter.cpp` — ONE `if`, in the class-property array arm |
| probe surface | `tools/probe/r10buvm11repro/` only |

## THE HEADLINE

`BuildUVMPkg` **still reads `CMP_NOTEQUAL` in both modes — this pass does NOT
make it pass**, and **no corpus row converted**: gates 3 and 4 are `0 differing
ROWS` against the committed baselines.  What it does is CLEAR the head buvm10
left — the object buvm9 named as its rung 2 two passes before this one existed.

| | pristine | patched |
|---|---|---|
| `uhdm-cmp` lines, default / testflags | **79** | **47** |
| heads (`grep -c '^LHS:'`) | 1 | 1 |
| head object | `bit_var(uvm_pkg::uvm_comparer::compare_map)@21545` < `array_var` / `RHS: <null>` | `function(uvm_pkg::uvm_comparer::get_recursion_policy)@21000` < `class_defn` / `RHS: <null>` |

Both modes' cmp logs are **byte-identical to each other** on both binaries, and
the other six rows of the seven-row head set are **byte-identical between the
two binaries** (§9).

## 1. THE HEAD, DECODED — the owner is the ELEMENT, and the field is `vpiRange`

The source is `uvm_pkg.sv:21545`, a class property of `uvm_comparer`:

```systemverilog
bit compare_map[uvm_object][uvm_object];   // TWO associative dims, `bit` element
```

The head is a **null-edge** head, so the ladder's field heuristic names the
TARGET.  `ctladder`'s rung-1 record says `KINDL=bit_var KINDR=<null>
KINDP=array_var SHAPE=MISSING-OURS`, and its `MK` line masks the `array_var`.
**That reading is one level too shallow and the dump says so.**  Both databases
have the `array_var`, both have its `vpiReg` element, and both agree on every
field of both:

```
      |vpiReg:                                          <- array_var::Variables(), and it is
      \_bit_var: (uvm_pkg::uvm_comparer::compare_map)       PRESENT AND EQUAL ON BOTH SIDES
        |vpiParent:   \_array_var: (...compare_map)
        |vpiTypespec: \_ref_typespec -> bit_typespec 21545:3-21545:6
        |vpiFullName: uvm_pkg::uvm_comparer::compare_map
        |vpiRange:                                      <- GOLDEN ONLY.  THE DEFECT.
        \_range: , line:21545:30, endln:21545:42
```

So, stated the way the brief asked: **the array_var field that holds golden's
`bit_var` is `Variables()` (dumped as `vpiReg`), and it is NOT the difference.
The OWNER of the failing vector is the `bit_var` itself and the FIELD is its own
`Ranges()` (`vpiRange`).**  `array_var::Compare` walks `Variables()`,
`bit_var::Compare` walks `Ranges()`, and the vector `SafeCompare` sets
`m_failedLhs` to the **owner of the vector** — which is why the head decompiles
the ELEMENT and leaves `RHS: <null>`.

The range golden hands it is the **second associative dimension's marker**: a
`range` whose `Left_expr` is `UINT:0` and whose `Right_expr` is
`STRING:associative` carrying `class_typespec(uvm_object)`.  It is the SAME
OBJECT the array_var lists under its own `vpiRange` (`vpiParent` -> the
array_var, in golden as well as in the patched build).

The whole-dump path-normalised diff of the two BuildUVMPkg databases is
**+2 lines / -0** — one `|vpiRange:` and one shallow `\_range:` line, on that one
object, and nothing else in 1 075 112 lines.

## 2. DECODED FROM THE PRODUCER — one line of Surelog, and it is bit-only

`ElaborationStep::makeVar_` (Surelog `src/DesignCompile/ElaborationStep.cpp`)
builds the variable, then the array_var pass wraps it.  Exactly ONE arm of the
`(found == false) && tps` typespec switch touches the element's ranges — ~1921:

```cpp
} else if (tpstype == uhdmbit_typespec) {
    bit_var* stv = s.MakeBit_var();
    stv->Ranges(unpackedDimensions);        // <- THE SAME VECTOR OBJECT
    obj = stv;
}
```

and the `logic_typespec` arm six lines above has the identical line **commented
out** (`"Do not set packedDimensions, it is a repeat of the typespec packed
dimension"`).  That is the whole of the law: **bit, and nothing else.**

`unpackedDimensions` is then MUTATED by the array_var pass (~2113): the loop
finds the OUTERMOST unsized marker, lifts it into the `array_typespec`
(`Index_typespec` for assoc) and **erases it from the vector**; what remains is
handed to `array_var->Ranges(...)` when the erased dim was dim 0, or to the inner
`array_typespec` when a FIXED dim came first.  The element var is still pointing
at that same vector, so:

| written | array_var `vpiRange` | element `vpiRange` |
|---|---|---|
| `bit x[int]` / `x[]` / `x[$]` (1-D unsized) | none | the vector is now EMPTY (serialization drops it) |
| `bit x[int][int]`, `[][]`, `[$][$]`, `[int][$]`, `[$][int]`, `[][int]`, `[int][]` | the remaining marker | **the same object** |
| `bit x[int][2]`, `[][2]`, `[$][2]`, `[int][2][3]` | the remaining FIXED range(s) | **the same object(s)** |
| `bit x[4]`, `[2][3]`, `[0:3]` (all fixed) | all of them | **the same objects** |
| `bit x[2][int]`, `[2][3][int]` (leading FIXED + assoc) | **none** | the remaining FIXED range(s) |
| `bit x[2][]`, `[2][$]` (leading FIXED + dyn/queue) | none, and **no element at all** — Surelog's `if ((Typespec() == nullptr) \|\| associative)` gate never pushes it | — |

Every row of that table is a measured golden cell of arm `w1v_dims11`, not a
reading of the source.

## 3. THE LAW

> **§ bitElemSharesArrayRanges11** — the element variable of a CLASS-PROPERTY
> `array_var` carries `vpiRange` = **the array_var's own range vector**, and it
> does so **if and only if that element is a `bit_var`**.

### STATED GATE == CODE GATE

**STATED:** in the class-property array arm of `UhdmExporter::emitClassBody`,
AFTER every producer of `av->Ranges(...)` has run (`emitAssocDims`' inner
markers, `buildUnpackedRanges`' fixed dims, and
§ `assocTypeParamDimIsStaticSize51`'s `[0 : KEY-1]` reshape): if the element var
`reg` is a `bit_var` and `av->Ranges()` is non-null and non-empty, give `reg`
that same vector.  Nothing else, no re-parenting, no copy.

**CODE:** `src/UhdmExporter.cpp`, `git diff` vs `e359f0a` — 83 added lines in one
window, of which **80 are the comment** and 3 are the `if`.  Nothing else in the
tree is touched.

### the gates that were REFUTED, each on the grid

| candidate gate | refuted by |
|---|---|
| "the dim shape decides" | arm w1 — golden gives it in ALL 17 shapes that leave the array_var a range, and in none of the 3 that do not |
| "only associative" | arm w1 — `[][2]`, `[$][2]`, `[4]`, `[2][3]`, `[0:3]` all get it |
| "not a typedef'd element" | arms w2 + w6 — a package `typedef bit`, `typedef bit [7:0]`, a typedef-of-typedef, a QUALIFIED `pk::b_t` and typedefs declared INSIDE the class all get it, exactly like a written `bit` |
| "any integral element" | arm w2 — logic, `logic [7:0]`, `typedef logic`, int, int unsigned, byte, shortint, longint, integer, time, real, shortreal, string, chandle, class handle, `enum bit`, packed struct, unpacked struct: **18 cells, golden-empty, every one** |
| "every home" | arm w3 — subroutine- and block-LOCAL arrays get NO array_var ranges at all in golden, so `TaskFuncEmit`'s sites are fenced out |
| "the same law at module scope" | arm w4 — **REFUTED**: at MODULE scope a typedef'd bit element gets NOTHING (`f_btd`, `f_bvtd`, `n_btd`, `n_bvtd`), because Surelog reaches the `DummyType` arm (~1777, `MakeBit_var()` with no ranges) and never enters the switch above.  This is why the stamp is at the CLASS site only — see residue R1 |

## 4. THE CENSUS — golden vs ours, over every array_var in the corpus, BEFORE any code

`r10buvm11cen` reads a database out of `Serializer::AllObjects()` (never dump
TEXT) and emits one row per `array_var`: view, parent chain, name, span,
`vpiArrayType`, `vpiSize`, the array's own range MARKER SHAPE, the element kind,
the element's typespec, the element's marker shape, and whether the two vectors
are the SAME OBJECTS.  `cenjoin11.py` joins two censuses on an **ID-blind and
address-blind** key `(view, parent chain of kinds+names, name, line:col)`.

**CALIBRATION FIRST, golden against golden** (BuildUVMPkg, 641 array_vars):
`G=R P=R 1 / G=N P=N 640 / DISAGREEING 0`, and the census binary is
**byte-deterministic on a re-run**.  A join that cannot report zero on identical
inputs cannot report two on different ones.

`cenall11.sh` then runs that join over the WHOLE surelog corpus — 956 databases,
339 of which have both a golden and one of ours (the other 617 are
`SLANG_REJECT` / `SURELOG_FAIL` / `DEFERRED` runs with no database, COUNTED and
printed, never hidden):

| class | pristine | patched |
|---|---|---|
| `G=N P=N` — neither gives the element ranges | 7 297 | 7 297 |
| `G=R P=R` — both do | 4 | **6** |
| **`G=R P=N` — golden does, we do NOT** | **2** | **0** |
| **`G=N P=R` — we do, golden does NOT (over-fire)** | **0** | **0** |
| present on one side only (a DIFFERENT defect, see R3/R4) | 511 / 20 | 511 / 20 |

and the **2** are one object in two modes, printed in full by the join:

```
G=R P=N  ELAB class_defn(uvm_comparer)<package(uvm_pkg)<design(unnamed)::compare_map@21545:7
         G(ek=bit_var evM=A avM=A)   P(ek=bit_var evM=- avM=A)
```

The law PREDICTS that census exactly: 2 before, 0 after, 0 over-fire in either
direction, across 7 300 compared array_vars.

## 5. THE GRID — six arms, 125 golden cells, **0 OVER-FIRE**

`grid11.sh` is the three-way cell table (golden / pristine / patched).  Surelog
and BOTH binaries run in the SAME directory (a UHDM database records the source
file's ABSOLUTE path — buvm8's `bndarms` trap).  The cell is
`view:at<arrayType>|av<marker shape>|<element kind>|ev<marker shape>`, DEF and
ELAB rows of one declaration joined with `,` so a view disagreement shows instead
of colliding.

| arm | what it varies | golden AVs | verdict |
|---|---|---|---|
| `w1v_dims11` | 26 DIM SHAPES, `bit` element, class in a package | 26 | **CONVERTED 7, OVER-FIRE 0** |
| `w2v_elem11` | 24 ELEMENT KINDS at the head's shape + 1-D and FIXED controls | 33 | **CONVERTED 9, OVER-FIRE 0** |
| `w3v_homes11` | every HOME × DEF/ELAB | 24 | **CONVERTED 6, OVER-FIRE 0** |
| `w4v_mod11` | the MODULE-scope twin of w1 + the module element-kind fence | 27 | **CONVERTED 0, OVER-FIRE 0 — a strict NO-OP** |
| `w5v_param11` | the `T pool[KEY]` static reshape (the THIRD `av->Ranges` producer) | 3 | **CONVERTED 2, OVER-FIRE 0** |
| `w6v_cltd11` | typedefs declared IN the class / in a BASE class / QUALIFIED | 12 | **CONVERTED 10, OVER-FIRE 0** |

**34 CONVERTED, 0 OVER-FIRE, 0 MOVED-STILL-WRONG.**  Cells worth naming:

| cell | written | golden | pristine | patched |
|---|---|---|---|---|
| w1 `d_aa_ii` | `bit x[int][int]` | `avA` / `evA` | `avA` / **`ev-`** | `avA` / **`evA`** |
| w1 `d_assoc_int` | `bit x[int]` | `av-` / `ev-` | = golden | unchanged (the vector is empty) |
| w1 `d_fa` | `bit x[2][int]` | `av-` / `eve` | **no array_var at all** | unchanged (**R3**) |
| w2 `e_log` / `e_int` / `e_str` / … | 18 non-bit elements | `avA` / `ev-` | = golden | unchanged |
| w2 `e_btd` / `e_bvtd` / `e_b2td` | typedef'd bit elements | `avA` / `evA` | `ev-` | **`evA`** |
| w3 `mc_aa` / `u_aa` / `c_aa` | class in a module / at `$unit` / in a package | `evA` | `ev-` | **`evA`** |
| w3 `fl_aa` / `mfl_aa` / `bl_aa` | function- and block-LOCAL | `av-` / `ev-` | = golden | unchanged (the FENCE) |
| w4 `f_btd` / `f_bvtd` | `typedef bit b_t; b_t x[4];` at MODULE scope | `ave` / **`ev-`** | `ave` / **`eve`** | unchanged (**R1c**) |
| w6 `a_bbtd` | element typedef'd in a BASE class | `logic_var` / `ev-` | = golden | unchanged |

## 6. RESIDUES, each measured and left deliberately

* **R0 — THE NEW HEAD.**  `function (uvm_pkg::uvm_comparer::get_recursion_policy)
  @uvm_pkg.sv:21000:3` under `class_defn(uvm_comparer)`, `RHS: <null>` —
  MISSING-OURS, a class METHOD golden lists and we do not.  Pre-existing; it was
  pristine rung 2.
* **R1 — THE MODULE/PACKAGE-SCOPE TWIN, three separate defects, ALL in arm w4,
  NONE of them this law.**
  (a) our fixed-dim range `Right_expr` is a folded `UINT` constant where
  golden's is an expression, for every module-scope dyn/queue/assoc array
  (`m_df`/`m_qf`/`m_af`/`m_dff`, golden `ave` vs ours `avf`) — so the array_var's
  OWN range already differs there and an element copy would convert nothing;
  (b) we emit **no inner unsized marker range at all** at module scope
  (`m_aa`/`m_dd`/`m_qq`: golden `avA`/`avU`/`avQ`, ours `av-`);
  (c) `emitArrayVar`'s already-landed bit-sharing law **OVER-FIRES on a typedef'd
  bit element** at module scope (`f_btd`/`f_bvtd`: golden `ev-`, ours `eve`) —
  the Surelog `DummyType` arm.  The corpus census says this fires on **ZERO**
  corpus objects (`G=N P=R` = 0 over 7 300 array_vars), which is why it is NAMED
  with its exact gate and not fixed in a pass whose law is class-scope.
* **R2 — leading-FIXED + assoc.**  `bit x[2][int]` / `x[2][3][int]`: golden's
  array_var has NO ranges and its element has the surviving FIXED ones
  (`shared=X` in the census, the ONE shape where the two vectors differ).  We
  emit no array_var for those declarations at all, so the cell is unreachable
  from here.
* **R3 — multi-dimension NON-associative class properties are DELETED by us.**
  14 of arm w1's 26 declarations (`bit x[][]`, `[$][$]`, `[int][$]`, `[$][int]`,
  `[][int]`, `[int][]`, `[int][2]`, `[2][int]`, `[][2]`, `[2][]`, `[$][2]`,
  `[2][$]`, `[int][2][3]`, `[2][3][int]`) produce NO object from us: the class
  arm's element factory has no arm for a nested-array element and
  `noteUnsupported` drops the property.  This is the largest thing the grid
  exposed and it is a whole pass of its own.
* **R4 — package- and module-scope `bit p_aa[int][int]`.**  Our element is a
  `logic_var` where golden's is a `bit_var` (package scope), and `bit p_f[4]` at
  package scope produces no array_var from us at all (arm w3).
* **R5 — `real` / `shortreal` / `chandle` elements of a class-scope ASSOC array**
  are dropped by us (arm w2 `e_real`/`e_sreal`/`e_chand`, `P=-`); golden gives
  them a `real_var`/`short_real_var`/`chandle_var` with no ranges.  The FIXED
  twin already has arms (`classFixedElemVar6`); the assoc one does not.

## 7. THE MOVERS, PREDICTED BY NAME BEFORE ANY BYTE WAS COMPARED

`predict11.sh` reads ONLY the PRISTINE databases (never the patched ones, never
golden) and names every object the law can touch:

* **CAND A** — an `array_var` with a `bit_var` element, a NON-EMPTY `Ranges()`,
  an element with NO ranges, and a `class_defn` in its parent chain.
* **CAND B** — the SAME shape with NO `class_defn` in the chain.  CAND B is a
  CONTROL, not a prediction: any CAND B that moves is an over-fire.

| corpus | databases | CAND A | CAND B | candidate DATABASES |
|---|---|---|---|---|
| uhdm2rtlil | 1 358 | **0** | 0 | **0** |
| surelog | 956 | **2** | **0** | **2**: `{default,testflags}/BuildUVMPkg` |

```
CAND A default/BuildUVMPkg-bf853d43/slang.uhdm   class_defn(uvm_comparer)<package(uvm_pkg)<design(unnamed)::compare_map@21545:7
CAND A testflags/BuildUVMPkg-bf853d43/slang.uhdm class_defn(uvm_comparer)<package(uvm_pkg)<design(unnamed)::compare_map@21545:7
```

Those two databases are EXACTLY the two law-movers gate 5 then found.

## 8. THE LADDER — 1 rung REMOVED, **0 ADDED**

`tools/probe/r10ladder1repro/ctladder` (the official `design::Compare` run to
fixpoint by masking each head).  MEASUREMENT ONLY; `uhdm-cmp` is the judge.
Calibration on this pass's golden against itself: **0 rungs on 183 142 objects.**

| | pristine | patched |
|---|---|---|
| rungs (fixpoint) | **129** | **128** |
| stop | FIXPOINT | FIXPOINT |
| masks / cascades (`[S]` line) | 129 / 71 | 128 / 70 |
| secs | 101.6 | 112.4 |
| rung 1 | `bit_var@21545:7` < `array_var(compare_map)` | `function(get_recursion_policy)@21000:3` < `class_defn(uvm_comparer)` |

Rung-list diff by normalised LHS object: **1 removed, 0 ADDED**, and the one
removed is the head itself.  This is the tightest ladder delta the campaign has
recorded — the change removes one rung and un-exposes nothing, because the mask
it drops was not a cascade for anything else.

## 9. THE FIVE GATES

| # | gate | result |
|---|---|---|
| 1 | build BOTH binaries, `-j 2`, md5 separately | pristine `f6d7a09beb97347361bda03a47b92428`, patched `3aafd7fcd0915f9dc1d91614da73d618`.  The deliverable was then applied to a THIRD, untouched `e359f0a` worktree (`/tmp/wt_r10buvm11_verify`, `git apply --check` clean) and built from scratch: md5 **`3aafd7fcd0915f9dc1d91614da73d618`** — the patch reproduces, bit for bit, the binary every reading above was taken with. |
| 2 | `tests/check_goldens.sh` + negative control | **23** PASS on the pristine, the patched AND the from-scratch reproduction; `SLANG_UHDM=/bin/false` -> **0** PASS.  `SLANG_UHDM` exported explicitly to EACH binary. |
| 3 | uhdm2rtlil, both modes | **679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL** in each mode on each binary; `ct11rows.sh` pristine-vs-patched = **0 differing ROWS** over 1 462, and the patched `testflags` half vs the COMMITTED `results/gate_uhdm2rtlil.csv` = **0 differing ROWS** over 731 (status AND dump column). |
| 4 | Surelog suite, `--mode both` | `ct11rows.sh` patched vs the COMMITTED `results/golden_surelog.csv` = **0 differing rows** over 1 588; same against the pristine sweep.  Status and dump histograms identical.  **NO ROW CONVERTED — `BuildUVMPkg` stays `CMP_NOTEQUAL` in both modes and `results/*.csv` were not touched.** |
| 5 | `byteverify.sh SELFCHECK=1 SELFCHECK1=1` | surelog **3 / 956** movers, u2r **0 / 1 358**.  Controls: 955/956 + `SELFCHECK1`=4 (1 corruption + the 3 movers), and 1357/1358 + `SELFCHECK1`=1. |

Movers, attributed one database at a time by `attrib11.sh` (census delta on the
law's own field + a whole-dump path-normalised diff, judged ORDER-BLIND):

| database | census GAINED | dump RAW | dump ORDER-BLIND | verdict |
|---|---|---|---|---|
| `default/BuildUVMPkg` | 1 | +2 / -0 | +2 / -0, `vpiRange:`=1 `\_range:`=1 other=0 | **ATTRIBUTED** (predicted) |
| `testflags/BuildUVMPkg` | 1 | +2 / -0 | +2 / -0, same | **ATTRIBUTED** (predicted) |
| `default/Scoreboard` | **0** | +46 / -46 | **+0 / -0** | **NOT THIS LAW — THE DOCUMENTED COIN** |

**AND THE COIN IS PROVED, NOT CITED.**  The standing MEASUREMENT LAWS call
`Scoreboard/default` a ~50/50 coin (the `svunit_pkg` `vpiTaskFunc` reorder), and
an order-blind zero is consistent with that but does not establish it.  So the
**PRISTINE** binary was run FOUR TIMES on `Scoreboard` from the same directory:

```
3f24c35477d3cb456af23ec3f1827aca   run 1
3f24c35477d3cb456af23ec3f1827aca   run 2
3f24c35477d3cb456af23ec3f1827aca   run 3
a8f196656b874f1988aa9f97f820a1e4   run 4      <- 2 distinct hashes from ONE binary
```

and those two md5s are **exactly** the pair the byte verifier reported as
`pristine=3f24c35477d3 patched=a8f196656b87`.  The mover is the coin landing the
other way, on a binary that never saw the patch.

### the canary battery, all pristine-vs-patched

| check | result |
|---|---|
| `canaries.sh` on the surelog CSVs | `ok=52 changed=0 absent=0`, 7 expected unknown names (the u2r-only canaries) |
| `canaries.sh` on the u2r CSVs | `ok=16 changed=0 absent=0`, 25 expected unknown names |
| `ctcan2.sh` surelog (`EXPECT_UNKNOWN=1`) / u2r (`EXPECT_UNKNOWN=6`) | `ok=58 changed=0` / `ok=2 changed=0` — **PASS** both |
| `canaudit.sh canaries.sh ctcan2.sh` | `audited=29 UNCOVERED=0 FENCE-BREACH=0`, both self-tests live |
| `InterfaceModPort` / `BlackParrotComplex` / `YosysOldOr` | not in the mover list => **byte-identical**; md5s printed per mode |
| `SVSwitch` md5 pin | `4842211c4030` on the PATCHED binary, both modes |
| `YosysVerx` md5 pin | `6ccda350c24a` on the PATCHED binary, both modes |
| determinism (`detcheck.sh`, 3 runs each on w1, w2, w6) | 1 distinct hash, 0 NO_OUTPUT |

### the SEVEN-ROW HEAD SET, both binaries, out of the FULL sweep workdirs

| row | mode | pristine | patched | cmp log |
|---|---|---|---|---|
| `BuildUVMPkg` | default, testflags | 79 lines / 1 head | **47 / 1** | the head MOVED (§ THE HEADLINE) |
| `SeqDriver` | default, testflags | 28 / 1 | 28 / 1 | **BYTE-IDENTICAL** |
| `SimpleUVM` | default, testflags | 28 / 1 | 28 / 1 | **BYTE-IDENTICAL** |
| `Scoreboard` | default | 28 / 1 | 28 / 1 | **BYTE-IDENTICAL** (its database is the coin; its cmp log is not) |
| `MiniAmiq` | default, testflags | 28 / 1 | 28 / 1 | **BYTE-IDENTICAL** |
| `Earlgrey_0_1` | default / testflags | 46 / 33 | 46 / 33 | **BYTE-IDENTICAL** |
| `Rggen` | default | 17 / 1 | 17 / 1 | **BYTE-IDENTICAL** |

`Scoreboard testflags` and `Rggen testflags` print SKIP-NOFILE and are COUNTED,
not hidden.

### the boundary gate

`bndsub11.sh` over **491** arm sources — `r10buvm3..10`, `r10oth8`, `r10oth9`,
`r10svs6`, `r10sd8..12`, `r10uvm82/83` (subdirectory arms included, buvm9's
lesson; the list travels on fd 3 with children `</dev/null`, buvm10's lesson) —
on both binaries:

```
-- arms PROCESSED=491 IDENTICAL=482 MOVED=3 REJECT-BOTH=6 ONE-SIDE=0
```

and **all three MOVED arms were then put back through `grid11.sh` against
golden**, because "moved" is not a verdict:

| arm | dump delta | grid verdict |
|---|---|---|
| `r10svs6repro/b2_elemkind` | +6 / -0, 3 × (`\|vpiRange:`, `\_range:`) | **CONVERTED 3, OVER-FIRE 0** |
| `r10svs6repro/v1_gaps` | +2 / -0 | **CONVERTED 1, OVER-FIRE 0** (`v07_pk`) |
| `r10buvm10repro/w3v_fence10` | +2 / -0 | **CONVERTED 1, OVER-FIRE 0** (`parr2`) |

The array_var laws named as boundaries (`emitDynArrayVar`'s 16-case module-scope
law, the buvm4/5/6/7 queue/dyn/assoc arms, the sd8-12 and uvm82/83 arms, and the
`oth8`/`oth9` `vpiSigned` grids) are in those 482 IDENTICAL arms, and every u2r
dyn/assoc/queue row is inside gate 3's `0 differing ROWS`.

## 10. reproduce
```sh
./build11.sh                                             # the census instrument
/tmp/r10buvm11cen <golden.uhdm> G > g.cen                 # census golden ...
/tmp/r10buvm11cen <ours.uhdm>   P > p.cen                 # ... and ours
./cenjoin11.py g.cen G p.cen P                           # the join
./cenjoin11.py g.cen G <(sed 's/ G / P /' g.cen) P       # the golden-vs-golden CALIBRATION
./cenall11.sh <workdir> /tmp/cen.txt                     # the corpus-wide census
PRISTINE=<e359f0a bin> PATCHED=<patched bin> ./grid11.sh w1v_dims11.sv   # ... w2 w3 w4 w5 w6
./allsweeps11.sh                                         # four sweeps, one at a time, --jobs 2
./predict11.sh /tmp/r10buvm11_wds_pristine               # PREDICT FIRST
SELFCHECK=1 SELFCHECK1=1 ./byteverify.sh /tmp/r10buvm11_wds_patched /tmp/r10buvm11_wds_pristine
./attrib11.sh <patched wd> <pristine wd> <rel>/slang.uhdm ...
./ct11rows.sh <baseline.csv> <fresh.csv>
./canaries.sh <fresh.csv> <baseline.csv>; EXPECT_UNKNOWN=<n> ./ctcan2.sh ...
bash canaudit.sh canaries.sh ctcan2.sh
PRISTINE=... PATCHED=... ./bndsub11.sh < <list of ABSOLUTE arm paths>
./rowheads.sh <workdir> <outdir> BuildUVMPkg
./detcheck.sh <bin> 3 w1v_dims11.sv
```

The ladder is `tools/probe/r10ladder1repro/ctladder.cpp`, built with the line in
that directory's README and run `<golden> <ours>`.
