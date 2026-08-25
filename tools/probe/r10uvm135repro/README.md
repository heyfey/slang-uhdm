# r10uvm135 — § `assocIdxNameHoistNet135` — **AN ASSOCIATIVE-ARRAY INDEX TYPE WRITTEN AS A NAME IS COMPILED AS AN EXPRESSION, AND THAT EXPRESSION JOINS THE LATE-BINDING POOL EVEN WHEN THE COMPILED RANGE THROWS IT AWAY** — the SeqDriver ×2 **17-line head CLEARED**

**MEASUREMENT-ONLY probes.** Nothing in this directory is an acceptance judge.
The official `uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and
`scripts/verify_golden.py` are the authorities for every number below. slang was
**NOT** patched; `results/*.csv` were **READ ONLY**; **nothing was promoted** and
**NO CORPUS ROW CONVERTED**; `GOLDEN_DEFER` stayed unset.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours**, in every table here and
in every script.

| | |
|---|---|
| BASE | `f08eee05` |
| worktree | `/tmp/wt_r10uvm135` |
| pristine binary | md5 `583b10a735e405dcfaeb2f49695d6632`, frozen `chmod 555` before any sweep |
| patched binary | md5 `a8d181a5efe5cb64ae89d780f8ebadd2`, frozen `chmod 555` before any sweep |
| production surface | `include/UhdmExporter.h` (the law + ONE declaration), `src/EmitHelpers.h` (ONE predicate), `src/TaskFuncEmit.cpp` (the helper + THREE push sites), `src/ModuleEmit.cpp` (ONE null test in the binder) |
| probe surface | `tools/probe/r10uvm135repro/` only |

## READ THIS FIRST — the numbers

`rowheads.sh` on this pass's OWN pristine and patched sweeps, same instrument
both times:

| row-mode | pristine cmp lines | patched | heads |
|---|---|---|---|
| **SeqDriver default / testflags** | **17** | **80** | 1 — a **NEW** head, a different object (§7 R0) |
| SimpleUVM default / testflags | 64 | 64 | 1 unchanged, head text BYTE-IDENTICAL — **and the database still MOVED** |
| Scoreboard default | 64 | 64 | 1 unchanged, head text BYTE-IDENTICAL |
| MiniAmiq default / testflags | 80 | 80 | 1 unchanged, head text BYTE-IDENTICAL |
| BuildUVMPkg default / testflags | 60 | 60 | 1 unchanged, head text BYTE-IDENTICAL |
| Earlgrey_0_1 default / testflags | 150 / 150 | 150 / 150 | 1 unchanged, head text BYTE-IDENTICAL |
| Rggen default | 0 (CMP_EQUAL) | 0 (CMP_EQUAL) | 0 |
| corpus rows changed | — | **0** (both corpora, both modes; CMP_NOTEQUAL stays 19) | |
| byte movers | — | **4 / 956** surelog — exactly the four PREDICTED BY NAME — and **0 / 1358** uhdm2rtlil. Every mover ADDS 13 dump lines and REMOVES none | |
| the corpus FENCE | HIT **4**, OTHER **0**, MIRROR **6** | **HIT 0**, OTHER **0**, MIRROR still **6** and unchanged — the family CLOSED corpus-wide | |
| direction, 9 UVM databases | — | **2 net cells + 16 index-name cells TO-GOLDEN, AWAY-GOLDEN 0, MOVED-WRONG 0** | |

The 17-line head this pass cleared is `head_pris_default_SeqDriver.cmp`; the new
one is `head_pat_default_SeqDriver.cmp` (80 lines, §7 R0).

## 1. THE HEAD, CONFIRMED FROM `BaseClass.h` AND FROM BOTH DUMPS FIRST

The whole 17-line head, verbatim from this pass's own pristine cmp log:

```
LHS:
decompile:
logic_net: (work@top_tb.uvm_phase), line:1664:21, endln:1664:30
|vpiParent:
\_module_inst: work@top_tb (work@top_tb), file:.../SeqDriver/testbench.sv, line:210:1, endln:236:18
|vpiName:uvm_phase
|vpiFullName:work@top_tb.uvm_phase
|vpiNetType:1
RHS: <null>
```

`LHS` printing in full with `RHS: <null>` is the **SINGULAR** `SafeCompare`
overload's `lhs != nullptr && rhs == nullptr` arm
(`~/.local/include/uhdm/BaseClass.h:187-193`); the VECTOR overload (`:202-224`)
would have named the whole `module_inst::Nets` CONTAINER, not one net. Read off
golden's own dump, the carrier is **not** a reference at 1664 at all — it is the
`ref_obj` at `uvm_phase.svh:1722:82`, the `output bit pred_of_succ[uvm_phase]`
formal of `uvm_phase::get_predecessors_for_successors`, in the
`uhdmtopPackages` copy of that out-of-body body, whose `vpiActual` IS that wire.
Ours carries the same reference at the same place, **unbound**, and our
`work@top_tb` holds no net of that name at all.

Source — `uvm-1.2 base/uvm_phase.svh`, class `uvm_phase`:

```systemverilog
  protected bit  m_predecessors[uvm_phase];                       // :575  a CLASS PROPERTY
  extern local function void
      get_predecessors_for_successors(output bit pred_of_succ[uvm_phase]);  // :593 the PROTOTYPE
  local function string m_aa2string(bit aa[uvm_phase]);           // :635  an IN-BODY method

function void uvm_phase::get_adjacent_predecessor_nodes(ref uvm_phase pred[]);  // :1662 OOB
   bit predecessors[uvm_phase];                                   // :1664  <- the WIRE's SPAN

function void uvm_phase::get_predecessors_for_successors(output bit pred_of_succ[uvm_phase]);
                                                                  // :1722  <- the HEAD's reference
```

## 2. THE LAW

> **§ `assocIdxNameHoistNet135`** — *An associative-array dimension whose INDEX
> TYPE is written as a bare identifier that Surelog cannot resolve as a
> `typedef` is COMPILED AS AN EXPRESSION: it mints a `ref_obj`, registers it for
> late binding, and MINTS THE IMPORTING MODULE'S IMPLICIT WIRE — **even at the
> sites where the compiled range then throws the reference away**.*
>
> **THE GRAMMAR HALF, already § `assocIoRange9`'s.** *Surelog's dimension
> alternatives are ordered `unsized | unpacked | associative | queue`
> (`grammar/SV3_1aParser.g4:1212-1216`) and `unpacked_dimension` has an
> `OPEN_BRACKET constant_expression CLOSE_BRACKET` alternative (`:1195-1199`)
> that a bare identifier matches — so `[uvm_phase]` parses as
> `paConstant_expression` and only a type KEYWORD (`[string]`, `[int]`, `[*]`)
> ever reaches `paAssociative_dimension`.*
>
> **THE HALF § 9 DID NOT READ, and it is this law.**
> *`CompileHelper::compileRanges`'s `paConstant_expression` arm
> (`src/DesignCompile/CompileExpression.cpp:4166-4196`) compiles the bracket
> text AS AN EXPRESSION FIRST —*
> `expr *rexp = compileExpression(component, fC, rexpr, compileDesign, reduce, range, instance, muteErrors);`
> *— and `compileExpression`'s identifier arm mints a `ref_obj`, tries
> `bindVariable` and, on failure, calls `component->needLateBinding(ref)`
> (`CompileExpression.cpp:5769-5788`). ONLY THEN, and only when
> `reduce == Reduce::Yes`, does the code notice the name is a TYPE
> (`compileTypespec` succeeds, `:4096-4133`), build a FRESH
> `[UINT:0 : STRING:associative]` range and `continue` — **DISCARDING the first
> range and the `ref_obj` inside it**. The discarded reference is already in the
> pool. So a dimension whose range keeps the SIZE model (`<name> - 1`) carries a
> VISIBLE reference that `UhdmWriter::lateBinding` BINDS, and a dimension the
> elaborated listing PROMOTES carries an ORPHANED one — invisible in the
> database, but it still MINTS the wire and still stamps it with ITS OWN SPAN.
> That is why golden's wire is named at `:1722` and SPANNED at `:1664`.*
>
> **THE MINT is the shared one** (`UhdmWriter.cpp:3982-4004`, § `oobRefVarLocalHoistNet107` /
> § `pkgFreeSubRefVarHoistNet117` / § `newArrayArgHoistNet130`): a `logic_net`,
> `VpiNetType(1)`, the REFERENCE's span, parent the top module, ONE wire per NAME
> per module, and `UhdmWriter.cpp:3949-3959`'s parameter-value arm still wins over
> it (§ `hoistedNetNeverOverAModuleParam117`, re-measured here in arm a4).
>
> **WHICH BODIES — `hoistHomePkg117()`, and NO new home machinery.** *A class's
> IN-BODY member — a property, an in-body method's formal or local, an `extern`
> PROTOTYPE listing — belongs to the CLASS component, whose late-binding list
> `UhdmWriter.cpp:1067` never walks (`// lateBinding(s, classDef, c);`); an
> OUT-OF-BODY definition's own listing and a free package subroutine's belong to
> the PACKAGE and hoist.*
>
> **WHICH BRACKET NAMES — `assocIdxNameHoistable135`, and it is NOT the range-shape
> test.** *`compileExpression` opens with `getObject`
> (`CompileExpression.cpp:237-260`), which returns a TYPESPEC for any name in
> `component->getDataType(...)` — **every `typedef`, including a typedef of a
> CLASS HANDLE** — so no `ref_obj` is minted and no wire follows. A CLASS NAME
> and a TYPE PARAMETER's name are in neither map and fall through to the
> identifier arm; a SCOPED name (`pkg::T`) is resolved by the class-scope arm
> (`:4463-4519`) and never reaches it.*

### THE ELEVEN CORPUS SITES, one that mints, one that binds, nine that do neither

Read off golden alone, `uvm-1.2 base/uvm_phase.svh`, in SeqDriver's `work@top_tb`
and SimpleUVM's `work@top` (the two designs whose top module materialises
`uvm_pkg`'s late-binding list):

| site | written | home | range | golden |
|---|---|---|---|---|
| `:1664:21` | `bit predecessors[uvm_phase];` | `get_adjacent_predecessor_nodes` **OOB** | PROMOTED | **MINTS the wire**, and the wire keeps THIS span |
| `:1693:19` | `bit successors[uvm_phase];` | `get_adjacent_successor_nodes` **OOB** | PROMOTED | the SAME wire (one per NAME per module) |
| `:1722:82` | `output bit pred_of_succ[uvm_phase]` | `get_predecessors_for_successors` **OOB** | SIZE | **BINDS** the visible ref — **THE HEAD** |
| `:1758:22` | `bit pred_of_succ[uvm_phase];` | `m_wait_for_pred` **OOB task** | PROMOTED | the same wire |
| `:1896:17` | `int visited[uvm_phase];` | `sync` **OOB** | SIZE | the same wire |
| `:1946:17` | `int visited[uvm_phase];` | `unsync` **OOB** | SIZE | the same wire |
| `:2131:16` | `bit siblings[uvm_phase];` | `wait_for_self_and_siblings_to_drop` **OOB task** | PROMOTED | the same wire |
| `:575 :576 :579` | `protected bit m_predecessors[uvm_phase];` … | CLASS PROPERTIES | — | **NONE** |
| `:593:86` | the `extern` PROTOTYPE's formal | the class's PROTOTYPE listing | SIZE | **NONE** — reference left UNBOUND |
| `:635:44` | `bit aa[uvm_phase]` | `m_aa2string`, **IN-BODY** | SIZE | **NONE** — reference left UNBOUND |
| `uvm_pool.svh:42:20` | `protected T pool[KEY];` | a CLASS PROPERTY | SIZE | **NONE** — a type PARAMETER, but an in-body member |

The IN-BODY / OUT-OF-BODY split is the only feature that separates the two halves
(`uvm_phase` is the same name, the same file, the same class in both), and the
package-clone and `uhdmallPackages` copies of the very same bodies stay unbound
— § 117's own view rule, unchanged.

## 3. THE GRID — golden's answer for every cell, both views

`grid135.sh <arm.sv> <bin A> <bin B> <workdir> <cen bin>` builds three databases
per view (`def` and `--elabuhdm` / `-elabuhdm`) and censuses all six; every
command is echoed with its own `rc` into `<workdir>/cmds.txt` so the binary each
database came from is auditable BY PATH. All four arms ran **12/12 rc=0**.
`GRID.r10uvm135.txt` has every cell verbatim with the direction score. Each arm
gives every cell its OWN name.

**`g135_a1.sv` — the INDEX-KIND GRID, and the arm that DECIDES the gate.** ONE
home (an out-of-body package-class method), ONE position (a body local); twelve
spellings, written out of "kind order" so no cell can be read off another:

| a1 cell | written | golden | pristine | patched |
|---|---|---|---|---|
| 01 `[baseGammaCls135]` | a CLASS name | **wire** | — | **wire** ✓ |
| 07 `[fwdRhoCls135]` | a **FORWARD**-typedef'd class | **wire** | — | **wire** ✓ |
| 02 `[tdEtaHandle135]` | a typedef of a CLASS HANDLE | — | — | — ✓ |
| 08 `[tdLambdaInt135]` | a typedef of `int` | — | — | — ✓ |
| 11 `[tdNuVec135]` | a typedef of a vector | — | — | — ✓ |
| 03 `[enumIotaKind135]` | an ENUM typedef | — | — | — ✓ |
| 10 `[pkgScopedSigma135::scopedTauCls135]` | a SCOPED class name | — | — | — ✓ |
| 12 `[pkgScopedSigma135::scopedUpsEnum135]` | a SCOPED enum typedef | — | — | — ✓ |
| 04 `[string]` 05 `[int]` 09 `[*]` 06 `[paramMuCls135#(int)]` | never a bare name | — | — | — ✓ |

**2 of 2 net cells agree after; 0 before; AWAY-GOLDEN 0.** A FIRST CUT that gated
on § `assocIoRange9`'s range-SHAPE test ("written as a NAME") minted **six** wires
golden does not have — cells 02, 03, 08, 10, 11, 12. That refutation is why
`assocIdxNameHoistable135` reads Surelog's `getObject` and not the grammar.

**`g135_a2.sv` — the HOME GRID.** ONE index kind (a plain class name) in twelve
homes:

| a2 cell | home | golden | pristine | patched |
|---|---|---|---|---|
| `oobFfLocalMap135` | an OUT-OF-BODY method's body local | **wire** | — | **wire** ✓ |
| `fArgDdMap135` | the same method's **FORMAL** | **wire + BOUND ref** | — | **wire + BOUND ref** ✓ |
| `blkHhLocalMap135` | a **named `begin` BLOCK** local inside it | **BOUND** to it | unbound | **BOUND** ✓ |
| `fArgKkMap135` | a FREE PACKAGE **FUNCTION**'s formal | **BOUND** | unbound | **BOUND** ✓ |
| `oobIiTaskMap135` | an OUT-OF-BODY **TASK**'s local | promoted, no visible ref | the same | the same ✓ |
| `freeLlLocalMap135` / `freeNnTaskMap135` | a free package function's and TASK's locals | promoted, no visible ref | the same | the same ✓ |
| `propPsiMap135` | a CLASS **PROPERTY** | **—** | — | **—** ✓ **A CONTROL** |
| `fArgAaMap135` / `inBodyBbMap135` | an **IN-BODY** method's formal and local | **— unbound** | — | **— unbound** ✓ **THE CONTROL** |
| the `extern` PROTOTYPE's own listing (`19:55`) | | **— unbound** | — | **— unbound** ✓ |
| `unitQqLocalMap135` | a `$unit` function's local (a SCOPED name) | — | — | — ✓ |
| `pkgOoVarMap135` | a PACKAGE variable | — no wire | — | — ✓ |
| `modTtLocalMap135` | a **MODULE's OWN** function's local | binds the wire | — | — (residue **R-MODFN**, §7) |

**1 of 1 net cell and 5 of 5 moving reference cells agree after; 0 before;
AWAY-GOLDEN 0, MOVED-WRONG 0.** Golden's ONE wire in `work@topHomeEps135` is
spanned at the OUT-OF-BODY method's FORMAL (`23:65-23:77`) and the patched
binary's is spanned there too.

**`g135_a3.sv` — the OWNER / MULTIPLICITY GRID.** A child instantiated by one of
two file-scope-importing tops. Golden mints `keyAbcCls135` in `work@kidMnoMulti135`
**ALONE**; we mint it in all three. **That spread is the shared pool's, not this
law's, and the arm PROVES it**: the CONTROL name `ctlSizeZab135` — a
`new[...]` size argument, § `newArrayArgHoistNet130`'s family, which this pass
does not touch — is spread by the **PRISTINE** binary over `work@topStuMulti135`
and `work@topYzaMulti135` in exactly the same way (`g=0 pris=2 pat=2`, unchanged).
uvm107's residue **R-MULTI**, inherited; **zero corpus reach** (the fence's MIRROR
set is byte-identical before and after and contains no index name).

**`g135_a4.sv` — the TYPE-PARAMETER AND PARAMETER-SHADOW GRID**, `uvm_pool`'s own
shape:

| a4 cell | written | golden | pristine | patched |
|---|---|---|---|---|
| `[KEYBRAVO135]` in an OOB body | a **TYPE PARAMETER**'s name | **wire** | — | **wire** ✓ |
| `[KEYBRAVO135]` as a class PROPERTY | the same name, in-body | — | — | — ✓ |
| `[shadowGolfCls135]` in `work@topNovemberFree135` | a class name, nothing shadows it | **wire** | — | **wire** ✓ |
| `[shadowGolfCls135]` in `work@topKiloParam135` | the module declares `parameter int shadowGolfCls135` | **—** | — | **—** ✓ (§ `hoistedNetNeverOverAModuleParam117`, re-measured for THIS reference kind) |
| `ctlRomeoSize135` | the R-MULTI CONTROL, § 130's family | one module | two | two (unchanged) |

**2 of 2 net cells agree after; 0 before; the parameter suppressor holds.**

**GOLDEN-VS-GOLDEN CALIBRATION FIRST** (`goldcen135.sh`, `CENSUS.r10uvm135.txt`).
Over the five UVM tests that have both modes, `default` and `testflags` are two
independent Surelog runs of the same design and this family's rows are compared
pair by pair: **5 pairs calibrated, 0 SKIP, 0 pairs differ, EXPM_N = 0** over 471
implicit-net rows. `Earlgrey_0_1` is excluded and why is recorded there (its two
goldens are two DIFFERENT elaborations — the `testflags` run carries
`work@padring.gen_dio_pads[1..14].*` instances the `default` run does not); the
fence finds ZERO cells of this family in it or in Rggen.

## 4. THE FIX

Four edits, and the code is fifteen lines.

* **`include/UhdmExporter.h`** — the law (the Surelog decode above, the eleven
  measured corpus sites) and ONE declaration,
  `void hoistAssocIdxName135(UHDM::ref_obj*, std::string_view, slang::SourceRange);`.
* **`src/EmitHelpers.h`** — ONE predicate, `assocIdxNameHoistable135(idx, sx)`:
  ```cpp
  if (!sx || sx->kind != syntax::SyntaxKind::IdentifierName) return false;
  if (idx.kind != SymbolKind::TypeAlias)                     return true;
  return assocIdxIsTypeParam51(idx);
  ```
  with the `getObject` decode and the twelve measured a1 cells beside it.
* **`src/TaskFuncEmit.cpp`** — the helper (whose whole body is the § 117 pool
  choice) and THREE push sites, all inside branches that already existed:
  ```cpp
  const Symbol* home135 = hoistHomePkg117();
  if (!home135 || name.empty()) return;
  auto& pool135 = (inClassBodyEmit && classBodyHomePkg75) ? classPropRefs
                                                          : pkgFreeSubPropRefs117;
  pool135.push_back({ref, std::string(name), range, home135});
  ```
  — `makeAssocArrayVar`'s SIZE arm pushes with its `ref_obj`, its PROMOTED arm
  pushes with `nullptr` (the orphan), and `emitIoRanges34`'s named arm pushes
  with its own `ref_obj` under a new `hoist135` parameter that the `extern`
  PROTOTYPE listing passes as `!protoOf` — golden leaves the prototype's
  reference unbound (`uvm_phase.svh:593:86`).
* **`src/ModuleEmit.cpp`** — ONE null test, `if (cpr.ref)`, so a ref-less entry
  mints and spans the wire and binds nothing.

**NOTHING ELSE CHANGED.** § `assocIoRange9`'s range SHAPE (`namedIdx0` /
`named9`, keyword-vs-name) is untouched; § `assocIdxTypeParamNoIndexTs51`,
§ `assocIndexTsSigned63` and § `sharedAliasNoStamp41` are untouched;
§ `oobRefVarLocalHoistNet107`, § `pkgFreeSubRefVarHoistNet117` and
§ `newArrayArgHoistNet130` push at their own sites as before, and the staging
vector, the two-vector choice and the parameter suppressor are theirs, unchanged.

**DIRECTION: it adds ONE wire per module per name and the bindings that wire
already deserved, and nothing else.** The order-blind whole-dump attribution
(`attrib135.sh`) over all four movers is **13 ADDED lines and 0 REMOVED lines**
each — the `logic_net`, its `vpiParent` / `vpiName` / `vpiFullName` /
`vpiNetType` / `vpiNet` lines, and the three `vpiActual` edges — and the wire
lands on golden's own span (`uvm_phase`@1664:21-1664:30 in both designs).

## 5. THE FENCE AND THE PREDICTION — written from PRISTINE databases only

`fence135.sh <sweep workdir> <cen bin> <out.tsv>` censuses BOTH sides of every
test in a sweep workdir with `ct135cen` and joins the IMPLICIT-NET rows on the
key both producers can spell, `(module fullname, net name)`:

* **HIT** — golden has the wire, we do NOT, and the name is one OUR OWN database
  writes in an associative-index bracket.
* **OTHER** — golden has the wire and we do not, but the name is not an index
  name of ours — another family's; these must NOT move.
* **MIRROR** — WE have a wire golden does not. A WIDENING; must stay 0 for index
  names.

| corpus | measured | SKIP | **HIT** | OTHER | **MIRROR** | **databases that MUST move** |
|---|---|---|---|---|---|---|
| surelog, PRISTINE | 1573 | 617 | **4** | 0 | 6 (none an index name) | **4** |
| surelog, PATCHED | 1573 | 617 | **0** | 0 | 6 — the identical rows | — |
| uhdm2rtlil, PRISTINE | 1462 | 104 | **0** | 0 | **0** — the predicted NONE | **0** |
| uhdm2rtlil, PATCHED | 1462 | 104 | **0** | 0 | **0** | — |

The 4 HIT cells are ONE NAME × FOUR DATABASES — `uvm_phase` in
`work@top_tb` / `work@top` of `{default,testflags}/{SeqDriver,SimpleUVM}` —
listed by name in `FENCE.pristine.surelog.tsv`. The 6 MIRROR rows are `clp`
(SeqDriver ×2, SimpleUVM ×2) and `top` (SimpleUVM ×2), other families' residues,
byte-identical before and after.

`pred135.sh` is the side-blind predictor and reads **OUR SIDE ALONE** — no golden
is opened. `MAY-MOVE` is an associative-index-name cell in the ELABORATED package
listing whose home can hoist: **surelog 4 rows in 4 databases** (SeqDriver ×2 and
MiniAmiq ×2, `PREDICTION.pristine.surelog.tsv`), **uhdm2rtlil 0 and 0**. It is a
SUPERSET in one direction and blind in another, exactly as its header says: a
side-blind view cannot see that MiniAmiq's tops materialise no package that
carries the reference (so MiniAmiq did NOT move), nor that SimpleUVM's own copy
sits in a listing the census labels `OTHER` (so SimpleUVM DID). The fence is the
prediction that was checked; the measured movers are exactly its four.

## 6. THE GATE BATTERY

See `GATES.r10uvm135.txt` for the whole battery with its numbers, the `cmds.txt`
binary audit BY PATH, and the four boundary runs. Headline: goldens **23/0**
(and `/bin/false` **0/23**); uhdm2rtlil **679/50/2** in BOTH modes on BOTH
binaries; the surelog corpus **1588 rows, CMP_NOTEQUAL 19, unchanged**;
`ct8rows` **PASS** (0 differing rows, status AND dump column) against the
committed baselines AND against this pass's own pristine sweep, on both corpora;
byte movers **4/956** and **0/1358**, all four predicted by name, `SELFCHECK`
955/956 and 1357/1358; canaries **ok=52 / ok=8, changed=0**, `ctcan2` PASS ×2,
`canaudit` **audited=29 UNCOVERED=0 FENCE-BREACH=0**; the five protected
databases byte-identical with `SVSwitch` pinned at `4842211c4030` and
`YosysVerx` at `6ccda350c24a`.

**THE BOUNDARY** (`BOUNDARY.r10uvm135.txt`), over a COPY of the WHOLE probe tree,
no path filter, both MODEs and both VIEWs — `PROCESSED == LISTED`
(3934/3934 twice, 1580/1580 twice) and `PRIS_REJECT == PATCHED_REJECT` in all
four, no asymmetric reject. Differing arms:

* this pass's own `g135_a1..a4.sv`;
* **`r10uvm40repro/t57a/dut.sv`** — an EARLIER pass's arm that MOVED, and it
  moves **TOWARD golden**: Surelog, run on that arm here, carries
  `logic_net: (work@top57.key57), line:31:14, endln:31:19` in `work@top57` and
  the pristine binary carried none. Scored **3 TO-GOLDEN, 0 AWAY-GOLDEN, 0
  MOVED-WRONG** (`GRID.r10uvm135.txt`);
* **`r10buvm22repro/g22.sv`** — residue **R-ADDRCONST**, § 130's own and NOT this
  law: 24 lines of `|vpiDecompile:` / `|UINT:` values that are `.bss` ADDRESSES
  of the emitting binary, every one shifted by exactly `0x1000` between the two
  non-PIE binaries (`22478425 -> 22482521`, `22477569 -> 22481665`). `g22.sv`'s
  only associative dimension is written `[string]`;
* eight directories under `MODE=dir` only (`r10uvm130`, `r10uvm75`, `r10uvm76`,
  `r10uvm88`, `r10uvm117`, `r10v109`, `r10v117`, `r10v130`) — **ORDER-ONLY**:
  sorting both dumps makes all 15 arm/view pairs BYTE-EQUAL, and the PRISTINE
  binary run FOUR times over `r10uvm75repro`'s own directory produced FOUR
  DIFFERENT dumps by itself (the macro-buffer `SourceLocation` coin, RESUME §9).

## 7. RESIDUES AND R0

**R0 — THE NEW HEAD, SeqDriver ×2, 80 lines** (`head_pat_default_SeqDriver.cmp`,
both modes identical): a NESTED `foreach` whose array expression is a hier_path.
`uvm_phase.svh:1730`, `foreach (successors[s].m_predecessors[pred])` — golden's
`foreach_stmt` at `1730:7` carries
`ref_var (uvm_pkg::uvm_phase::get_predecessors_for_successors::successors)`
@1730:16 (the ROOT name alone, with its own `ref_typespec` onto the
`array_typespec` @1724:15), while we carry the WHOLE
`hier_path (successors[s].m_predecessors)` @1730:16-1730:44 in that slot. A
foreach-over-a-hier-path family, ranked first.

**R-MODFN — a MODULE's OWN subroutine.** Arm a2 cell `modTtLocalMap135`
(`bit modTtLocalMap135 [idxPhiCls135];` in `topHomeEps135`'s own function,
`66:27`) and `r10uvm40repro/t57a/dut.sv:125` (`int mmacls[key57];` in
`top57::mmAssoc57`): golden BINDS that reference to the hoisted wire — a module's
late-binding list carries its OWN unbound references too — and we leave it
unbound. **ZERO corpus witnesses on either corpus** — the fence's HIT set is 4
cells and all four are package-homed — so it is recorded rather than widened on no
evidence. This is uvm117's **R-MODFN**, unchanged, now witnessed for a third
reference family.

**R-PKGVARRANGE — a PACKAGE variable's own dimension.** Arm a2 cell
`pkgOoVarMap135` (`51:23`): golden emits the SIZE-model range for a package-scope
associative variable and we emit none. NO wire on either side (a package variable
is not in any module's late-binding list), so it is not this law; pre-existing and
unchanged (`g=2 pris=0 pat=0`).

**R-MULTI — the hoisting module COUNT.** Arms a3 and a4: golden mints one wire in
the FIRST module written that cannot bind the name; our pool binds every module
that materialises the home package. Inherited from uvm107 and shared by every law
that uses the pool; both arms carry a CONTROL name from § 130's family showing the
PRISTINE binary already spreading it the same way. **Zero corpus reach** (fence
MIRROR byte-identical before and after).

**R-COPYCOUNT and R-PROTOSPAN — the copies of an out-of-body body, and the
prototype's span.** In SeqDriver golden carries ONE `ref_obj` at `:1722:82` in the
package's `uhdmallPackages` listing where we carry one, but THREE in the class's
own listings where we carry six, and golden spans the class's PROTOTYPE copy at
`:593:86` where we span it at `:1722:82`. Both are UNBOUND on both sides in every
copy the judge can reach, so no generated `Compare` reads a difference (a
`ref_obj::Compare` reads `VpiName` and `Actual_group`, never a span). Pre-existing,
unchanged by this pass (`CENSUS.r10uvm135.txt` prints them as PARTIAL / STILL-WRONG
with `MOVED-WRONG 0`), and uvm107's R-ELABMULT family.

**R-ADDRCONST — the `.bss` address leak in the associative typedef's
`array_typespec`.** § 130's, unchanged and untouched; see §6.

## 8. THE INSTRUMENTS IN THIS DIRECTORY

| file | what it is |
|---|---|
| `ct135cen.cpp` / `build135.sh` | the census: one `NET` row per module net and one `AIDX` row per associative dimension whose index is a NAME, in both the SIZE and the PROMOTED shapes, with the `Actual_group` column |
| `score135.py` | the three-way scorer (golden / pristine / patched) with `TO-GOLDEN` / `AWAY-GOLDEN` / `STILL-WRONG` / `PARTIAL` / `MOVED-WRONG` |
| `grid135.sh` | builds an arm's six databases (three producers × two views) and censuses them; every command with its own `rc` in `cmds.txt` |
| `goldcen135.sh` | the golden-vs-golden calibration, run FIRST |
| `cen135.sh` | the direction census over named corpus rows |
| `fence135.sh` | the corpus fence (HIT / OTHER / MIRROR) |
| `pred135.sh` | the side-blind mover predictor (no golden opened) |
| `attrib135.sh` | order-blind line attribution for one mover |
| `bound135.sh` | the boundary gate over a COPY of the whole probe tree |
| `g135_a1..a4.sv` | the grid arms |
| `byteverify.sh` `ct8rows.sh` `canaries.sh` `ctcan2.sh` `canaudit.sh` `rowheads.sh` | the shared gates, copied verbatim so this directory runs its own battery |
