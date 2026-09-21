# r11u82 — reference FORM decides the fold, and a namesake collision is
# decided by the producer's vector order, not by SystemVerilog's shadowing

Base commit `f25df07e`. Pristine binary md5 `87f32e6a31b52cd5b7766f0b8bcc731a`
— built in this pass's own worktree, `-j 2`, md5 taken separately, and
**byte-identical to the main tree's `build/slang-uhdm` at `f25df07e` and to the
OPS pin**, compared not assumed. Patched binary md5
`65484d52491e71d8675def23d0953826`. Both frozen `chmod 555` at immutable paths
before any sweep; every `cmds.txt` audited by binary PATH.

Two laws, two switches, each droppable alone. `results/*.csv` untouched;
`src/ParamEmit.cpp` untouched (the sister pass's ground — the whole patch is
`src/ModuleEmit.cpp`).

---

## 1. THE THREE WITNESSES, RE-MEASURED AT THE BASE (question 1)

`GRID.pris.r11u82.txt`. Every arm compiles on both sides, both rc values
recorded; the goldens are regenerated per arm by the pinned Surelog v1.87.

```
xh_ancpath   golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=28
xf_crossblk  golden_rc=0 ours_rc=0  cmp_rc=255 heads=1 cmplines=15
vf_collide   golden_rc=0 ours_rc=0  cmp_rc=0   heads=0 cmplines=0
```

**`xh_ancpath` is LAW A's witness and its ONE differing cell is `b_modp`**
(`assign b_modp = dut.M_LOC.n;` written inside `B1.B2`), through this pass's
resolving lister:

```
    section          lhs_fullname              GOLDEN                OURS
~   uhdmtopModules   work@dut.B1.B2.b_modp     rhs hier_path         rhs constant BIN:…1001011000 sz=32
```

A folded constant where golden keeps a `hier_path` differs on `VpiType`, so
this cell IS judge-visible; it sits behind the arm's own head (a `func_call`
leftover argument, r11u75's residue 4, unmoved by this pass).

**`xf_crossblk` agrees cell for cell at this base** — pass 74's and pass 75's
fences hold — and it stays a pure CONTROL here: byte-identical on both
binaries.

**`vf_collide` is LAW B's witness and it is `cmp_rc 0` at this base.** The
defect is not in the status; it is in WHICH object the three cells point at,
and the lister prints the target's span:

```
row                        GOLDEN target                              OURS target
work@dut.gv[0].c_net       logic_net (work@dut.c_net)  line 6:15      line 14:16
work@dut.gv[0].c_var       logic_var (work@dut.c_var)  line 7:15      line 15:16
work@dut.gv[0].c_st        struct_net (work@dut.c_st)  line 9:15      line 16:16
```

Lines 6/7/9 are the PACKAGE `pc`'s own declarations — the copies
`importPackage` hoists into the module — and lines 14/15/16 are the module's
own. Both objects carry the same `VpiName` and the same synthesised
`vpiFullName`, and golden's object has already been visited in the module's
`Nets()` walk by the time the cell's `Actual_group` is compared, so
`ref_obj::Compare` short-circuits on `m_visited`: judge-SILENT, byte-scored
(the pass-73 lesson).

---

## 2. THE DECODE (question 2)

### 2a. LAW A — the pre-existing `caMemSel` road's base test

`asmRefFamilyBase` (`src/ParamEmit.cpp:2886`) walks the reference chain down to
the member-by-member-const-function-built struct parameter and accepts a
`HierarchicalValueExpression` **as readily as a `NamedValueExpression`**
(`ParamEmit.cpp:2891-2895`). The fold that record feeds is
`drainCaAsmMemberSlice` (`ParamEmit.cpp:3675`), which resolves the base through
`elabParamPa` and REPLACES the cell's elaborated slot with a fresh folded
`cont_assign`. So a module-level, child-instance, package or interface base
reached by a WRITTEN PATH takes the fold road exactly as a simple name does.

r11u75's fence stopped only the RECORD that strips such a cell's own-local
actual (§ caGenScopeFoldedLhsNoOwnBind75) and left the push "exactly as
pristine takes it", because narrowing the pre-existing road is a different law
with its own grid. This is that grid.

### 2b. LAW B — the producer's namesake search order

`slang::ast::Scope::find` answers SystemVerilog's rule: a local declaration
shadows a wildcard import, so our lookup returned the MODULE's own object. The
producer never asks that question. Its search is
`CompileHelper::bindVariable` (`src/DesignCompile/CompileStmt.cpp:3068-3092`
for the `ModuleInstance` overload — `netlist->nets()` first, then
`netlist->variables()` — and `:3139-3150` for the `module_inst` one) and
`UhdmWriter::lateBinding` (`src/DesignCompile/UhdmWriter.cpp:3765-3812` —
`inst->Nets()`, then `Array_nets()`, then `m->Variables()`). BOTH walk whole
vectors in order and return the FIRST name match.

And the imported copy is FIRST in those vectors:
`CompileHelper::importPackage` (`src/DesignCompile/CompileHelper.cpp:171-189`)
does `scope->addVariable(var.second)` and
`scope->getSignals().push_back(net)` into the IMPORTING scope's own
registries during the module's import pass, ahead of the module's own
declarations — measured below to be independent of where the `import` is
written.

So the rule is **nets before variables, and inside each vector the imported
copy before the module's own** — which is not "the import always wins", and
the grid has the row that proves it.

---

## 3. THE GOLDEN GRID (question 3)

Twelve arms, `grid/`, every one its own `dut.sv`, every golden regenerated by
the pinned Surelog v1.87, every arm `golden_rc=0 ours_rc=0` on both binaries
(`GRID.pris.r11u82.txt` / `GRID.patch.r11u82.txt`).

### 3a. LAW A — reference FORM, across scopes and homes

| arm | row | written form | base's home | GOLDEN | pristine |
|---|---|---|---|---|---|
| `s1_modform` | `m_simple` / `m_simt` | simple name | module | **FOLDS** | folds |
| `s1_modform` | `m_path` / `m_patht` | `dut.M_LOC.n` | module | `hier_path` | **folds WRONG** |
| `s2_childpath` | `k_simple` | simple name | the child itself | **FOLDS** | folds |
| `s2_childpath` | `c_path` | `u1.K_LOC.n` | a CHILD instance | `hier_path` | **folds WRONG** |
| `s5_ifacepath` | `i_path` | `u_if.I_LOC.n` | an INTERFACE instance | `hier_path` | **folds WRONG** |
| `s3_pkgbase` | `q_pkg` | `p::P_LOC.n` | a PACKAGE | **FOLDS** | folds |
| `s3_pkgbase` | `q_imp` | `P_LOC.n` (wildcard-imported) | a PACKAGE | **FOLDS** | folds |
| `s3_pkgbase` | `q_loc` / `G1.g_loc` / `G1.g_pkg` | simple / package-scoped, from a gen scope | module / package | **FOLD** | fold |
| `s6_pathforms` | `t_gen` / `t_deep` / `t_idx` | `B1.B_LOC.n`, `B1.B2.D_LOC.n`, `A1[1].L_LOC.n` | a GENERATE scope | `hier_path` | `hier_path` |
| `s6_pathforms` | `t_own` | simple name | module | **FOLDS** | folds |
| `xh_ancpath` | `b_simple`/`b_mod`/`b_self` | simple name | enclosing block / module / own | **FOLD** | fold |
| `xh_ancpath` | `b_path` | `B1.B_LOC.n` | enclosing block | `hier_path` | `hier_path` |
| `xh_ancpath` | `b_modp` | `dut.M_LOC.n` | module | `hier_path` | **folds WRONG** |

Two readings the grid settles:

* **A PACKAGE-SCOPED NAME IS NOT A WRITTEN PATH.** `p::P_LOC.n` folds on
  golden, module level and inside a generate scope, and slang binds it as a
  `NamedValue` — so the form test passes it through untouched. This matters:
  the fold the landed conversions ride is the simple-name fold.
* **AT MODULE LEVEL THE JUDGE IS SILENT.** Golden's elaborated slot for a
  written-path cell IS the definition `cont_assign` object, already visited by
  the def-listing walk, so `cont_assign::Compare`'s
  `m_visited.insert(this)` returns 0 before it reads a field — `s1`, `s2` and
  `s5` are all `cmp_rc 0` on the PRISTINE binary. Only the generate-scope cell
  (`xh_ancpath` `b_modp`, a fresh clone) is scoreable, and the byte gate is
  what convicts the rest.

### 3b. LAW B — namesake homes and collision shapes

| arm | row | package copy | module's own | GOLDEN binds | pristine binds |
|---|---|---|---|---|---|
| `c2_kinds` | `k_nn` | NET | NET | the PACKAGE's net | the module's |
| `c2_kinds` | `k_nv` | NET | VARIABLE | the PACKAGE's net | the module's var |
| `c2_kinds` | `k_vn` | VARIABLE | NET | **the MODULE's net** | the module's net |
| `c2_kinds` | `k_vv` | VARIABLE | VARIABLE | the PACKAGE's var | the module's |
| `c2_kinds` | `k_only` | VARIABLE | — | the PACKAGE's var | the package's |
| `c1_order` | `da` (import written FIRST) | NET/VAR | NET/VAR | the PACKAGE's | the module's |
| `c1_order` | `db` (import written LAST) | NET/VAR | NET/VAR | the PACKAGE's | the module's |
| `c4_portns` | `p_net` | NET | a module PORT's net | the PACKAGE's net | the port's |
| `c4_portns` | `q_var` | VARIABLE | VARIABLE | the PACKAGE's var | the module's |
| `c3_expimp` | `e_net` / `e_var` | explicit import, no module-own | — | the PACKAGE's | the package's |
| `vf_collide` | `c_net`/`c_var`/`c_st` | NET/VAR/struct NET | NET/VAR/struct NET | the PACKAGE's | the module's |

`k_vn` is the convicting row: the module's own NET is reached before the
package's VARIABLE because nets are searched first — so the choice is exactly
`impNet || !ownNet`, and "the import always wins" is REFUTED.
`c1_order` refutes source order as a discriminator, `c3_expimp` shows the
landed no-collision cells are untouched, and `c4_portns` shows a module PORT
loses to the imported net just the same.

### 3c. The pass-73/74/75/77 controls

`xf_crossblk` (pass 74/75's sibling-and-iteration grid) and `s6_pathforms`
(the generate-scope bases, which reach no fold road on either binary) are
**byte-identical between the two binaries**, and so are `c3_expimp` and
`s3_pkgbase`. The whole switch ledger is in §5.

---

## 4. THE TWO LAWS (question 4)

### § caMemSelWrittenPathNeverFolds82 — LAW A

The record is gated on the member-select's base being a `NamedValue`, at BOTH
of the pre-existing road's record sites: the generate-scope one beside
`emitGenScopes` (where `simpleBase75` already existed and only the record's
`foldRec75` half read it) and the instance-level one inside `emitInstance`
(where the new `simpleBase82` nulls `caMemSelBase`, withholding the shared
slot's push and the elab-owned one's together). Withholding the push IS the
fix: the drain is what swaps the shared slot for a fresh folded
`cont_assign`, so a cell that is never recorded keeps the shared definition
object golden carries. `foldRec75` was already false on these cells, so
§ caGenScopeFoldedLhsNoOwnBind75 is untouched by construction, and the
SIMPLE-NAME fold the landed conversions ride is not reached at all.

### § caNamesakeImportCopyShadows82 — LAW B

Inside `genCaLhsNamesake74`'s one-hop `InstanceBody` arm, after the existing
kind filter: if `nsImportHome75` answers for the same name, the producer's
vector order picks between the two candidates (`impNet || !ownNet`) and the
chosen one is returned. The WIDTH half (`genCaSubstAdjustW71`) is NOT touched —
golden's `vf_collide` Rhs constants stay 32 bits on both binaries, so the
resize answers as it did.

The loser is handed back through a new `shadowed82` out-parameter and the
caller retries it through the SAME three resolution steps (the `netMap` hit,
the `genScopeNets` fallback, the unpacked-array fence) when the winner has no
emitted object. GOLDEN WRITES NOTHING ON A MISS — but it does write here, so
the fallback exists to make sure this pass never turns a wrong object into NO
object.

Each law is droppable alone: `R11U82_PATHFOLD_OFF=1`, `R11U82_COLLIDE_OFF=1`,
`R11U82_OFF=1` for both. `R11U82_CELLDBG=1` traces every cell that reaches
either site, DECLINED ones included — the trace is taken BEFORE the gate and
does not read the switch, which is what lets one run predict the mover set.

---

## 5. THE SWITCH LEDGER

`SWITCHES.r11u82.txt` — differing dump lines against the PRISTINE binary's own
dump of the same arm (0 = byte-identical):

```
arm             NONE  R11U82_OFF  PATHFOLD_OFF  COLLIDE_OFF
c1_order           8           0             8            0
c2_kinds           6           0             6            0
c3_expimp          0           0             0            0
c4_portns          4           0             4            0
s1_modform        50           0             0           50
s2_childpath      25           0             0           25
s3_pkgbase         0           0             0            0
s5_ifacepath      25           0             0           25
s6_pathforms       0           0             0            0
vf_collide         6           0             6            0
xf_crossblk        0           0             0            0
xh_ancpath        28           0             0           28
```

`R11U82_OFF=1` reproduces the pristine database BYTE FOR BYTE on all twelve
arms, and each single switch returns exactly its own law's arms to pristine
and leaves every other arm at the patched reading.

---

## 6. THE CENSUS AND ITS POSITIVE CONTROL (question 5)

`CENSUS.r11u82.txt`, both corpora, both modes, replaying the harness's own
discovery and its own slang argument vector, every invocation's rc recorded:

```
uhdm2rtlil (1742 test x mode arms)   LAW A sites 4, declined 0; LAW B collisions 0
surelog    (1573 test x mode arms)   LAW A sites 2, declined 0; LAW B collisions 0
```

The four uhdm2rtlil LAW A sites are `struct_param_func_arg` and
`struct_param_func_loop` in both modes and the two surelog ones are
`StructParamFuncBodyFieldCompare` in both modes — the landed conversions' own
cells, and **every one of them is `simple=1`**, so the fold they ride is
untouched.

**THE ZEROS ARE ZEROS INSIDE A LIVE POPULATION** — the genvar_loop_decl_3
precedent. 3892 (uhdm2rtlil) and 12574 (surelog) `R11U74BIND` rows reach the
very lookup LAW B changes, and every one of them reports NO import collision.

**POSITIVE CONTROL** (`POSCTRL.r11u82.txt`): the same trace, the same binary,
on the grid arms where the laws act — **8 `declined=1` rows** (LAW A:
`s1_modform` ×2, `s2_childpath` ×1, `s5_ifacepath` ×1, `xh_ancpath` ×1,
`s6_pathforms` ×3) and **12 `take=1` rows** (LAW B: `c1_order` ×4, `c2_kinds`
×3, `c4_portns` ×2, `vf_collide` ×3). The instrument can see both sites and
both outcomes.

`s6_pathforms`'s three declines are the instructive ones: they are the arm
whose dump does NOT move (ledger `NONE=0`), because a generate-scope base was
already declining downstream for want of an `elabParamPa` entry. The trace
names the DECISION, the ledger names the CONSEQUENCE, and the two are not the
same count.

**PREDICTED MOVER SET: EMPTY, both corpora, both modes** — and that is what
the byte gate measured.

---

## 7. GATES (question 6)

All green; the full record is `GATES.r11u82.txt`. In one line each:

* build both, md5s, pristine == the OPS pin `87f32e6a31b52cd5b7766f0b8bcc731a`;
* goldens 23/0 on both binaries, `/bin/false` 0/23;
* uhdm2rtlil 788/16/67 in both modes on both binaries, 0 of 1742 rows differing
  against `results/golden_uhdm2rtlil.csv` (both modes) and PASS against
  `results/gate_uhdm2rtlil.csv`; `byteverify SELFCHECK=1` **MOVERS 0 / 1608**;
* surelog 474/9 default + 469/8 testflags on both binaries; the 3 rows differing
  from `results/golden_surelog.csv` are present on the PRISTINE sweep too and
  are all environment (the Earlgrey_0_1/testflags dump-COLUMN draw, two
  LowMem* workdir strings); `byteverify SELFCHECK=1` **MOVERS 5 / 960**, and
  all five are the documented UVM macro-buffer class, attributed ORDER-BLIND to
  **four lines each, every one a `UINT:<n>`/`vpiDecompile:<n>` pair**;
* canary databases all on their pins (SVSwitch `4842211c4030`, YosysVerx
  `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1
  `8bdf25272e08`/`59d0ee6d10c3`); `canaries.sh` surelog ok=51 changed=1 — the
  Earlgrey_0_1/testflags dump COLUMN, which reads the same on the PRISTINE
  sweep — u2r ok=8 changed=0; ctcan2 PASS both; canaudit audited=29
  UNCOVERED=0 FENCE-BREACH=0; rowheads measured=12 with the UVM family and
  Earlgrey_0_1 all `0 0 cmp rc=0`;
* **MOVED-WRONG 0 / AWAY-GOLDEN 0**, both corpora, both mode columns.

**The object-level regression scan is clean too.** Every one of the twelve arms
× six dump sections had each top-level object block span-normalised and diffed
golden-vs-ours on BOTH binaries (`shapecmp82.py`): **0 blocks that matched
golden on the pristine binary differ on the patched one**, and four blocks go
the other way (`s1_modform`, `s2_childpath`, `s5_ifacepath` each convert their
`cont_assign` block, `c2_kinds` converts `work@dut.gv[0]`).

`results/*.csv` untouched. `src/ParamEmit.cpp` untouched. The four
slang-fenced names appear in no file here but `canaudit.sh`'s own `FENCED=`
line, and in no production diff.

---

## 8. RESIDUES (ranked)

1. **The `func_call` leftover ARGUMENT constant** is still the head of
   `xh_ancpath`, `xf_crossblk`, `s3_pkgbase`, `s5_ifacepath` and
   `s6_pathforms` — golden's `p::build(x)` call carries the argument the
   *declaration* wrote, ours the one the *fold* resolved (`xh_ancpath`: golden
   `UINT:704`, ours `UINT:600`). It is r11u75's residue and it masks every
   other cell on those arms. **R0** — it is the one head standing between this
   family's arms and `cmp_rc 0`.
2. **An INTERFACE's elaborated `cont_assign` listing** is missing from our
   `uhdmtopModules` where golden has it (`s5_ifacepath`
   `work@dut.u_if.i_simple`) — pre-existing on both binaries, the interface
   def-view gen-scope residue r11u75 records.
3. **`c4_portns` keeps its own head** (8 cmp lines, unchanged on both
   binaries): a module PORT's net and the imported package's net of the same
   name both exist and our port listing differs from golden's; LAW B moved the
   cell's target onto golden's object and left that listing alone.
4. The pass-77 residues (the five unpacked-array element spellings, the
   over-broad def-view `vpiNetType:36`) stand unmoved.

## 9. HOW TO RE-RUN

```bash
GRID=<this dir>/grid bash rr82.sh <binary> <tag>        # every arm, both rc values
GRID=<this dir>/grid bash sw82.sh <pristine> <patched>  # the switch ledger
GRID=<this dir>/grid bash score82.sh pris patch         # order-blind arm distance
DIFF=1 python3 calist82.py <gold.dump> <ours.dump>      # the resolving lister
python3 shapecmp82.py <gold.dump> <ours.dump> <section> # the object-block scan
python3 cellcen82.py <repo> <corpus> <binary> out.tsv   # the site census
```

No corpus test is dispatched from this directory; every arm is its own
`dut.sv`.

---

# r11v82 — THE ADVERSARIAL VERIFICATION, AND THE ONE CORRECTION IT LANDED

Verifier worktrees `/tmp/wt_v11u82` + `/tmp/wt_v11u82pris` at `f25df07e`,
scratch `/tmp/v11u82_*`, binaries built in the verifier's own worktrees with
`-j 2` and frozen `chmod 555` at `/tmp/v11u82_bin/{pris,patch,vfix}.bin`.

## V1. REPRODUCTION, BIT FOR BIT

Both of the implementer's binaries rebuild to the SAME md5 in a fresh
worktree: pristine `87f32e6a31b52cd5b7766f0b8bcc731a` (byte-identical to the
main tree's `build/slang-uhdm` at `f25df07e` and to the OPS pin) and patched
`65484d52491e71d8675def23d0953826`. `GRID.pris.r11u82.txt`,
`GRID.patch.r11u82.txt`, `SWITCHES.r11u82.txt`, `SCORE.r11u82.txt` and
`POSCTRL.r11u82.txt` all reproduce LINE FOR LINE on the verifier's own runs
(`GRIDV.*.r11v82.txt`, `SWITCHESV.r11v82.txt`).

**One reading in the implementer's evidence needs its footnote.**
`score82.sh` is an order-blind MULTISET distance, and on `s1_modform`,
`s2_childpath` and `s5_ifacepath` its `gold_only` column RISES under the patch
(333→348, 224→231, 176→183). That is the multiset trap, not a loss: the same
comparison run DEDUPED is unchanged on every LAW A arm (`s1` gold-missing 89
→ 89, `s2` 76 → 76, `s5` 60 → 60) while ours-extra falls. What actually
happens is measured directly — golden's `uhdmtopModules` carries ELEVEN
`cont_assign` occurrences on `s1_modform` and pristine minted FIFTEEN; the
patched binary carries golden's eleven, the written-path cell's elaborated
slot is a one-line already-visited STUB exactly as golden's is, and the full
expansion in `uhdmallModules` is **byte-identical to golden's, all 32 lines,
`hier_path` included**.

## V2. THE LAWS BROKEN, ON REAL v1.87 GOLDENS

Sixteen verifier arms beside the implementer's twelve, every one its own
`dut.sv`, every golden regenerated by the pinned Surelog, every arm's two rc
values recorded (`GRIDV.*`). No status moved on any of the 28 arms on any
binary.

**LAW A holds and GENERALISES.** Six new forms, all declined by the law and
all matching golden afterwards: a `$root`-rooted path (`v3_rootpath`), the
same definition instantiated TWICE (`v4_twoinst`, both elaborated copies), a
path through an interface PORT from inside the child (`v5_ifaceport`), a PATH
to a parameter whose own initializer is a simple name (`v2_aliaschain` — the
form test reads the FIRST hop and that is the written form), and from inside a
generate scope a path into a child instance and into an interface
(`v6_genpathchild`, **two more JUDGE-VISIBLE `hier_path`-vs-constant cells
converted**, the same class as `xh_ancpath` `b_modp`). Every one of those
cells is an ours-only `cont_assign` on pristine and gone on the patched
binary. The simple-name/package-scoped fold the landed conversions ride is
untouched in the shapes the implementer's grid did not reach either — inside a
child instance and inside an interface, by `p::P_LOC.n` and by its
wildcard-imported spelling (`v1_upward`, dump byte-identical on both
binaries).

`asmRefFamilyBase` accepts only a `NamedValue` or a `HierarchicalValue` at
every hop, so `simpleBase82 == false` is EXACTLY "the base is a
`HierarchicalValue`" and the gate can never widen to a nested member access or
an element select by accident. Checked, not assumed.

**LAW B was RIGHT IN SHAPE AND WRONG IN ONE READING, and the miss cost real
cells both ways.** `impNet || !ownNet` is the producer's vector order, but
"net" is read off slang's SymbolKind, and Surelog files a STRUCT-typed
declaration — packed or unpacked, in a package or in a module body — as a
`struct_net`, in the NETS vector. Measured type by type with the other side
held fixed, so golden's answer IS the classification:

```
arm w9_typeshapes  (module's own a NET in every row; the package copy varies)
    packed struct -> golden binds the PACKAGE's struct_net   => a NET
    packed union, enum, int, packed array, typedef'd vector, plain logic
                  -> golden binds the MODULE's net           => variables
arm w10_ownshapes  (the package copy a plain VARIABLE in every row)
    module-own packed struct   -> golden binds the MODULE's struct_net
    module-own UNPACKED struct -> golden binds the MODULE's struct_net
    module-own union/enum/int/real/packed array/typedef'd vector
                               -> golden binds the PACKAGE's logic_var
```

so the line is exactly STRUCT and nothing else crosses it. Reading slang's
kind instead cost cells in BOTH directions, every one measured against a real
golden:

* **THREE cells PRISTINE-RIGHT and patched WRONG** — a package PLAIN VARIABLE
  colliding with a module-own STRUCT: `w8_structown` `z_pv` and
  `w10_ownshapes` `m_st` / `m_us`. Golden binds the MODULE's `struct_net`
  (nets go first and the struct IS a net); the pristine binary agreed;
  `r11u82` as submitted took the package's `logic_var`.
* **TWO cells left pristine-wrong** — a package STRUCT colliding with a
  module-own NET: `w7_kindsrev` `y_sv` and `w9_typeshapes` `t_st`, where
  golden binds the PACKAGE's `struct_net` and the law declined.

`§ caNamesakeStructIsProducerNet82` classifies both candidates by the
PRODUCER's vector instead, and one predicate closes both directions. Every
other measured row is unmoved: the implementer's twelve arms read the same on
the corrected binary as on the submitted one, and the only three arms whose
databases move at all between them are `w7`, `w8` and `w10` (2, 2 and 4 lines).

The rest of LAW B survived everything thrown at it, all converting and none
breaking: both width orders (`w2_width`), an unpacked-array package copy where
the caller's array fence fires and `shadowed82`'s fallback hands the cell back
to the module's own (`w3_arraynet`), two wildcard-imported packages holding the
name (`w4_twopkg`, golden takes the FIRST import's copy), the one-hop fence two
scopes out (`w5_deepgen`, the deep cell stays UNBOUND on golden and on both
binaries), and the same colliding module instantiated twice (`w6_multiinst`,
four cells, per-instance objects, no pointer shared across instances).

## V3. THE SWITCHES

`SWITCHESV.r11v82.txt`, 28 arms, `sw82v.sh`: `R11U82_OFF=1` reproduces the
PRISTINE database BYTE FOR BYTE on **all 28**, and each of the four switches
returns exactly its own law's arms to pristine and leaves every other arm at
the corrected reading. `R11V82_STRUCTNET_OFF=1` moves only `w7`, `w8`, `w9`
and `w10` — the correction is droppable alone.

## V4. THE CENSUS, RE-RUN ON THE CORRECTED BINARY

`cellcen82.py` on BOTH corpora with `vfix.bin` reproduces the implementer's
numbers EXACTLY.  uhdm2rtlil — 1742 test×mode arms, **3892 `R11U74BIND`**, 1636 NO-SITE,
**4 `R11U82PATHFOLD` sites, every one `simple=1` and `declined=0`** (the
landed conversions' own cells, `struct_param_func_arg` and
`struct_param_func_loop` in both modes), **0 `R11U82COLLIDE` collisions**, and
the same rc histogram (5386/131/12/3, three rc=-11 rows).  surelog — 1573
arms, **12574 `R11U74BIND`**, 1521 NO-SITE, **2 `R11U82PATHFOLD` sites, both
`simple=1` and `declined=0`** (`StructParamFuncBodyFieldCompare` in both
modes), **0 collisions**, rc histogram 12571/900/578/32/12/4.  Both laws AND
the correction are corpus-invisible, and the zeros are zeros inside a live
3892-row and 12574-row population.  **PREDICTED MOVER SET: EMPTY, both corpora,
both modes.** POSITIVE CONTROL (`POSCTRLV.r11v82.txt`, the same trace, the same corrected
binary, all 28 arms): **15 `declined=1` rows and 38 `take=1` rows** — the
instrument sees both sites and both outcomes. On `w10_ownshapes` it named
`take=1` on all EIGHT collisions before the correction and on exactly the right
SIX after, with `ownNet=1` on the packed struct and on the unpacked one.

## V5. RESIDUES THE VERIFICATION ADDS (ranked, none of them regressions)

1. **A gen-scope namesake collision inside an INTERFACE body never reaches the
   imported copy** (`w1_iface`, 2 cells, byte-identical on all three
   binaries). LAW B's trace says `take=1` on both, so the lookup DOES choose
   golden's object; `resolve82` then finds no emitted object for a package
   signal hoisted into an interface, and `shadowed82`'s fallback correctly
   hands the cell back to where pristine left it. The defect is upstream in
   the hoist, not in the lookup: the interface's import holder has no
   `netMap`/`genScopeNets` entry. This is the same family as residue 2 below
   and is the natural next pass on this ground.
2. **`c4_portns` keeps its own 8-line head on every binary** — our port
   listing differs from golden's where a module PORT's net and an imported
   package net share a name. LAW B moved the cell's target onto golden's
   object and left the listing alone. Pre-existing.
3. **The `func_call` leftover ARGUMENT constant** (r11u75's residue) is still
   the single head of `xh_ancpath`, `xf_crossblk`, `s3_pkgbase`,
   `s5_ifacepath`, `s6_pathforms` and now `v1_upward`, `v4_twoinst`,
   `v5_ifaceport` and `v6_genpathchild`. It masks every other cell on those
   arms and is the one head between this family and `cmp_rc 0`. **R0.**
4. `w10_ownshapes` keeps the SAME 29-line head on all three binaries — golden
   carries a `logic_net (work@dut.m_us)` listing beside the `struct_net` for a
   module-own UNPACKED STRUCT and we do not. `w7_kindsrev` likewise keeps its
   own 8-line head on all three. Both are listing residues on the same
   struct-is-a-net ground and neither is touched by either law.

## V6. THE INSTRUMENT THAT SAW IT, AND THE ONE THAT COULD NOT

The regression is INVISIBLE to the implementer's own object-block scan.
`shapecmp82.py` keys on the top-level block (`work@dut.gv[0]`), and on
`w8_structown` / `w10_ownshapes` that block already differed from golden on the
PRISTINE binary — the other cells inside it were wrong — so a cell going the
other way inside the same block cannot flip the block's verdict. Run over all
28 arms × 6 sections, 1379 blocks, span-normalised, it reads
**MOVED-WRONG=0 CONVERTED=8** for the SUBMITTED patch and
**MOVED-WRONG=0 CONVERTED=12** for the corrected one: clean either way. That
is RESUME §9's "slot-keyed censuses are BLIND below the slot", and it is why
the implementer's scan read green.

The arbiter is the PER-CELL comparison — `calist82.py`'s resolving rows, one
per `cont_assign`, joined pristine-vs-tag over all 28 arms:

```
                       MOVED-WRONG   CONVERTED
submitted r11u82             4            50
verifier-corrected           1*           52
```

`*` the one remaining row is a bookkeeping artifact, not a defect, and it is
measured: on `s5_ifacepath` golden's `uhdmtopModules` carries SEVEN
`cont_assign` occurrences — three of the interface's own line-12 cell and ONE
of the written-path line-17 cell — while pristine carried one line-12 and
THREE line-17. The two errors CANCELLED in the count. LAW A removes the two
spurious line-17 mints (golden 1, ours 1 ✓) and the pre-existing interface
residue (golden 3, ours 1) then shows through as an unnamed golden-only row.
Nothing golden has was dropped: `uhdmallModules` and `uhdmallInterfaces` are
unchanged at 6 and 3 on every binary.

**TRUE MOVED-WRONG: 4 on the submitted patch, 0 on the corrected one.**

## V7. HOW TO RE-RUN THE VERIFICATION

```bash
GRID=<dir with all 28 arms> bash rr82.sh  <binary> <tag>     # arms, both rc values
GRID=<dir>                   bash sw82v.sh <pris> <fixed>    # the 4-switch ledger
GRID=<dir>                   bash score82.sh pris vfix       # order-blind distance
cd <grid> && bash cellmw82.sh vfix        # PER-CELL moved-wrong (the arbiter)
cd <grid> && python3 blockmw82.py         # per-BLOCK scan (blind below the block)
python3 cellcen82.py <repo> <corpus> <binary> out.tsv        # the site census
```

Evidence added by the verification: `GRIDV.{pris,patch,vfix}.r11v82.txt`,
`SWITCHESV.r11v82.txt`, `CENSUSV.r11v82.txt`, `POSCTRLV.r11v82.txt`,
`COLLIDEV.r11v82.txt`, `GATESV.r11v82.txt`, `GATES.transcript.r11v82.txt`, and
sixteen new arms under `grid/`.
